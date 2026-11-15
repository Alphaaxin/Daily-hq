import 'package:flutter/material.dart';

/// Premium black & gold, like a private-banking app. Single dark theme.
class N {
  N._();

  static const bg = Color(0xFF07080B);
  static const solid = Color(0xFF121318);
  static const surface = Color(0x09FFFFFF); // ~3.5% white
  static const raise = Color(0x0EFFFFFF); // ~5.5% white
  static const line = Color(0x14FFFFFF); // 8% white
  static const ink = Color(0xFFF3EFE6);
  static const muted = Color(0xFF9C978B);

  static const gold = Color(0xFFD9B46A);
  static const goldHi = Color(0xFFF0D59A);
  static const goldLo = Color(0xFFA9823F);
  static const goldInk = Color(0xFF17120A);
  static const goldSoft = Color(0x21D9B46A);

  static const water = Color(0xFF6CC4E6);
  static const waterSoft = Color(0x216CC4E6);
  static const good = Color(0xFF5FD39A);
  static const goodSoft = Color(0x215FD39A);
  static const warn = Color(0xFFE9C062);
  static const bad = Color(0xFFF07A6E);
  static const badSoft = Color(0x21F07A6E);
  static const night = Color(0xFFDCDFFF);

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldHi, gold, goldLo],
    stops: [0, .45, 1],
  );

  static const nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2B2F4A), Color(0xFF1A1C2E)],
  );

  static const display = 'Sora';
  static const body = 'Figtree';
  static const mono = 'IBMPlexMono';

  static const r = 22.0; // card radius
  static const gap = 14.0;

  static TextStyle h1 = const TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w700,
    fontSize: 27,
    height: 1.1,
    letterSpacing: -0.8,
    color: ink,
  );
  static TextStyle h2 = const TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: -0.16,
    color: ink,
  );
  static TextStyle eyebrow = const TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    letterSpacing: 1.0,
    color: muted,
  );
  static TextStyle small = const TextStyle(fontFamily: body, fontSize: 13, color: muted);
  static TextStyle num(double size, {Color color = ink, FontWeight weight = FontWeight.w600}) => TextStyle(
    fontFamily: mono,
    fontSize: size,
    fontWeight: weight,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
