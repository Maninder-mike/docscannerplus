import 'dart:io';

import 'package:docscannerplus/services/image_filter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

/// Page displayed after scanning to allow filter selection.
class FilterPreviewPage extends StatefulWidget {
  final String imagePath;
  final String? pdfPath;

  const FilterPreviewPage({super.key, required this.imagePath, this.pdfPath});

  @override
  State<FilterPreviewPage> createState() => _FilterPreviewPageState();
}

class _FilterPreviewPageState extends State<FilterPreviewPage> {
  final _filterService = ImageFilterService();
  ImageFilterType _selectedFilter = ImageFilterType.original;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        title: const Text('Edit Scan'),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _saveDocument,
            child: _isProcessing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Text('Save', style: TextStyle(color: colorScheme.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image Preview
          Expanded(
            child: Center(
              child: ColorFiltered(
                colorFilter:
                    _filterService.getColorFilterForType(_selectedFilter) ??
                    const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
              ).animate().fadeIn(duration: 300.ms),
            ),
          ),

          // Filter Selection
          Container(
            color: colorScheme.surface,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _selectedFilter.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: ImageFilterType.values.length,
                      itemBuilder: (context, index) {
                        final filter = ImageFilterType.values[index];
                        return _buildFilterOption(filter, colorScheme);
                      },
                    ),
                  ),
                  const Gap(12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(ImageFilterType filter, ColorScheme colorScheme) {
    final isSelected = filter == _selectedFilter;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  width: isSelected ? 3 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ColorFiltered(
                colorFilter:
                    _filterService.getColorFilterForType(filter) ??
                    const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
              ),
            ),
            const Gap(6),
            Text(
              filter.displayName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (50 * ImageFilterType.values.indexOf(filter)).ms);
  }

  Future<void> _saveDocument() async {
    setState(() => _isProcessing = true);

    try {
      // Return the selected filter type
      Navigator.pop(context, _selectedFilter);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
