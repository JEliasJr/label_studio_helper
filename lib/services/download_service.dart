import 'dart:typed_data';

// Esta é a mágica! Ele exporta o 'download_service_stub.dart' por padrão.
// MAS, se o compilador detectar que estamos no ambiente web (onde 'dart.library.html' existe),
// ele ignora o primeiro e exporta 'download_service_web.dart' em vez disso.
export 'download_service_stub.dart' if (dart.library.html) 'download_service_web.dart';

// Esta é uma "interface" ou "contrato". Ela garante que ambas as nossas implementações
// (web e stub) tenham exatamente o mesmo método 'downloadFile'.
abstract class DownloadServiceBase {
  Future<void> downloadFile({
    required Uint8List bytes,
    required String downloadName,
    String? mimeType,
  });
}