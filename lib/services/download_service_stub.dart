import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'download_service.dart';

// Esta é a implementação REAL do serviço para TODAS as outras plataformas.
class DownloadService implements DownloadServiceBase {
  @override
  Future<void> downloadFile({
    required Uint8List bytes,
    required String downloadName,
    String? mimeType,
  }) async {
    // Este código usa o pacote 'file_saver' e funciona no Windows, Linux, Android, etc.
    final extension = downloadName.split('.').last;
    await FileSaver.instance.saveFile(
      name: downloadName.replaceAll('.$extension', ''), // Nome do arquivo sem extensão
      bytes: bytes,
      ext: extension, // A extensão do arquivo
      mimeType: mimeType != null ? MimeType.custom : MimeType.text,
    );
  }
}