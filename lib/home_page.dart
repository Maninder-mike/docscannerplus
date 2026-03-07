import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docscannerplus/features/home/logic/home_actions.dart';
import 'package:docscannerplus/features/home/widgets/home_app_bar.dart';
import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/providers/selection_provider.dart';
import 'package:docscannerplus/widgets/document_list.dart';
import 'package:docscannerplus/widgets/scanner_fab.dart';
import 'package:docscannerplus/widgets/home_drawer.dart';

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

  late HomeActions _actions;

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
        child: RefreshIndicator(
          onRefresh: () async {
            // Add a small delay for UX, the stream providers automatically update
            await Future.delayed(const Duration(milliseconds: 600));
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
              if (!isSelectionMode)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final sort = ref.watch(documentSortProvider);
                            String sortLabel = 'Date added';
                            if (sort == DocumentSortOption.nameAsc ||
                                sort == DocumentSortOption.nameDesc) {
                              sortLabel = 'Name';
                            }

                            return ActionChip(
                              avatar: const Icon(Icons.sort, size: 16),
                              label: Text(sortLabel),
                              onPressed: () => _showSortOptions(context, ref),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Consumer(
                          builder: (context, ref, _) {
                            final tag = ref.watch(documentTagFilterProvider);
                            return ActionChip(
                              avatar: const Icon(Icons.filter_list, size: 16),
                              label: Text(tag ?? 'All'),
                              onPressed: () => _showFilterOptions(context, ref),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isLoading) const DocumentList(),
            ],
          ),
        ),
      ),
      floatingActionButton: isSelectionMode ? null : const ScannerFab(),
    );
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final currentSort = ref.watch(documentSortProvider);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date (Newest first)'),
                trailing: currentSort == DocumentSortOption.dateDesc
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(documentSortProvider.notifier).state =
                      DocumentSortOption.dateDesc;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date (Oldest first)'),
                trailing: currentSort == DocumentSortOption.dateAsc
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(documentSortProvider.notifier).state =
                      DocumentSortOption.dateAsc;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name (A-Z)'),
                trailing: currentSort == DocumentSortOption.nameAsc
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(documentSortProvider.notifier).state =
                      DocumentSortOption.nameAsc;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha_outlined),
                title: const Text('Name (Z-A)'),
                trailing: currentSort == DocumentSortOption.nameDesc
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(documentSortProvider.notifier).state =
                      DocumentSortOption.nameDesc;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context, WidgetRef ref) {
    // For now, just show a simple clear option.
    // In a real app, this would show a list of unique tags from the documents.
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear Filter'),
                onTap: () {
                  ref.read(documentTagFilterProvider.notifier).state = null;
                  Navigator.pop(context);
                },
              ),
              // We could dynamically list tags here...
            ],
          ),
        );
      },
    );
  }
}
