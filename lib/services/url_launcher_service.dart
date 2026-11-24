import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'url_launcher_stub.dart'
    if (dart.library.html) 'url_launcher_web.dart'
    if (dart.library.io) 'url_launcher_mobile.dart';

/// Abre la URL de la consulta CSE del SISFOH en un navegador externo.
Future<void> openExternalSisfohUrl(BuildContext context) async {
  const sisfohUrl = 'https://focalizacion.sisfoh.gob.pe/ConsultaCSE/';

  try {
    final success = await launchExternalUrlPlatformImplementation(sisfohUrl);
    if (!success) {
      if (context.mounted) {
        _showFallbackClipboardSnackBar(context, sisfohUrl);
      }
    }
  } catch (e) {
    if (context.mounted) {
      _showFallbackClipboardSnackBar(context, sisfohUrl);
    }
  }
}

void _showFallbackClipboardSnackBar(BuildContext context, String url) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('No se pudo abrir el enlace. Cópialo y ábrelo en tu navegador.'),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: 'Copiar enlace',
        textColor: Colors.amber,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: url));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enlace copiado al portapapeles.')),
          );
        },
      ),
    ),
  );
}
