import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class ReorderPagesPage extends StatefulWidget {
  final List<String> imagePaths;

  const ReorderPagesPage({super.key, required this.imagePaths});

  @override
  State<ReorderPagesPage> createState() => _ReorderPagesPageState();
}

class _ReorderPagesPageState extends State<ReorderPagesPage> {
  late List<String> _currentPaths;

  @override
  void initState() {
    super.initState();
    _currentPaths = List.from(widget.imagePaths);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = _currentPaths.removeAt(oldIndex);
      _currentPaths.insert(newIndex, item);
    });
  }

  void _save() {
    Navigator.pop(context, _currentPaths);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder Pages'),
        actions: [TextButton(onPressed: _save, child: const Text('Is Done'))],
      ),
      body: _currentPaths.isEmpty
          ? const Center(child: Text('No pages found'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentPaths.length,
              onReorder: _onReorder,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) {
                    return Material(
                      elevation: 8,
                      color: Colors.transparent,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final path = _currentPaths[index];
                return Card(
                  key: ValueKey(path),
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Page Number
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Gap(16),
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(path),
                            width: 60,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Gap(16),
                        // Drag Handle Warning/Icon
                        Expanded(
                          child: Text(
                            'Page ${index + 1}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Icon(
                          Icons.drag_handle,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const Gap(8),
                      ],
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0);
              },
            ),
    );
  }
}
