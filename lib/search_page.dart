import 'package:docscannerplus/models/document_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:open_filex/open_filex.dart';

class SearchPage extends StatefulWidget {
  final List<DocumentModel> documents;

  const SearchPage({super.key, required this.documents});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<DocumentModel> _filteredDocuments = [];

  final List<String> _allTags = [];
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _filteredDocuments = [];
    _extractTags();
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _extractTags() {
    final tags = <String>{};
    for (final doc in widget.documents) {
      if (doc.tags.isNotEmpty) {
        tags.addAll(doc.tags);
      }
    }
    setState(() {
      _allTags.clear();
      _allTags.addAll(tags.toList()..sort());
    });
  }

  void _onTagSelected(String tag) {
    setState(() {
      if (_selectedTag == tag) {
        _selectedTag = null;
      } else {
        _selectedTag = tag;
      }
    });
    // Re-run search
    _onSearchChanged(_searchController.text);
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredDocuments = []);
      return;
    }

    final lowerQuery = query.toLowerCase();
    final results = widget.documents.where((doc) {
      // Filter by tag if selected
      if (_selectedTag != null && !doc.tags.contains(_selectedTag)) {
        return false;
      }

      if (query.trim().isEmpty) return true;
      // Search in title
      if (doc.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      // Search in extracted text (OCR)
      if (doc.extractedText != null &&
          doc.extractedText!.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      return false;
    }).toList();

    setState(() => _filteredDocuments = results);
  }

  Future<void> _openDocument(DocumentModel doc) async {
    if (doc.filePath != null) {
      final result = await OpenFilex.open(doc.filePath!);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search documents...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.outline),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),

      body: Column(
        children: [
          if (_allTags.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _allTags.map((tag) {
                  final isSelected = _selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_) => _onTagSelected(tag),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: isSelected ? colorScheme.onPrimary : null,
                      ),
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(child: _buildBody(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_searchController.text.isEmpty) {
      return _buildEmptySearch(colorScheme);
    }

    if (_filteredDocuments.isEmpty) {
      return _buildNoResults(colorScheme);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final doc = _filteredDocuments[index];
        return _buildResultCard(doc, colorScheme, index);
      },
    );
  }

  Widget _buildEmptySearch(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          const Gap(16),
          Text(
            'Search by title or content',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildNoResults(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          const Gap(16),
          Text(
            'No documents found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.outline),
          ),
          const Gap(8),
          Text(
            'Try a different search term',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildResultCard(
    DocumentModel doc,
    ColorScheme colorScheme,
    int index,
  ) {
    // Determine where the match was found
    final query = _searchController.text.toLowerCase();
    final matchInTitle = doc.title.toLowerCase().contains(query);
    final matchInContent =
        doc.extractedText?.toLowerCase().contains(query) ?? false;

    return Card(
          elevation: 0,
          color: colorScheme.surfaceContainer,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _openDocument(doc),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHighlightedText(
                              doc.title,
                              query,
                              Theme.of(context).textTheme.titleMedium!,
                              colorScheme,
                            ),
                            const Gap(2),
                            Text(
                              doc.formattedDate,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colorScheme.outline),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colorScheme.outline),
                    ],
                  ),
                  // Show content snippet if match was in content
                  if (matchInContent &&
                      !matchInTitle &&
                      doc.extractedText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildContentSnippet(
                          doc.extractedText!,
                          query,
                          colorScheme,
                        ),
                      ),
                    ),
                  // Show match location badge
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (matchInTitle)
                          _buildMatchBadge('Title', colorScheme),
                        if (matchInContent)
                          _buildMatchBadge('Content', colorScheme),
                        ...doc.tags.map((t) => _buildTagBadge(t, colorScheme)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }

  Widget _buildMatchBadge(String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle baseStyle,
    ColorScheme colorScheme,
  ) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text, style: baseStyle);
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, index), style: baseStyle),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: baseStyle.copyWith(
              backgroundColor: colorScheme.primaryContainer,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          TextSpan(
            text: text.substring(index + query.length),
            style: baseStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildContentSnippet(
    String content,
    String query,
    ColorScheme colorScheme,
  ) {
    final lowerContent = content.toLowerCase();
    final index = lowerContent.indexOf(query.toLowerCase());

    if (index == -1) {
      return Text(
        content.substring(0, content.length.clamp(0, 100)),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Get a snippet around the match
    final start = (index - 30).clamp(0, content.length);
    final end = (index + query.length + 50).clamp(0, content.length);
    final snippet =
        (start > 0 ? '...' : '') +
        content.substring(start, end) +
        (end < content.length ? '...' : '');

    return _buildHighlightedText(
      snippet,
      query,
      Theme.of(
        context,
      ).textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant),
      colorScheme,
    );
  }

  Widget _buildTagBadge(String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '#$label',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
