// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';
import 'download_service.dart';

// Esta é a implementação REAL do serviço para a plataforma WEB.
class DownloadService implements DownloadServiceBase {
  @override
  Future<void> downloadFile({
    required Uint8List bytes,
    required String downloadName,
    String? mimeType,
  }) async {
    // Este código usa 'dart:html' e só funciona em um navegador.
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = downloadName;
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}