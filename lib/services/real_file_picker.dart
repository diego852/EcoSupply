import 'dart:async';
import 'package:flutter/foundation.dart';

// Importación condicional para Web y Plataformas Nativas
import 'real_file_picker_stub.dart'
    if (dart.library.html) 'real_file_picker_web.dart'
    if (dart.library.io) 'real_file_picker_mobile.dart';

class PickedRealFile {
  final String name;
  final int size; // Tamaño en bytes
  final Uint8List? bytes;
  final String extension;
  final String? path;

  double get sizeMb => size / (1024 * 1024);
  bool get isPdf => extension.toLowerCase() == 'pdf';
  bool get isImage => ['jpg', 'jpeg', 'png'].contains(extension.toLowerCase());

  PickedRealFile({
    required this.name,
    required this.size,
    required this.bytes,
    required this.extension,
    this.path,
  });
}

class RealFilePickerResult {
  final List<PickedRealFile> files;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  RealFilePickerResult({
    required this.files,
    this.errorMessage,
  });
}

/// Abre el selector REAL del sistema operativo (Explorador de Windows, Galería/Archivos en Android/iOS o cuadro de diálogo del navegador en Web/Vercel).
Future<RealFilePickerResult> pickRealSystemFiles({
  required bool isPdfOnly,
  required int currentAttachedCount,
  int maxFilesAllowed = 3,
  int maxSizeBytes = 5 * 1024 * 1024, // 5 MB
}) async {
  try {
    // Si isPdfOnly == true -> solo PDF. Si isPdfOnly == false -> solo IMÁGENES (JPG, JPEG, PNG)
    final allowedExts = isPdfOnly ? ['pdf'] : ['jpg', 'jpeg', 'png'];

    final rawFiles = await pickFilesPlatformImplementation(
      allowedExtensions: allowedExts,
      isPdfOnly: isPdfOnly,
    );

    if (rawFiles.isEmpty) {
      return RealFilePickerResult(files: []);
    }

    // 1. Validar límite de 3 archivos en total
    if (currentAttachedCount + rawFiles.length > maxFilesAllowed) {
      return RealFilePickerResult(
        files: [],
        errorMessage: 'Límite excedido: Solo puedes adjuntar un máximo de $maxFilesAllowed archivos en total.',
      );
    }

    final validFiles = <PickedRealFile>[];

    for (final file in rawFiles) {
      final ext = file.extension.toLowerCase();

      // 2. Validar extensión exacta según la opción presionada
      if (!allowedExts.contains(ext)) {
        final expectedFormat = isPdfOnly ? 'PDF' : 'Imágenes (JPG, PNG)';
        return RealFilePickerResult(
          files: [],
          errorMessage: 'El archivo "$ext" no es un formato válido. Se requiere $expectedFormat.',
        );
      }

      // 3. Validar tamaño máximo de 5 MB por archivo
      if (file.size > maxSizeBytes) {
        return RealFilePickerResult(
          files: [],
          errorMessage: 'El archivo "${file.name}" supera el tamaño máximo permitido de 5 MB (${file.sizeMb.toStringAsFixed(1)} MB).',
        );
      }

      validFiles.add(file);
    }

    return RealFilePickerResult(files: validFiles);
  } catch (e) {
    return RealFilePickerResult(
      files: [],
      errorMessage: 'Error al abrir el explorador de archivos del sistema: $e',
    );
  }
}
