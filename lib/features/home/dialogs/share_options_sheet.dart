import 'package:flutter/material.dart';

class ShareOptionsSheet extends StatelessWidget {
  final VoidCallback onSharePdf;
  final VoidCallback onShareText;
  final bool hasTextContent;

  const ShareOptionsSheet({
    super.key,
    required this.onSharePdf,
    required this.onShareText,
    required this.hasTextContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Export As', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('PDF Document'),
            subtitle: const Text('Best for printing and sharing'),
            onTap: () {
              Navigator.pop(context);
              onSharePdf();
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Text (TXT)'),
            subtitle: const Text('Best for editing content'),
            enabled: hasTextContent,
            onTap: () {
              Navigator.pop(context);
              onShareText();
            },
          ),
        ],
      ),
    );
  }
}
