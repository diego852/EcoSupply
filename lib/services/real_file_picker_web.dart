import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

import 'real_file_picker.dart';

/// Implementación para Flutter Web (Vercel, Chrome, Edge, Safari):
/// Abre la ventana nativa de selección de archivos del sistema operativo a través del navegador web.
Future<List<PickedRealFile>> pickFilesPlatformImplementation({
  required List<String> allowedExtensions,
  required bool isPdfOnly,
}) async {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.multiple = true;
  // Filtro estricto del explorador del sistema: Si es PDF -> '.pdf', si es Imagen -> '.jpg,.jpeg,.png'
  uploadInput.accept = isPdfOnly ? '.pdf' : '.jpg,.jpeg,.png';

  uploadInput.click();

  await uploadInput.onChange.first;
  final files = uploadInput.files;
  if (files == null || files.isEmpty) return [];

  final result = <PickedRealFile>[];

  for (final file in files) {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoadEnd.first;

    final bytes = reader.result as Uint8List?;
    final fileName = file.name;
    final extension = fileName.contains('.') ? fileName.split('.').last : '';

    result.add(PickedRealFile(
      name: fileName,
      size: file.size,
      bytes: bytes,
      extension: extension,
      path: null,
    ));
  }

  return result;
}
