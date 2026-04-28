// lib/common/app_theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppThemeController extends GetxController {
  static AppThemeController get to => Get.find();

  final isDarkRx = true.obs;
  bool get isDark => isDarkRx.value;

  void toggle() => isDarkRx.value = !isDarkRx.value;
  void setDark(bool v) => isDarkRx.value = v;

  // ── Colours ────────────────────────────────────────────────────────────────
  Color get bg => isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4FF);
  Color get card => isDark ? const Color(0xFF131929) : Colors.white;
  Color get cardAlt =>
      isDark ? const Color(0xFF1A2235) : const Color(0xFFF8FAFF);
  Color get border =>
      isDark ? const Color(0xFF1E2D45) : const Color(0xFFDDE6FF);
  Color get divider =>
      isDark ? const Color(0xFF1E2D45) : const Color(0xFFE8EDF8);

  Color get textMain => isDark ? Colors.white : const Color(0xFF0D1B3E);
  Color get textSub =>
      isDark ? const Color(0xFF8899BB) : const Color(0xFF5A6B8C);
  Color get textHint =>
      isDark ? const Color(0xFF4A5A7A) : const Color(0xFFAABBCC);

  Color get primary => isDark ? const Color(0xFF4D9EFF) : const Color(0xFF0D47A1);
  Color get primaryBg =>
      isDark ? const Color(0xFF0D2040) : const Color(0xFFE8F0FF);
  Color get iconActive =>
      isDark ? const Color(0xFF4D9EFF) : const Color(0xFF0D47A1);

  Color get success => const Color(0xFF00C853);
  Color get online => const Color(0xFF00E676);
  Color get loading => const Color(0xFFFF9800);
  Color get danger => const Color(0xFFFF5252);
  Color get warning => const Color(0xFFFFD740);

  Color get errorBg =>
      isDark ? const Color(0xFF2A1A1A) : const Color(0xFFFFF3F3);
  Color get errorBorder =>
      isDark ? const Color(0xFF5A2020) : const Color(0xFFFFCDD2);
  Color get errorText =>
      isDark ? const Color(0xFFFF8A80) : const Color(0xFFD32F2F);

  Color get enRouteBadge => const Color(0xFF0D47A1);
  Color get groundBadge => const Color(0xFF37474F);
  Color get unknownBadge => const Color(0xFF455A64);

  // ── Decorations ────────────────────────────────────────────────────────────
  List<BoxShadow> get cardShadow => isDark
      ? [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12)]
      : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)];

  List<BoxShadow> get elevatedShadow => isDark
      ? [
    BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 20,
        offset: const Offset(0, 8))
  ]
      : [
    BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 20,
        offset: const Offset(0, 8))
  ];

  BoxDecoration cardDecoration({double radius = 16}) => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
    boxShadow: cardShadow,
  );

  BoxDecoration fabDecoration() => BoxDecoration(
    color: card,
    shape: BoxShape.circle,
    border: Border.all(color: border),
    boxShadow: cardShadow,
  );

  Gradient get topBarGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark
        ? [
      const Color(0xFF0A0E1A).withOpacity(0.97),
      const Color(0xFF0A0E1A).withOpacity(0.0),
    ]
        : [
      const Color(0xFFF0F4FF).withOpacity(0.97),
      const Color(0xFFF0F4FF).withOpacity(0.0),
    ],
  );

  Gradient get sheetGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [const Color(0xFF0D47A1).withOpacity(0.15), Colors.transparent]
        : [const Color(0xFF0D47A1).withOpacity(0.05), Colors.transparent],
  );

  // ── Map styles ─────────────────────────────────────────────────────────────
  static const String darkMapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#0A0E1A"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#4A6080"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#0A0E1A"}]},
    {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#1A2A40"}]},
    {"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#4A7AAA"}]},
    {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#3A6A9A"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"road","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#060D18"}]},
    {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#0D2A4A"}]}
  ]''';

  static const String brightMapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#EEF2FF"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#6B7E9F"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#FFFFFF"}]},
    {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#C8D8F0"}]},
    {"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#3A5A9A"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"road","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#C8DEFF"}]},
    {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#5A8ABB"}]}
  ]''';
}