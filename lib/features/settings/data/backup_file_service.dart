import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class BackupFileService {
  const BackupFileService();

  static const _channel = MethodChannel('qdone/files');

  bool get supportsSystemFileDialogs => Platform.isAndroid;

  Future<String?> pickBackupJson() async {
    if (!supportsSystemFileDialogs) {
      return null;
    }
    return _channel.invokeMethod<String>('importBackup');
  }

  Future<String?> importBackupJson() => pickBackupJson();

  Future<String> exportBackupJson(String content, {DateTime? now}) async {
    final fileName = _backupFileName(now ?? DateTime.now());
    final localPath = await saveBackupJson(content, fileName: fileName);
    if (supportsSystemFileDialogs) {
      try {
        final saved =
            await _channel.invokeMethod<bool>('exportBackup', <String, Object>{
              'fileName': fileName,
              'content': content,
            }) ??
            false;
        if (saved) {
          return '$fileName; копия в приложении: $localPath';
        }
      } catch (_) {
        // The local file above is the reliable export path; SAF is best effort.
      }
    }
    return localPath;
  }

  Future<String> saveBackupJson(String content, {String? fileName}) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}qdone_exports',
    );
    await exportDirectory.create(recursive: true);
    final file = File(
      '${exportDirectory.path}${Platform.pathSeparator}'
      '${fileName ?? _backupFileName(DateTime.now())}',
    );
    await file.writeAsString(content);
    return file.path;
  }

  Future<String?> readLatestLocalBackupJson() async {
    final latest = await latestLocalBackupPath();
    if (latest == null) {
      return null;
    }
    return File(latest).readAsString();
  }

  Future<String?> latestLocalBackupPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}qdone_exports',
    );
    if (!await exportDirectory.exists()) {
      return null;
    }
    final files = await exportDirectory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .cast<File>()
        .toList();
    if (files.isEmpty) {
      return null;
    }
    files.sort((a, b) {
      final aModified = a.lastModifiedSync();
      final bModified = b.lastModifiedSync();
      return bModified.compareTo(aModified);
    });
    return files.first.path;
  }

  String _backupFileName(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return 'qdone-backup-'
        '${value.year}${two(value.month)}${two(value.day)}-'
        '${two(value.hour)}${two(value.minute)}${two(value.second)}.json';
  }
}
