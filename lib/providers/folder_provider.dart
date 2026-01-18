import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedFolderNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) {
    state = id;
  }
}

final selectedFolderProvider =
    NotifierProvider<SelectedFolderNotifier, String?>(
      SelectedFolderNotifier.new,
    );

class SelectedFolderNameNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? name) {
    state = name;
  }
}

final selectedFolderNameProvider =
    NotifierProvider<SelectedFolderNameNotifier, String?>(
      SelectedFolderNameNotifier.new,
    );
