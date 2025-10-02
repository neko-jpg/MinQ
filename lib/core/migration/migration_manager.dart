import 'package:cloud_firestore/cloud_firestore.dart';

/// データモデルのバージョン
class ModelVersion {
  static const int current = 3;

  // バージョン履歴
  static const int v1 = 1; // 初期バージョン
  static const int v2 = 2; // questにcategoryフィールド追加
  static const int v3 = 3; // userにpreferencesフィールド追加
}

/// マイグレーション基底クラス
abstract class Migration {
  int get fromVersion;
  int get toVersion;

  Future<void> migrate(FirebaseFirestore firestore);

  String get description;
}

/// V1→V2: questにcategoryフィールド追加
class MigrationV1ToV2 implements Migration {
  @override
  int get fromVersion => 1;

  @override
  int get toVersion => 2;

  @override
  String get description => 'Add category field to quests';

  @override
  Future<void> migrate(FirebaseFirestore firestore) async {
    print('🔄 Migrating from v$fromVersion to v$toVersion: $description');

    final questsSnapshot = await firestore.collection('quests').get();

    final batch = firestore.batch();
    int count = 0;

    for (final doc in questsSnapshot.docs) {
      final data = doc.data();

      // categoryフィールドがない場合のみ追加
      if (!data.containsKey('category')) {
        batch.update(doc.reference, {
          'category': 'general',
          'modelVersion': toVersion,
        });
        count++;
      }
    }

    if (count > 0) {
      await batch.commit();
      print('✅ Migrated $count quests');
    } else {
      print('ℹ️ No quests to migrate');
    }
  }
}

/// V2→V3: userにpreferencesフィールド追加
class MigrationV2ToV3 implements Migration {
  @override
  int get fromVersion => 2;

  @override
  int get toVersion => 3;

  @override
  String get description => 'Add preferences field to users';

  @override
  Future<void> migrate(FirebaseFirestore firestore) async {
    print('🔄 Migrating from v$fromVersion to v$toVersion: $description');

    final usersSnapshot = await firestore.collection('users').get();

    final batch = firestore.batch();
    int count = 0;

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();

      // preferencesフィールドがない場合のみ追加
      if (!data.containsKey('preferences')) {
        batch.update(doc.reference, {
          'preferences': {
            'theme': 'system',
            'language': 'ja',
            'notifications': true,
          },
          'modelVersion': toVersion,
        });
        count++;
      }
    }

    if (count > 0) {
      await batch.commit();
      print('✅ Migrated $count users');
    } else {
      print('ℹ️ No users to migrate');
    }
  }
}

/// マイグレーションマネージャー
class MigrationManager {
  final FirebaseFirestore _firestore;
  final List<Migration> _migrations;

  MigrationManager({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _migrations = [
          MigrationV1ToV2(),
          MigrationV2ToV3(),
        ];

  /// 必要なマイグレーションを実行
  Future<void> runMigrations({
    required int currentVersion,
    required int targetVersion,
  }) async {
    if (currentVersion >= targetVersion) {
      print('ℹ️ No migrations needed (current: $currentVersion, target: $targetVersion)');
      return;
    }

    print('🚀 Starting migrations from v$currentVersion to v$targetVersion');

    // 必要なマイグレーションを抽出
    final requiredMigrations = _migrations.where((migration) {
      return migration.fromVersion >= currentVersion &&
          migration.toVersion <= targetVersion;
    }).toList();

    // バージョン順にソート
    requiredMigrations.sort((a, b) => a.fromVersion.compareTo(b.fromVersion));

    // マイグレーションを順次実行
    for (final migration in requiredMigrations) {
      try {
        await migration.migrate(_firestore);
      } catch (e) {
        print('❌ Migration failed: ${migration.description}');
        print('Error: $e');
        rethrow;
      }
    }

    // マイグレーション情報を記録
    await _recordMigration(currentVersion, targetVersion);

    print('✅ All migrations completed successfully');
  }

  /// マイグレーション情報を記録
  Future<void> _recordMigration(int from, int to) async {
    await _firestore.collection('_migrations').add({
      'fromVersion': from,
      'toVersion': to,
      'migratedAt': FieldValue.serverTimestamp(),
      'success': true,
    });
  }

  /// 現在のデータベースバージョンを取得
  Future<int> getCurrentDatabaseVersion() async {
    try {
      final snapshot = await _firestore
          .collection('_migrations')
          .orderBy('migratedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 1; // 初期バージョン
      }

      return snapshot.docs.first.data()['toVersion'] as int;
    } catch (e) {
      print('⚠️ Failed to get database version: $e');
      return 1;
    }
  }

  /// ユーザーデータのバージョンを取得
  Future<int> getUserDataVersion(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return 1;
      }

      return doc.data()?['modelVersion'] as int? ?? 1;
    } catch (e) {
      print('⚠️ Failed to get user data version: $e');
      return 1;
    }
  }

  /// ユーザーデータをマイグレート
  Future<void> migrateUserData(String userId) async {
    final currentVersion = await getUserDataVersion(userId);
    final targetVersion = ModelVersion.current;

    if (currentVersion < targetVersion) {
      print('🔄 Migrating user data from v$currentVersion to v$targetVersion');
      await runMigrations(
        currentVersion: currentVersion,
        targetVersion: targetVersion,
      );
    }
  }

  /// 全ユーザーデータをマイグレート（管理者用）
  Future<void> migrateAllUserData() async {
    print('🚀 Starting migration for all users');

    final usersSnapshot = await _firestore.collection('users').get();

    for (final doc in usersSnapshot.docs) {
      try {
        await migrateUserData(doc.id);
      } catch (e) {
        print('❌ Failed to migrate user ${doc.id}: $e');
      }
    }

    print('✅ All user data migrated');
  }

  /// マイグレーション履歴を取得
  Future<List<Map<String, dynamic>>> getMigrationHistory() async {
    final snapshot = await _firestore
        .collection('_migrations')
        .orderBy('migratedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// ロールバック（注意: データ損失の可能性あり）
  Future<void> rollback(int targetVersion) async {
    print('⚠️ Rolling back to version $targetVersion');
    print('⚠️ This operation may cause data loss!');

    // ロールバックロジックは慎重に実装する必要がある
    // 通常は手動でのデータ復元を推奨

    throw UnimplementedError('Rollback is not implemented for safety reasons');
  }
}

/// データモデルのバージョン管理ミックスイン
mixin VersionedModel {
  int get modelVersion;

  /// モデルが最新バージョンかどうか
  bool get isLatestVersion => modelVersion == ModelVersion.current;

  /// マイグレーションが必要かどうか
  bool get needsMigration => modelVersion < ModelVersion.current;

  /// バージョン情報をMapに追加
  Map<String, dynamic> withVersion(Map<String, dynamic> data) {
    return {
      ...data,
      'modelVersion': ModelVersion.current,
    };
  }
}

/// マイグレーション状態
enum MigrationStatus {
  /// マイグレーション不要
  upToDate,

  /// マイグレーション必要
  needsMigration,

  /// マイグレーション中
  migrating,

  /// マイグレーション失敗
  failed,
}

/// マイグレーション状態プロバイダー
class MigrationStatusProvider {
  final MigrationManager _manager;
  MigrationStatus _status = MigrationStatus.upToDate;

  MigrationStatusProvider(this._manager);

  MigrationStatus get status => _status;

  /// マイグレーション状態をチェック
  Future<MigrationStatus> checkStatus() async {
    try {
      final currentVersion = await _manager.getCurrentDatabaseVersion();
      final targetVersion = ModelVersion.current;

      if (currentVersion < targetVersion) {
        _status = MigrationStatus.needsMigration;
      } else {
        _status = MigrationStatus.upToDate;
      }

      return _status;
    } catch (e) {
      _status = MigrationStatus.failed;
      return _status;
    }
  }

  /// 自動マイグレーションを実行
  Future<void> autoMigrate() async {
    if (_status != MigrationStatus.needsMigration) {
      return;
    }

    _status = MigrationStatus.migrating;

    try {
      final currentVersion = await _manager.getCurrentDatabaseVersion();
      await _manager.runMigrations(
        currentVersion: currentVersion,
        targetVersion: ModelVersion.current,
      );

      _status = MigrationStatus.upToDate;
    } catch (e) {
      _status = MigrationStatus.failed;
      rethrow;
    }
  }
}

/// マイグレーションヘルパー
class MigrationHelper {
  const MigrationHelper._();

  /// フィールドの追加
  static Map<String, dynamic> addField(
    Map<String, dynamic> data,
    String fieldName,
    dynamic defaultValue,
  ) {
    if (!data.containsKey(fieldName)) {
      data[fieldName] = defaultValue;
    }
    return data;
  }

  /// フィールドの削除
  static Map<String, dynamic> removeField(
    Map<String, dynamic> data,
    String fieldName,
  ) {
    data.remove(fieldName);
    return data;
  }

  /// フィールドのリネーム
  static Map<String, dynamic> renameField(
    Map<String, dynamic> data,
    String oldName,
    String newName,
  ) {
    if (data.containsKey(oldName)) {
      data[newName] = data[oldName];
      data.remove(oldName);
    }
    return data;
  }

  /// フィールドの型変換
  static Map<String, dynamic> convertFieldType(
    Map<String, dynamic> data,
    String fieldName,
    dynamic Function(dynamic) converter,
  ) {
    if (data.containsKey(fieldName)) {
      data[fieldName] = converter(data[fieldName]);
    }
    return data;
  }

  /// ネストされたフィールドの追加
  static Map<String, dynamic> addNestedField(
    Map<String, dynamic> data,
    List<String> path,
    dynamic defaultValue,
  ) {
    Map<String, dynamic> current = data;

    for (int i = 0; i < path.length - 1; i++) {
      final key = path[i];
      if (!current.containsKey(key) || current[key] is! Map) {
        current[key] = <String, dynamic>{};
      }
      current = current[key] as Map<String, dynamic>;
    }

    final lastKey = path.last;
    if (!current.containsKey(lastKey)) {
      current[lastKey] = defaultValue;
    }

    return data;
  }
}
