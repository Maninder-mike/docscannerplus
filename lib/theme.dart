import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

class AppTheme {
  static ThemeData get _baseThemeData => ThemeData(
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      },
    ),
  );

  static ThemeData lightTheme([ColorScheme? dynamicScheme]) {
    final scheme =
        dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF006C51), // A deep teal/emerald fallback
          brightness: Brightness.light,
        );

    return _baseThemeData.copyWith(
      colorScheme: scheme,
      textTheme: GoogleFonts.outfitTextTheme(),
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(),
      searchBarTheme: const SearchBarThemeData(
        elevation: WidgetStatePropertyAll(0),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 3,
      ),
    );
  }

  static ThemeData darkTheme([ColorScheme? dynamicScheme]) {
    final scheme =
        dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF006C51),
          brightness: Brightness.dark,
        );

    return _baseThemeData.copyWith(
      colorScheme: scheme,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(),
      searchBarTheme: const SearchBarThemeData(
        elevation: WidgetStatePropertyAll(0),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 3,
      ),
    );
  }
}
