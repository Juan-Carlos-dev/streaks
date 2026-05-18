import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF007BFF);
  static const Color primaryLight = Color(0xFF4DA3FF);
  static const Color primaryDark = Color(0xFF0056B3);

  // Backgrounds
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF1A1A2E);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textHint = Color(0xFF666666);

  // Accents
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color pink = Color(0xFFFF2D55);
  static const Color purple = Color(0xFFAF52DE);

  // Habit Colors
  static const List<String> habitColors = [
    '#007BFF', // Classic Blue
    '#FF3B30', // Active Red
    '#34C759', // Vibrant Green
    '#FF9500', // Energizing Orange
    '#AF52DE', // Deep Purple
    '#FF2D55', // Bright Pink
    '#5AC8FA', // Sky Blue
    '#FFCC00', // Golden Yellow
    '#00E5FF', // Bright Cyan
    '#00DEC6', // Mint Teal
    '#2ECC71', // Emerald Green
    '#FA8072', // Sweet Salmon
    '#F08080', // Coral Pink
    '#D6A2E8', // Soft Lilac
    '#FF7F50', // Warm Coral
    '#8A2BE2', // Electric Violet
  ];

  // Profile gradient presets
  static const List<List<Color>> profileGradients = [
    [Color(0xFF007BFF), Color(0xFF00D2FF)],
    [Color(0xFFFF3B30), Color(0xFFFF9500)],
    [Color(0xFF34C759), Color(0xFF00D2FF)],
    [Color(0xFFAF52DE), Color(0xFFFF2D55)],
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
  ];

  // Main app gradient (Login/background)
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0066FF),
      Color(0xFF003399),
      Color(0xFF000033),
      Color(0xFF000000),
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF007BFF), Color(0xFF00D2FF)],
  );

  // Standard blue gradient used on all interactive blue elements (dark → light)
  static LinearGradient blueGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3D8EF0), Color(0xFF64B5F6)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A2E), Color(0xFF000000)],
  );

  static Color habitColorFromHex(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return primary;
    }
  }

  static IconData habitIconFromString(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'book':
        return Icons.book;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'edit_note':
        return Icons.edit_note;
      case 'local_florist':
        return Icons.local_florist;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'pets':
        return Icons.pets;
      case 'music_note':
        return Icons.music_note;
      case 'code':
        return Icons.code;
      case 'restaurant':
        return Icons.restaurant;
      case 'water_drop':
        return Icons.water_drop;
      case 'bedtime':
        return Icons.bedtime;
      case 'directions_run':
        return Icons.directions_run;
      case 'brush':
        return Icons.brush;
      default:
        return Icons.check_circle_outline;
    }
  }
}
