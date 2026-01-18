import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';

class AddSignaturePage extends StatefulWidget {
  final List<String> imagePaths;
  final Uint8List signatureImage;

  const AddSignaturePage({
    super.key,
    required this.imagePaths,
    required this.signatureImage,
  });

  @override
  State<AddSignaturePage> createState() => _AddSignaturePageState();
}

class _AddSignaturePageState extends State<AddSignaturePage> {
  late PageController _pageController;
  int _currentPage = 0;

  // Signature State
  Offset _position = const Offset(100, 100);
  double _scale = 1.0;
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updatePosition(Offset delta) {
    setState(() {
      _position += delta;
    });
  }

  Future<void> _applyToPage() async {
    setState(() => _isSaving = true);
    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0); // Higher quality
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return;

      final buffer = byteData.buffer.asUint8List();
      final currentPath = widget.imagePaths[_currentPage];

      // Overwrite the image file
      final file = File(currentPath);
      await file.writeAsBytes(buffer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signature applied to page')),
        );
      }
    } catch (e) {
      debugPrint('Error applying signature: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _finish() {
    Navigator.pop(context, true); // True means changes were made
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Signature'),
        actions: [TextButton(onPressed: _finish, child: const Text('Done'))],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imagePaths.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return Center(
                  child: RepaintBoundary(
                    key: index == _currentPage ? _repaintKey : null,
                    child: Stack(
                      children: [
                        Image.file(
                          File(widget.imagePaths[index]),
                          fit: BoxFit.contain,
                        ),
                        if (index == _currentPage)
                          Positioned(
                            left: _position.dx,
                            top: _position.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) =>
                                  _updatePosition(details.delta),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Image.memory(
                                  widget.signatureImage,
                                  width: 200 * _scale,
                                  fit: BoxFit.contain,
                                  color: Colors.black, // Ensure black signature
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Size'),
                    Expanded(
                      child: Slider(
                        value: _scale,
                        min: 0.2,
                        max: 3.0,
                        onChanged: (v) => setState(() => _scale = v),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _currentPage > 0
                          ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                          : null,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Text('${_currentPage + 1} / ${widget.imagePaths.length}'),
                    IconButton(
                      onPressed: _currentPage < widget.imagePaths.length - 1
                          ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
                const Gap(8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _applyToPage,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Apply Signature to Page'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
