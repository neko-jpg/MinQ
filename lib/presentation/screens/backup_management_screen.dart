import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/premium/backup_service.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';
import 'package:minq/presentation/widgets/common/loading_overlay.dart';

class BackupManagementScreen extends ConsumerStatefulWidget {
  const BackupManagementScreen({super.key});

  @override
  ConsumerState<BackupManagementScreen> createState() => _BackupManagementScreenState();
}

class _BackupManagementScreenState extends ConsumerState<BackupManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTierAsync = ref.watch(currentTierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: context.colorTokens.surface,
        foregroundColor: context.colorTokens.textPrimary,
        elevation: 0,
        bottom: currentTierAsync.when(
          data: (tier) => tier.hasFeature(FeatureType.backup)
              ? TabBar(
                  controller: _tabController,
                  labelColor: context.colorTokens.primary,
                  unselectedLabelColor: context.colorTokens.textSecondary,
                  indicatorColor: context.colorTokens.primary,
                  tabs: const [
                    Tab(text: 'Local Backups'),
                    Tab(text: 'Cloud Backups'),
                  ],
                )
              : null,
          loading: () => null,
          error: (error, stack) => null,
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: currentTierAsync.when(
          data: (tier) => tier.hasFeature(FeatureType.backup)
              ? _buildBackupTabs(context)
              : _buildPremiumRequired(context),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const Center(
            child: Text('Error loading subscription status'),
          ),
        ),
      ),
      floatingActionButton: currentTierAsync.when(
        data: (tier) => tier.hasFeature(FeatureType.backup)
            ? FloatingActionButton.extended(
                onPressed: _createBackup,
                backgroundColor: context.colorTokens.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.backup),
                label: const Text('Create Backup'),
              )
            : null,
        loading: () => null,
        error: (error, stack) => null,
      ),
    );
  }

  Widget _buildBackupTabs(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildLocalBackupsTab(context),
        _buildCloudBackupsTab(context),
      ],
    );
  }

  Widget _buildLocalBackupsTab(BuildContext context) {
    return FutureBuilder<List<LocalBackup>>(
      future: ref.read(backupServiceProvider).getLocalBackups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: context.colorTokens.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading backups',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorTokens.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final backups = snapshot.data ?? [];

        if (backups.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.backup,
            title: 'No Local Backups',
            subtitle: 'Create your first backup to secure your data',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: backups.length,
          itemBuilder: (context, index) {
            final backup = backups[index];
            return _buildLocalBackupCard(context, backup);
          },
        );
      },
    );
  }

  Widget _buildCloudBackupsTab(BuildContext context) {
    return FutureBuilder<List<CloudBackup>>(
      future: ref.read(backupServiceProvider).getCloudBackups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading cloud backups: ${snapshot.error}'),
          );
        }

        final backups = snapshot.data ?? [];

        if (backups.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.cloud_off,
            title: 'No Cloud Backups',
            subtitle: 'Enable cloud sync to automatically backup your data',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: backups.length,
          itemBuilder: (context, index) {
            final backup = backups[index];
            return _buildCloudBackupCard(context, backup);
          },
        );
      },
    );
  }

  Widget _buildLocalBackupCard(BuildContext context, LocalBackup backup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: context.colorTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorTokens.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder,
                  color: context.colorTokens.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${_formatDate(backup.createdAt)}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleLocalBackupAction(value, backup),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'restore',
                      child: Row(
                        children: [
                          Icon(Icons.restore, size: 20),
                          SizedBox(width: 8),
                          Text('Restore'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: context.colorTokens.error),
                          const SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: context.colorTokens.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  context,
                  icon: Icons.storage,
                  label: _formatFileSize(backup.size),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  icon: Icons.verified,
                  label: 'v${backup.version}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudBackupCard(BuildContext context, CloudBackup backup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: context.colorTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorTokens.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud,
                  color: context.colorTokens.info,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Synced: ${_formatDate(backup.createdAt)}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSyncStatusBadge(context, backup.syncStatus),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleCloudBackupAction(value, backup),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'restore',
                      child: Row(
                        children: [
                          Icon(Icons.cloud_download, size: 20),
                          SizedBox(width: 8),
                          Text('Restore'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  context,
                  icon: Icons.storage,
                  label: _formatFileSize(backup.size),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  icon: Icons.verified,
                  label: 'v${backup.version}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorTokens.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colorTokens.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusBadge(BuildContext context, CloudSyncStatus status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case CloudSyncStatus.synced:
        color = context.colorTokens.success;
        icon = Icons.check_circle;
        break;
      case CloudSyncStatus.syncing:
        color = context.colorTokens.warning;
        icon = Icons.sync;
        break;
      case CloudSyncStatus.pending:
        color = context.colorTokens.info;
        icon = Icons.schedule;
        break;
      case CloudSyncStatus.failed:
        color = context.colorTokens.error;
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: context.colorTokens.textMuted,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorTokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumRequired(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 64,
              color: context.colorTokens.textMuted,
            ),
            const SizedBox(height: 24),
            Text(
              'Premium Feature',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Backup and restore features are available for Premium subscribers only. Upgrade to secure your data.',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorTokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorTokens.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _buildCreateBackupDialog(context),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final backupService = ref.read(backupServiceProvider);
        final backupResult = await backupService.createLocalBackup(
          includeSettings: result['settings'] ?? true,
          includeProgress: result['progress'] ?? true,
          includeQuests: result['quests'] ?? true,
          includeAchievements: result['achievements'] ?? true,
          customName: result['name'],
        );

        if (backupResult.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Backup created successfully'),
              backgroundColor: context.colorTokens.success,
            ),
          );
          setState(() {}); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(backupResult.errorMessage ?? 'Backup failed'),
              backgroundColor: context.colorTokens.error,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: context.colorTokens.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildCreateBackupDialog(BuildContext context) {
    final nameController = TextEditingController();
    bool includeSettings = true;
    bool includeProgress = true;
    bool includeQuests = true;
    bool includeAchievements = true;

    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Create Backup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Backup Name (Optional)',
                  hintText: 'Enter custom name',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Include:',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              CheckboxListTile(
                value: includeSettings,
                onChanged: (value) => setState(() => includeSettings = value!),
                title: const Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: includeProgress,
                onChanged: (value) => setState(() => includeProgress = value!),
                title: const Text('Progress Data'),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: includeQuests,
                onChanged: (value) => setState(() => includeQuests = value!),
                title: const Text('Quests'),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: includeAchievements,
                onChanged: (value) => setState(() => includeAchievements = value!),
                title: const Text('Achievements'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop({
              'name': nameController.text.isNotEmpty ? nameController.text : null,
              'settings': includeSettings,
              'progress': includeProgress,
              'quests': includeQuests,
              'achievements': includeAchievements,
            }),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLocalBackupAction(String action, LocalBackup backup) async {
    switch (action) {
      case 'restore':
        await _restoreBackup(backup.id);
        break;
      case 'delete':
        await _deleteBackup(backup.id);
        break;
    }
  }

  Future<void> _handleCloudBackupAction(String action, CloudBackup backup) async {
    switch (action) {
      case 'restore':
        await _restoreCloudBackup(backup.id);
        break;
    }
  }

  Future<void> _restoreBackup(String backupId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text('This will replace your current data with the backup. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorTokens.warning,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final backupService = ref.read(backupServiceProvider);
        final result = await backupService.restoreFromBackup(backupId);

        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Backup restored successfully'),
              backgroundColor: context.colorTokens.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Restore failed'),
              backgroundColor: context.colorTokens.error,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: context.colorTokens.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _restoreCloudBackup(String backupId) async {
    // Similar to _restoreBackup but for cloud backups
    await _restoreBackup(backupId); // Simplified for now
  }

  Future<void> _deleteBackup(String backupId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text('Are you sure you want to delete this backup? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorTokens.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final backupService = ref.read(backupServiceProvider);
        await backupService.deleteBackup(backupId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Backup deleted'),
            backgroundColor: context.colorTokens.success,
          ),
        );
        
        setState(() {}); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: context.colorTokens.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}