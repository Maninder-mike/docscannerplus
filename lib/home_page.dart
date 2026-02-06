import 'package:docscannerplus/features/home/logic/home_actions.dart';
import 'package:docscannerplus/features/home/widgets/home_app_bar.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/providers/selection_provider.dart';

import 'package:docscannerplus/widgets/document_list.dart';
import 'package:docscannerplus/widgets/home_drawer.dart';
import 'package:docscannerplus/widgets/scanner_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Defer logging to ensure provider is ready if needed, mostly for safety
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logScreenView(screenName: 'home_page');
    });
  }

  late final HomeActions _actions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _actions = HomeActions(
      context: context,
      ref: ref,
      setLoading: (loading) {
        if (mounted) setState(() => _isLoading = loading);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = ref.watch(isSelectionModeProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 500) {
            ref.read(documentLimitProvider.notifier).increase();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            HomeAppBar(
              onClearSelection: _actions.clearSelection,
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              onRename: _actions.renameSelectedDocument,
              onEditTags: _actions.editTags,
              onExtractText: _actions.extractTextFromSelected,
              onReorderPages: _actions.reorderPages,
              onSignDocument: _actions.signDocument,
              onAddWatermark: _actions.addWatermark,
              onMerge: _actions.mergeSelectedDocuments,
              onShare: _actions.shareSelectedDocuments,
              onDelete: _actions.deleteSelectedDocuments,
              onSearch: _actions.openSearch,
              isLoading: _isLoading,
            ),
            if (!_isLoading) const DocumentList(),
          ],
        ),
      ),
      floatingActionButton: isSelectionMode ? null : const ScannerFab(),
    );
  }
}
