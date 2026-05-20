import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/habit.dart';

class AvatarFrame {
  final String id;
  final String name;
  final String description;
  final List<Color> gradientColors;
  final Color glowColor;
  final double borderWidth;

  const AvatarFrame({
    required this.id,
    required this.name,
    required this.description,
    required this.gradientColors,
    required this.glowColor,
    this.borderWidth = 4.0,
  });

  bool isUnlocked(User user, List<Habit> habits) {
    switch (id) {
      case 'none':
        return true;
      case 'bronze':
        return habits.isNotEmpty;
      case 'neon_blue':
        return user.stats.currentGlobalStreak >= 3;
      case 'neon_purple':
        return user.stats.currentGlobalStreak >= 5;
      case 'fire':
        return user.stats.currentGlobalStreak >= 7;
      case 'gold':
        return user.stats.currentGlobalStreak >= 15;
      default:
        return true;
    }
  }

  String get unlockCriteria {
    switch (id) {
      case 'none':
        return '';
      case 'bronze':
        return 'Crea tu primer hábito.';
      case 'neon_blue':
        return 'Consigue una racha global de 3 días.';
      case 'neon_purple':
        return 'Consigue una racha global de 5 días.';
      case 'fire':
        return 'Consigue una racha global de 7 días.';
      case 'gold':
        return 'Consigue una racha global de 15 días.';
      default:
        return '';
    }
  }

  static const List<AvatarFrame> allFrames = [
    AvatarFrame(
      id: 'none',
      name: 'Sin marco',
      description: 'El estilo clásico por defecto.',
      gradientColors: [Colors.black, Colors.black],
      glowColor: Colors.transparent,
      borderWidth: 2.0,
    ),
    AvatarFrame(
      id: 'bronze',
      name: 'Iniciador de Rachas',
      description: 'Marco metálico de bronce para empezar con estilo.',
      gradientColors: [Color(0xFF8C7853), Color(0xFFC0A080), Color(0xFF8C7853)],
      glowColor: Color(0x338C7853),
      borderWidth: 4.0,
    ),
    AvatarFrame(
      id: 'gold',
      name: 'Leyenda de Oro',
      description: 'Un marco dorado y brillante con destellos para auténticos ganadores.',
      gradientColors: [Color(0xFFBF953F), Color(0xFFFCF6BA), Color(0xFFB38728), Color(0xFFFBF5B7)],
      glowColor: Color(0x66FFD700),
      borderWidth: 4.0,
    ),
    AvatarFrame(
      id: 'fire',
      name: 'En Llamas (On Fire)',
      description: 'Un marco ardiente y cálido para quienes no rompen su racha diaria.',
      gradientColors: [Colors.orange, Colors.redAccent, Colors.yellow],
      glowColor: Color(0x66FF5722),
      borderWidth: 4.0,
    ),
    AvatarFrame(
      id: 'neon_blue',
      name: 'Glow Ciberpunk',
      description: 'Un aro de neón azul ciberpunk con sombra resplandeciente.',
      gradientColors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
      glowColor: Color(0x8800E5FF),
      borderWidth: 4.0,
    ),
    AvatarFrame(
      id: 'neon_purple',
      name: 'Nébula Violeta',
      description: 'Aro de luz magenta y violeta que destaca sobre cualquier fondo.',
      gradientColors: [Color(0xFFE040FB), Color(0xFF651FFF)],
      glowColor: Color(0x88E040FB),
      borderWidth: 4.0,
    ),
  ];

  static AvatarFrame getById(String id) {
    return allFrames.firstWhere((f) => f.id == id, orElse: () => allFrames.first);
  }
}

class ProfileBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final List<Color> backgroundColors;
  final String unlockCriteria;

  const ProfileBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.backgroundColors,
    required this.unlockCriteria,
  });

  bool isUnlocked(User user, List<Habit> habits) {
    switch (id) {
      case 'streak_7':
        return user.stats.currentGlobalStreak >= 7;
      case 'streak_30':
        return user.stats.currentGlobalStreak >= 30;
      case 'post_master':
        return user.stats.postsCount >= 10;
      case 'social_star':
        return user.stats.followersCount >= 5;
      case 'gym_rat':
        final keywords = ['gym', 'gimnasio', 'entrenar', 'ejercicio', 'pesas', 'pesa', 'workout', 'correr', 'running', 'deporte', 'fitness', 'swimming', 'bici', 'ciclismo'];
        return habits.any((h) => keywords.any((kw) => h.title.toLowerCase().contains(kw)));
      case 'mindfulness':
        final keywords = ['yoga', 'meditar', 'meditacion', 'mindfulness', 'respirar', 'relax', 'estiramientos', 'estirar', 'dormir', 'sleep'];
        return habits.any((h) => keywords.any((kw) => h.title.toLowerCase().contains(kw)));
      case 'nerd':
        final keywords = ['estudiar', 'leer', 'libro', 'programar', 'code', 'coding', 'python', 'javascript', 'developer', 'aprender', 'tfg', 'ingles', 'idiomas', 'math'];
        return habits.any((h) => keywords.any((kw) => h.title.toLowerCase().contains(kw)));
      case 'water_champion':
        final keywords = ['agua', 'water', 'nutricion', 'dieta', 'healthy', 'comer', 'comida', 'saludable', 'fruta', 'verdura'];
        return habits.any((h) => keywords.any((kw) => h.title.toLowerCase().contains(kw)));
      default:
        return false;
    }
  }

  static const List<ProfileBadge> allBadges = [
    ProfileBadge(
      id: 'streak_7',
      name: 'Racha Semanal',
      description: 'Has conseguido mantener una racha global de 7 días seguidos.',
      emoji: '⚡',
      backgroundColors: [Color(0xFFFF9800), Color(0xFFFF5722)],
      unlockCriteria: 'Alcanza una racha global de 7 días.',
    ),
    ProfileBadge(
      id: 'streak_30',
      name: 'Leyenda Mensual',
      description: '¡30 días sin fallar! Has demostrado una constancia titánica.',
      emoji: '👑',
      backgroundColors: [Color(0xFFFFD700), Color(0xFFFFA000)],
      unlockCriteria: 'Alcanza una racha global de 30 días.',
    ),
    ProfileBadge(
      id: 'gym_rat',
      name: 'Gym Rat',
      description: 'Llevas el deporte en las venas. Has creado un hábito de entrenamiento.',
      emoji: '🏋️‍♂️',
      backgroundColors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
      unlockCriteria: 'Crea un hábito relacionado con deporte o gimnasio.',
    ),
    ProfileBadge(
      id: 'mindfulness',
      name: 'Mente Zen',
      description: 'Cuidas tu salud mental mediante meditación, yoga o estiramientos.',
      emoji: '🧘',
      backgroundColors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
      unlockCriteria: 'Crea un hábito relacionado con meditación o yoga.',
    ),
    ProfileBadge(
      id: 'nerd',
      name: 'Enfoque Intelectual',
      description: 'Dedicación absoluta al estudio, la lectura o la programación.',
      emoji: '🤓',
      backgroundColors: [Color(0xFF9C27B0), Color(0xFF4A148C)],
      unlockCriteria: 'Crea un hábito relacionado con estudiar, leer o programar.',
    ),
    ProfileBadge(
      id: 'water_champion',
      name: 'Súper Hidratado',
      description: 'Priorizas una buena hidratación y nutrición en tu día a día.',
      emoji: '💧',
      backgroundColors: [Color(0xFF00BCD4), Color(0xFF006064)],
      unlockCriteria: 'Crea un hábito relacionado con tomar agua o nutrición.',
    ),
    ProfileBadge(
      id: 'post_master',
      name: 'Post Master',
      description: 'Has publicado al menos 10 veces en Streaks para motivar al resto.',
      emoji: '📸',
      backgroundColors: [Color(0xFFE91E63), Color(0xFF880E4F)],
      unlockCriteria: 'Sube 10 publicaciones en tu cuenta.',
    ),
    ProfileBadge(
      id: 'social_star',
      name: 'Estrella Social',
      description: 'Tienes una comunidad de al menos 5 seguidores que te apoyan.',
      emoji: '🌟',
      backgroundColors: [Color(0xFF009688), Color(0xFF004D40)],
      unlockCriteria: 'Consigue 5 seguidores.',
    ),
  ];

  static ProfileBadge getById(String id) {
    return allBadges.firstWhere((b) => b.id == id, orElse: () => allBadges.first);
  }
}
