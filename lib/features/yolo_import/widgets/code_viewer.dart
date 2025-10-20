import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeViewer extends StatelessWidget {
  const CodeViewer({
    super.key,
    required this.title,
    required this.code,
  });

  final String title;
  final String code;

  // Função auxiliar para copiar texto para a área de transferência.
  void _copyToClipboard(BuildContext context, String text) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Copiado!'), 
        duration: Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), 
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12), 
            decoration: BoxDecoration(
              color: Colors.grey[200], 
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(children: [
              Expanded(
                child: SelectableText(code, style: const TextStyle(fontFamily: 'monospace'))
              ),
              const SizedBox(width: 8),
              InkWell(
                child: const Icon(Icons.copy, size: 18, color: Colors.black54), 
                onTap: () => _copyToClipboard(context, code)
              )
            ]),
          ),
        ]
      ),
    );
  }
}