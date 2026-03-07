import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final selectionProvider = NotifierProvider<Selection, Set<String>>(() {
  return Selection();
});

class Selection extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void select(String id) {
    state = {...state, id};
  }

  void clear() {
    state = {};
  }
}

final isSelectionModeProvider = Provider<bool>((ref) {
  return ref.watch(selectionProvider).isNotEmpty;
});
