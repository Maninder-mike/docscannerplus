import 'package:flutter/material.dart';

class MergeDialog extends StatefulWidget {
  final String initialName;

  const MergeDialog({super.key, this.initialName = 'Merged Document'});

  @override
  State<MergeDialog> createState() => _MergeDialogState();
}

class _MergeDialogState extends State<MergeDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Merge Documents'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Document Name',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Merge'),
        ),
      ],
    );
  }
}
