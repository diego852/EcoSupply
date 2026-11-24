import 'dart:async';
import 'dart:html' as html;

/// Abre la URL en una nueva pestaña del navegador en Flutter Web (Vercel)
Future<bool> launchExternalUrlPlatformImplementation(String url) async {
  try {
    html.window.open(url, '_blank');
    return true;
  } catch (e) {
    return false;
  }
}
