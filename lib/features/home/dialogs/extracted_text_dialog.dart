import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExtractedTextDialog extends StatelessWidget {
  final String text;

  const ExtractedTextDialog({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Extracted Text'),
      content: SingleChildScrollView(child: SelectableText(text)),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard')),
            );
          },
          child: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
