import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableCard extends StatelessWidget {
  const CopyableCard({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;
  
  void _copyToClipboard(BuildContext context, String text) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Copiado!'), 
        duration: Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8), 
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        subtitle: Text(
          value, 
          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500)
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy), 
          tooltip: 'Copiar', 
          onPressed: () => _copyToClipboard(context, value)
        ),
    ));
  }
}