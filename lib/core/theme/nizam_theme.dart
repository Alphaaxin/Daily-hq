import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData nizamTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: N.body,
    scaffoldBackgroundColor: N.bg,
    colorScheme: const ColorScheme.dark(
      primary: N.gold,
      onPrimary: N.goldInk,
      secondary: N.water,
      surface: N.solid,
      onSurface: N.ink,
      error: N.bad,
    ),
  );
  OutlineInputBorder border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: N.ink, displayColor: N.ink, fontFamily: N.body),
    splashFactory: InkSparkle.splashFactory,
    dividerColor: N.line,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: N.raise,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      hintStyle: const TextStyle(color: N.muted),
      labelStyle: const TextStyle(color: N.muted),
      border: border(N.line),
      enabledBorder: border(N.line),
      focusedBorder: border(N.gold),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: N.solid,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      showDragHandle: true,
      dragHandleColor: N.line,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: N.solid,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? N.goldInk : N.muted),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? N.gold : N.raise),
      trackOutlineColor: const WidgetStatePropertyAll(N.line),
    ),
    timePickerTheme: const TimePickerThemeData(backgroundColor: N.solid),
    datePickerTheme: const DatePickerThemeData(backgroundColor: N.solid, surfaceTintColor: Colors.transparent),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: N.solid),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: N.gold, selectionHandleColor: N.gold),
  );
}
