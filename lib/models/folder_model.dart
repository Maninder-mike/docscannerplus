import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Represents a folder for organizing documents.
class FolderModel {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final DateTime createdAt;

  FolderModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  /// Create a new folder with auto-generated ID.
  factory FolderModel.create({
    required String name,
    Color color = Colors.blue,
    IconData icon = Icons.folder,
  }) {
    return FolderModel(
      id: const Uuid().v4(),
      name: name,
      color: color,
      icon: icon,
      createdAt: DateTime.now(),
    );
  }

  /// Predefined folder colors for user selection.
  static const List<Color> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  /// Predefined folder icons for user selection.
  static const List<IconData> availableIcons = [
    Icons.folder,
    Icons.work,
    Icons.school,
    Icons.home,
    Icons.receipt_long,
    Icons.medical_services,
    Icons.account_balance,
    Icons.flight,
    Icons.directions_car,
    Icons.favorite,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.toARGBHex(),
      'iconIndex': availableIcons.indexOf(icon),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    // Priority: iconIndex -> iconCodePoint -> default
    IconData? icon;

    final index = json['iconIndex'] as int?;
    if (index != null && index >= 0 && index < availableIcons.length) {
      icon = availableIcons[index];
    } else {
      final codePoint = json['iconCodePoint'] as int?;
      if (codePoint != null) {
        icon = _getIconFromCodePoint(codePoint);
      }
    }

    return FolderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: _colorFromHex(json['color'] as String),
      icon: icon ?? Icons.folder,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static IconData _getIconFromCodePoint(int codePoint) {
    for (var i = 0; i < availableIcons.length; i++) {
      if (availableIcons[i].codePoint == codePoint) {
        return availableIcons[i];
      }
    }
    return Icons.folder;
  }

  FolderModel copyWith({String? name, Color? color, IconData? icon}) {
    return FolderModel(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt,
    );
  }

  static Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension ColorExtension on Color {
  String toARGBHex() {
    return '#${(toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}
