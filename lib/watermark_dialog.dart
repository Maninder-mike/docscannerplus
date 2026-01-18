import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:docscannerplus/models/watermark_options.dart';

class WatermarkDialog extends StatefulWidget {
  const WatermarkDialog({super.key});

  @override
  State<WatermarkDialog> createState() => _WatermarkDialogState();
}

class _WatermarkDialogState extends State<WatermarkDialog> {
  final TextEditingController _textController = TextEditingController(
    text: 'CONFIDENTIAL',
  );
  double _opacity = 0.3;
  double _size = 40.0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Watermark'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Watermark Text',
              border: OutlineInputBorder(),
            ),
          ),
          const Gap(16),
          Row(
            children: [
              const Text('Opacity'),
              Expanded(
                child: Slider(
                  value: _opacity,
                  min: 0.1,
                  max: 1.0,
                  onChanged: (v) => setState(() => _opacity = v),
                ),
              ),
              Text(_opacity.toStringAsFixed(1)),
            ],
          ),
          Row(
            children: [
              const Text('Size'),
              Expanded(
                child: Slider(
                  value: _size,
                  min: 10,
                  max: 100,
                  onChanged: (v) => setState(() => _size = v),
                ),
              ),
              Text(_size.toInt().toString()),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_textController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              WatermarkOptions(
                text: _textController.text.trim(),
                opacity: _opacity,
                size: _size,
              ),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
