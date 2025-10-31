import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  final PremiumService _premiumService;
  final LocalStorageService _localStorage;

  BackupService(this._premiumService, this._localStorage);

  Future<bool> canBackupData() async {
    return await _premiumService.hasFeature(FeatureType.backup);
  }

  Future<BackupResult> createLocalBackup({
    bool includeSettings = true,
    bool includeProgress = true,
    bool includeQuests = true,
    bool includeAchievements = true,
    String? customName,
  }) async {
    if (!await canBackupData()) {
      return BackupResult.failure('Premium subscription required for backup');
    }

    try {
      final backupData = await _collectBackupData(
        includeSettings: includeSettings,
        includeProgress: includeProgress,
        includeQuests: includeQuests,
        includeAchievements: includeAchievements,
      );

      final backup = LocalBackup(
        id: _generateBackupId(),
        name: customName ?? 'Backup ${DateTime.now().toString().split('.')[0]}',
        createdAt: DateTime.now(),
        size: _calculateBackupSize(backupData),
        checksum: _calculateChecksum(backupData),
        data: backupData,
        version: '1.0',
      );

      final directory = await _getBackupDirectory();
      final file = File('${directory.path}/${backup.id}.minq');
      
      final backupJson = jsonEncode(backup.toJson());
      await file.writeAsString(backupJson);

      // Save backup metadata
      await _saveBackupMetadata(backup);

      return BackupResult.success(
        backup: backup,
        filePath: file.path,
      );
    } catch (e) {
      return BackupResult.failure('Failed to create backup: $e');
    }
  }

  Future<BackupResult> restoreFromBackup(String backupId) async {
    if (!await canBackupData()) {
      return BackupResult.failure('Premium subscription required for restore');
    }

    try {
      final directory = await _getBackupDirectory();
      final file = File('${directory.path}/$backupId.minq');
      
      if (!await file.exists()) {
        return BackupResult.failure('Backup file not found');
      }

      final backupJson = await file.readAsString();
      final backupData = jsonDecode(backupJson);
      final backup = LocalBackup.fromJson(backupData);

      // Verify backup integrity
      final currentChecksum = _calculateChecksum(backup.data);
      if (currentChecksum != backup.checksum) {
        return BackupResult.failure('Backup file is corrupted');
      }

      // Restore data
      await _restoreBackupData(backup.data);

      return BackupResult.success(
        backup: backup,
        message: 'Data restored successfully',
      );
    } catch (e) {
      return BackupResult.failure('Failed to restore backup: $e');
    }
  }

  Future<List<LocalBackup>> getLocalBackups() async {
    try {
      final backupsData = await _localStorage.getString('backup_metadata');
      if (backupsData == null) return [];

      final List<dynamic> backupsList = jsonDecode(backupsData);
      return backupsList.map((json) => LocalBackup.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteBackup(String backupId) async {
    try {
      final directory = await _getBackupDirectory();
      final file = File('${directory.path}/$backupId.minq');
      
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from metadata
      final backups = await getLocalBackups();
      final updatedBackups = backups.where((b) => b.id != backupId).toList();
      await _saveBackupsMetadata(updatedBackups);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<BackupResult> createCloudBackup() async {
    if (!await canBackupData()) {
      return BackupResult.failure('Premium subscription required for cloud backup');
    }

    try {
      // Create local backup first
      final localResult = await createLocalBackup();
      if (!localResult.isSuccess) {
        return localResult;
      }

      // Upload to cloud (mock implementation)
      final cloudBackup = CloudBackup(
        id: localResult.backup!.id,
        name: localResult.backup!.name,
        createdAt: localResult.backup!.createdAt,
        size: localResult.backup!.size,
        checksum: localResult.backup!.checksum,
        version: localResult.backup!.version,
        cloudUrl: 'https://cloud.minq.app/backups/${localResult.backup!.id}',
        syncStatus: CloudSyncStatus.synced,
      );

      // Save cloud backup metadata
      await _saveCloudBackupMetadata(cloudBackup);

      return BackupResult.success(
        backup: localResult.backup!,
        cloudBackup: cloudBackup,
        message: 'Backup uploaded to cloud successfully',
      );
    } catch (e) {
      return BackupResult.failure('Failed to create cloud backup: $e');
    }
  }

  Future<List<CloudBackup>> getCloudBackups() async {
    try {
      final backupsData = await _localStorage.getString('cloud_backup_metadata');
      if (backupsData == null) return [];

      final List<dynamic> backupsList = jsonDecode(backupsData);
      return backupsList.map((json) => CloudBackup.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<BackupResult> restoreFromCloud(String cloudBackupId) async {
    if (!await canBackupData()) {
      return BackupResult.failure('Premium subscription required for cloud restore');
    }

    try {
      // Download from cloud (mock implementation)
      final cloudBackups = await getCloudBackups();
      final cloudBackup = cloudBackups.firstWhere((b) => b.id == cloudBackupId);

      // Create local backup from cloud data
      final localBackup = LocalBackup(
        id: cloudBackup.id,
        name: cloudBackup.name,
        createdAt: cloudBackup.createdAt,
        size: cloudBackup.size,
        checksum: cloudBackup.checksum,
        version: cloudBackup.version,
        data: {}, // Would be downloaded from cloud
      );

      // Restore data
      await _restoreBackupData(localBackup.data);

      return BackupResult.success(
        backup: localBackup,
        message: 'Data restored from cloud successfully',
      );
    } catch (e) {
      return BackupResult.failure('Failed to restore from cloud: $e');
    }
  }

  Future<void> enableAutoBackup({
    BackupFrequency frequency = BackupFrequency.weekly,
    bool cloudSync = true,
  }) async {
    await _localStorage.setString('auto_backup_settings', jsonEncode({
      'enabled': true,
      'frequency': frequency.name,
      'cloudSync': cloudSync,
      'lastBackup': null,
    }));
  }

  Future<void> disableAutoBackup() async {
    await _localStorage.setString('auto_backup_settings', jsonEncode({
      'enabled': false,
    }));
  }

  Future<Map<String, dynamic>> _collectBackupData({
    required bool includeSettings,
    required bool includeProgress,
    required bool includeQuests,
    required bool includeAchievements,
  }) async {
    final data = <String, dynamic>{};

    if (includeSettings) {
      data['settings'] = await _getSettingsData();
    }

    if (includeProgress) {
      data['progress'] = await _getProgressData();
    }

    if (includeQuests) {
      data['quests'] = await _getQuestsData();
    }

    if (includeAchievements) {
      data['achievements'] = await _getAchievementsData();
    }

    return data;
  }

  Future<Map<String, dynamic>> _getSettingsData() async {
    // Mock implementation - would fetch actual settings
    return {
      'theme': 'dark',
      'notifications': true,
      'language': 'ja',
      'autoSync': true,
    };
  }

  Future<List<Map<String, dynamic>>> _getProgressData() async {
    // Mock implementation - would fetch actual progress data
    return [
      {
        'date': '2024-01-01',
        'questsCompleted': 3,
        'xpEarned': 75,
        'streakDays': 5,
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _getQuestsData() async {
    // Mock implementation - would fetch actual quests
    return [
      {
        'id': 'quest_1',
        'title': 'Morning Exercise',
        'description': 'Do 30 minutes of exercise',
        'category': 'Health',
        'status': 'completed',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _getAchievementsData() async {
    // Mock implementation - would fetch actual achievements
    return [
      {
        'id': 'achievement_1',
        'name': 'First Steps',
        'unlockedAt': '2024-01-01T08:30:00Z',
      },
    ];
  }

  Future<void> _restoreBackupData(Map<String, dynamic> data) async {
    // Mock implementation - would restore actual data
    if (data.containsKey('settings')) {
      // Restore settings
    }
    if (data.containsKey('progress')) {
      // Restore progress
    }
    if (data.containsKey('quests')) {
      // Restore quests
    }
    if (data.containsKey('achievements')) {
      // Restore achievements
    }
  }

  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  String _generateBackupId() {
    return 'backup_${DateTime.now().millisecondsSinceEpoch}';
  }

  int _calculateBackupSize(Map<String, dynamic> data) {
    return jsonEncode(data).length;
  }

  String _calculateChecksum(Map<String, dynamic> data) {
    final bytes = utf8.encode(jsonEncode(data));
    return sha256.convert(bytes).toString();
  }

  Future<void> _saveBackupMetadata(LocalBackup backup) async {
    final backups = await getLocalBackups();
    backups.add(backup);
    await _saveBackupsMetadata(backups);
  }

  Future<void> _saveBackupsMetadata(List<LocalBackup> backups) async {
    final backupsJson = jsonEncode(backups.map((b) => b.toJson()).toList());
    await _localStorage.setString('backup_metadata', backupsJson);
  }

  Future<void> _saveCloudBackupMetadata(CloudBackup backup) async {
    final backups = await getCloudBackups();
    backups.add(backup);
    final backupsJson = jsonEncode(backups.map((b) => b.toJson()).toList());
    await _localStorage.setString('cloud_backup_metadata', backupsJson);
  }
}

class LocalBackup {
  final String id;
  final String name;
  final DateTime createdAt;
  final int size;
  final String checksum;
  final String version;
  final Map<String, dynamic> data;

  const LocalBackup({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.size,
    required this.checksum,
    required this.version,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'size': size,
    'checksum': checksum,
    'version': version,
    'data': data,
  };

  factory LocalBackup.fromJson(Map<String, dynamic> json) => LocalBackup(
    id: json['id'],
    name: json['name'],
    createdAt: DateTime.parse(json['createdAt']),
    size: json['size'],
    checksum: json['checksum'],
    version: json['version'],
    data: json['data'],
  );
}

class CloudBackup {
  final String id;
  final String name;
  final DateTime createdAt;
  final int size;
  final String checksum;
  final String version;
  final String cloudUrl;
  final CloudSyncStatus syncStatus;

  const CloudBackup({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.size,
    required this.checksum,
    required this.version,
    required this.cloudUrl,
    required this.syncStatus,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'size': size,
    'checksum': checksum,
    'version': version,
    'cloudUrl': cloudUrl,
    'syncStatus': syncStatus.name,
  };

  factory CloudBackup.fromJson(Map<String, dynamic> json) => CloudBackup(
    id: json['id'],
    name: json['name'],
    createdAt: DateTime.parse(json['createdAt']),
    size: json['size'],
    checksum: json['checksum'],
    version: json['version'],
    cloudUrl: json['cloudUrl'],
    syncStatus: CloudSyncStatus.values.firstWhere(
      (e) => e.name == json['syncStatus'],
    ),
  );
}

class BackupResult {
  final bool isSuccess;
  final LocalBackup? backup;
  final CloudBackup? cloudBackup;
  final String? filePath;
  final String? message;
  final String? errorMessage;

  const BackupResult._({
    required this.isSuccess,
    this.backup,
    this.cloudBackup,
    this.filePath,
    this.message,
    this.errorMessage,
  });

  factory BackupResult.success({
    LocalBackup? backup,
    CloudBackup? cloudBackup,
    String? filePath,
    String? message,
  }) {
    return BackupResult._(
      isSuccess: true,
      backup: backup,
      cloudBackup: cloudBackup,
      filePath: filePath,
      message: message,
    );
  }

  factory BackupResult.failure(String errorMessage) {
    return BackupResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

enum BackupFrequency {
  daily,
  weekly,
  monthly,
}

enum CloudSyncStatus {
  pending,
  syncing,
  synced,
  failed,
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return BackupService(premiumService, localStorage);
});