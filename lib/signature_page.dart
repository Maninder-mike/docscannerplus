import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final HandSignatureControl _control = HandSignatureControl();

  bool _hasSignature = false;

  void _clear() {
    _control.clear();
    setState(() => _hasSignature = false);
  }

  Future<void> _save() async {
    // control.toImage returns ByteData directly with default PNG format
    final buffer = await _control.toImage(
      color: Colors.black,
      background: Colors.transparent,
      fit: true,
      format: ui.ImageByteFormat.png,
    );

    if (buffer != null) {
      if (mounted) {
        Navigator.pop(context, buffer.buffer.asUint8List());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Signature'),
        actions: [
          IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear',
          ),
          IconButton(
            onPressed: _hasSignature ? _save : null,
            icon: const Icon(Icons.check),
            tooltip: 'Save',
          ),
        ],
      ),
      backgroundColor: Colors.white, // White canvas
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  HandSignature(
                    control: _control,
                    onPointerDown: () => setState(() => _hasSignature = true),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: Text(
                        'Sign above',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
