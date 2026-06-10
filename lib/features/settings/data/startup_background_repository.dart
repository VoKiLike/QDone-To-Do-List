import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class StartupBackgroundRepository {
  StartupBackgroundRepository({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  static const _directoryName = 'startup_backgrounds';

  final ImagePicker _picker;

  Future<String?> pickAndStoreBackground() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 2200,
    );
    if (image == null) {
      return null;
    }
    return _copyToPermanentStorage(image.path);
  }

  Future<String?> recoverLostBackground() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty || response.file == null) {
      return null;
    }
    return _copyToPermanentStorage(response.file!.path);
  }

  Future<void> deleteBackground(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<String>> listBackgrounds() async {
    final directory = await _backgroundDirectory();
    if (!await directory.exists()) {
      return const <String>[];
    }
    final files = await directory
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files.map((file) => file.path).toList();
  }

  Future<String> _copyToPermanentStorage(String sourcePath) async {
    final source = File(sourcePath);
    final directory = await _backgroundDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final extension = _extensionFor(source.path);
    final target = File(
      '${directory.path}${Platform.pathSeparator}'
      'qdone-startup-${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    await source.copy(target.path);
    return target.path;
  }

  Future<Directory> _backgroundDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory(
      '${documents.path}${Platform.pathSeparator}$_directoryName',
    );
  }

  String _extensionFor(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) {
      return '.jpg';
    }
    final extension = path.substring(dot).toLowerCase();
    return extension.length > 8 ? '.jpg' : extension;
  }
}
