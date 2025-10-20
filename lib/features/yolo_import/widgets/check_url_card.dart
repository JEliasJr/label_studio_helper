import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckUrlCard extends StatelessWidget {
  const CheckUrlCard({super.key, required this.baseUrl});

  final String baseUrl;

  // Função para copiar o texto para a área de transferência
  void _copyToClipboard(BuildContext context, String text) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('URL base copiada!'), 
        duration: Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8), 
      child: ListTile(
        // CORREÇÃO: Simplificamos o RichText para um Text, exibindo apenas a baseUrl.
        title: Text(
          baseUrl, 
          style: const TextStyle(
            fontSize: 14, 
            color: Colors.black87, 
            fontFamily: 'monospace',
          ),
          // Adicionado para evitar que a URL quebre a linha se for muito longa.
          overflow: TextOverflow.ellipsis, 
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy), 
          tooltip: 'Copiar URL base', 
          // A função de copiar continua funcionando corretamente.
          onPressed: () => _copyToClipboard(context, baseUrl),
        ),
    ));
  }
}