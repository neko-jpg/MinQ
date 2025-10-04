import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart' as p;

/// Generates an encrypted differential backup between [source] and [previous].
///
/// Usage:
/// ```
/// dart run tool/backup/diff_backup.dart \
///   --source data/current \
///   --previous data/previous \
///   --output backups/backup.zip.enc \
///   --password secret
/// ```
Future<void> main(List<String> arguments) async {
  final args = _Arguments.parse(arguments);
  final sourceSnapshot = await _Snapshot.fromDirectory(args.source);
  final previousSnapshot = args.previous != null
      ? await _Snapshot.fromDirectory(args.previous!)
      : _Snapshot.empty();

  final diff = sourceSnapshot.diff(previousSnapshot);
  final archive = Archive()
    ..addFile(ArchiveFile.string('diff.json', jsonEncode(diff.toJson())));

  for (final entry in diff.changedEntries) {
    final file = File(p.join(args.source, entry.relativePath));
    if (!await file.exists()) {
      continue;
    }
    final bytes = await file.readAsBytes();
    archive.addFile(ArchiveFile(entry.relativePath, bytes.length, bytes));
  }

  final encoded = ZipEncoder().encode(archive);
  final encrypted = _encrypt(encoded, args.password);
  final outputFile = File(args.output);
  await outputFile.create(recursive: true);
  await outputFile.writeAsBytes(encrypted);
  stdout.writeln(
    'Encrypted differential backup created at ${outputFile.path} '
    '(${encrypted.length} bytes).',
  );
}

class _Arguments {
  _Arguments({
    required this.source,
    required this.output,
    this.previous,
    required this.password,
  });

  final String source;
  final String? previous;
  final String output;
  final String password;

  static _Arguments parse(List<String> args) {
    final map = <String, String>{};
    for (var i = 0; i < args.length; i += 2) {
      if (i + 1 >= args.length) {
        throw ArgumentError('Missing value for ${args[i]}');
      }
      map[args[i]] = args[i + 1];
    }

    if (!map.containsKey('--source') || !map.containsKey('--output')) {
      throw ArgumentError('--source and --output are required');
    }

    final password = map['--password'] ??
        Platform.environment['MINQ_BACKUP_PASSWORD'] ??
        (throw ArgumentError('Missing --password or MINQ_BACKUP_PASSWORD env'));

    return _Arguments(
      source: map['--source']!,
      previous: map['--previous'],
      output: map['--output']!,
      password: password,
    );
  }
}

class _Snapshot {
  _Snapshot(this.entries);

  final Map<String, _SnapshotEntry> entries;

  factory _Snapshot.empty() => _Snapshot({});

  static Future<_Snapshot> fromDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      throw ArgumentError('Directory $path does not exist');
    }

    final entries = <String, _SnapshotEntry>{};
    await for (final entity in dir.list(recursive: true)) {
      if (entity is! File) continue;
      final relativePath = p.relative(entity.path, from: path);
      if (relativePath.startsWith('.')) continue;
      final bytes = await entity.readAsBytes();
      final digest = sha256.convert(bytes).toString();
      entries[relativePath] = _SnapshotEntry(
        relativePath: relativePath,
        hash: digest,
      );
    }
    return _Snapshot(entries);
  }

  _SnapshotDiff diff(_Snapshot previous) {
    final added = <_SnapshotEntry>[];
    final modified = <_SnapshotEntry>[];
    final removed = <_SnapshotEntry>[];

    for (final entry in entries.values) {
      final previousEntry = previous.entries[entry.relativePath];
      if (previousEntry == null) {
        added.add(entry);
      } else if (previousEntry.hash != entry.hash) {
        modified.add(entry);
      }
    }

    for (final entry in previous.entries.values) {
      if (!entries.containsKey(entry.relativePath)) {
        removed.add(entry);
      }
    }

    return _SnapshotDiff(
      addedEntries: added,
      modifiedEntries: modified,
      removedEntries: removed,
    );
  }
}

class _SnapshotEntry {
  _SnapshotEntry({
    required this.relativePath,
    required this.hash,
  });

  final String relativePath;
  final String hash;

  Map<String, Object?> toJson() => {
        'relativePath': relativePath,
        'hash': hash,
      };
}

class _SnapshotDiff {
  _SnapshotDiff({
    required this.addedEntries,
    required this.modifiedEntries,
    required this.removedEntries,
  });

  final List<_SnapshotEntry> addedEntries;
  final List<_SnapshotEntry> modifiedEntries;
  final List<_SnapshotEntry> removedEntries;

  Iterable<_SnapshotEntry> get changedEntries =>
      [...addedEntries, ...modifiedEntries];

  Map<String, Object?> toJson() => {
        'added': addedEntries.map((e) => e.toJson()).toList(),
        'modified': modifiedEntries.map((e) => e.toJson()).toList(),
        'removed': removedEntries.map((e) => e.toJson()).toList(),
      };
}

List<int> _encrypt(List<int> data, String password) {
  final digest = sha256.convert(utf8.encode(password)).bytes;
  final key = encrypt.Key(Uint8List.fromList(digest));
  final iv = encrypt.IV.fromSecureRandom(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  final encrypted = encrypter.encryptBytes(data, iv: iv);

  return <int>[...iv.bytes, ...encrypted.bytes];
}
