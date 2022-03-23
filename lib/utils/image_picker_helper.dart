import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ImagePickerHelper {
  File? file;
  XFile? xfile;

  bool isEmpty() {
    return xfile == null;
  }

  add(File _file) {
    this.file = _file;
  }

  addXFile(XFile _xfile) {
    this.xfile = _xfile;
    if (this.xfile != null) {
      this.file = File(this.xfile!.path);
    }
  }

  Future<String?> uploadToStorage(String dirname, [String? filename]) async {
    if (this.xfile == null) {
      return null;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    String _filename = filename == null ? "$now-${this.xfile!.name}" : filename;

    final ref = firebase_storage.FirebaseStorage.instance.ref().child(dirname);
    final uploadTask = await ref.child(_filename).putData(
          await this.xfile!.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );

    return await uploadTask.ref.getDownloadURL();
  }

  render({
    double? width,
    double? height,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
  }) {
    if (this.file == null) return SizedBox();

    if (kIsWeb)
      return Image.network(
        this.file!.path,
        width: width,
        height: height,
        opacity: opacity,
        fit: fit,
      );

    return Image.file(
      this.file!,
      width: width,
      height: height,
      opacity: opacity,
      fit: fit,
    );
  }
}
