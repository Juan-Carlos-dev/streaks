import 'package:flutter/material.dart';
import 'dart:math' as math;
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

enum BadgeShape { circle, hexagon, shield, diamond, star }
enum BadgeTier { bronze, silver, gold, platinum, diamond, cosmic }

class ProfileBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final IconData iconData;
  final BadgeShape shape;
  final BadgeTier tier;
  final List<Color> backgroundColors;
  final String unlockCriteria;
  final String? imagePath;

  const ProfileBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.iconData,
    required this.shape,
    required this.tier,
    required this.backgroundColors,
    required this.unlockCriteria,
    this.imagePath,
  });

  bool isUnlocked(User user, List<Habit> habits) {
    switch (id) {
      // Habits count:
      case 'habits_1':
        return habits.length >= 1;
      case 'habits_3':
        return habits.length >= 3;
      case 'habits_5':
        return habits.length >= 5;
      case 'habits_8':
        return habits.length >= 8;
      case 'habits_12':
        return habits.length >= 12;
      case 'habits_20':
        return habits.length >= 20;

      // Streaks:
      case 'streak_3':
        return user.stats.currentGlobalStreak >= 3;
      case 'streak_7':
        return user.stats.currentGlobalStreak >= 7;
      case 'streak_15':
        return user.stats.currentGlobalStreak >= 15;
      case 'streak_30':
        return user.stats.currentGlobalStreak >= 30;
      case 'streak_60':
        return user.stats.currentGlobalStreak >= 60;
      case 'streak_100':
        return user.stats.currentGlobalStreak >= 100;
      case 'streak_365':
        return user.stats.currentGlobalStreak >= 365;

      // Completions:
      case 'comp_1':
        final total = habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
        return total >= 1;
      case 'comp_10':
        final total = habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
        return total >= 10;
      case 'comp_50':
        final total = habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
        return total >= 50;
      case 'comp_100':
        final total = habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
        return total >= 100;
      case 'comp_500':
        final total = habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
        return total >= 500;
      case 'comp_1000':
        final total = habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
        return total >= 1000;

      // Posts:
      case 'posts_1':
        return user.stats.postsCount >= 1;
      case 'posts_5':
        return user.stats.postsCount >= 5;
      case 'posts_15':
        return user.stats.postsCount >= 15;
      case 'posts_30':
        return user.stats.postsCount >= 30;
      case 'posts_50':
        return user.stats.postsCount >= 50;

      // Followers:
      case 'followers_1':
        return user.stats.followersCount >= 1;
      case 'followers_5':
        return user.stats.followersCount >= 5;
      case 'followers_15':
        return user.stats.followersCount >= 15;
      case 'followers_30':
        return user.stats.followersCount >= 30;
      case 'followers_50':
        return user.stats.followersCount >= 50;

      // Following:
      case 'following_1':
        return user.stats.followingCount >= 1;
      case 'following_5':
        return user.stats.followingCount >= 5;
      case 'following_15':
        return user.stats.followingCount >= 15;

      default:
        return false;
    }
  }

  static const List<ProfileBadge> allBadges = [
    // Habits active:
    ProfileBadge(
      id: 'habits_1',
      name: 'Primer Paso',
      description: 'Has creado tu primer hábito en la aplicación.',
      emoji: '🌱',
      iconData: Icons.spa_outlined,
      shape: BadgeShape.circle,
      tier: BadgeTier.bronze,
      backgroundColors: [Color(0xFF81C784), Color(0xFF009688)],
      unlockCriteria: '1 hábito activo.',
      imagePath: 'assets/images/badge_primer_paso.png',
    ),
    ProfileBadge(
      id: 'habits_3',
      name: 'Trilogía',
      description: 'Gestionas 3 hábitos activos al mismo tiempo.',
      emoji: '☘️',
      iconData: Icons.auto_awesome_mosaic_outlined,
      shape: BadgeShape.circle,
      tier: BadgeTier.silver,
      backgroundColors: [Color(0xFF4DB6AC), Color(0xFF00796B)],
      unlockCriteria: '3 hábitos activos.',
    ),
    ProfileBadge(
      id: 'habits_5',
      name: 'Malabarista',
      description: 'Mantienes 5 hábitos activos de forma simultánea.',
      emoji: '⚡',
      iconData: Icons.bolt,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.gold,
      backgroundColors: [Color(0xFF64B5F6), Color(0xFF3F51B5)],
      unlockCriteria: '5 hábitos activos.',
    ),
    ProfileBadge(
      id: 'habits_8',
      name: 'Alta Productividad',
      description: 'Estás gestionando 8 hábitos activos a la vez.',
      emoji: '📈',
      iconData: Icons.trending_up,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.platinum,
      backgroundColors: [Color(0xFF5C6BC0), Color(0xFF1A237E)],
      unlockCriteria: '8 hábitos activos.',
    ),
    ProfileBadge(
      id: 'habits_12',
      name: 'Máxima Eficiencia',
      description: '12 hábitos activos simultáneamente. ¡Disciplina inquebrantable!',
      emoji: '🚀',
      iconData: Icons.rocket_launch,
      shape: BadgeShape.diamond,
      tier: BadgeTier.diamond,
      backgroundColors: [Color(0xFFFF8A65), Color(0xFFD84315)],
      unlockCriteria: '12 hábitos activos.',
    ),
    ProfileBadge(
      id: 'habits_20',
      name: 'Señor de la Rutina',
      description: '20 hábitos activos. Has alcanzado la maestría de la constancia.',
      emoji: '🌌',
      iconData: Icons.electric_bolt,
      shape: BadgeShape.shield,
      tier: BadgeTier.cosmic,
      backgroundColors: [Color(0xFF424242), Color(0xFF212121)],
      unlockCriteria: '20 hábitos activos.',
    ),

    // Streaks:
    ProfileBadge(
      id: 'streak_3',
      name: 'Primeras Chispas',
      description: 'Has conseguido mantener una racha global de 3 días.',
      emoji: '✨',
      iconData: Icons.flash_on,
      shape: BadgeShape.circle,
      tier: BadgeTier.bronze,
      backgroundColors: [Color(0xFFFFF176), Color(0xFFF57F17)],
      unlockCriteria: 'Racha global de 3 días.',
    ),
    ProfileBadge(
      id: 'streak_7',
      name: 'Constancia Semanal',
      description: '7 días consecutivos manteniendo tus hábitos activos.',
      emoji: '🔥',
      iconData: Icons.local_fire_department,
      shape: BadgeShape.circle,
      tier: BadgeTier.silver,
      backgroundColors: [Color(0xFFFFB74D), Color(0xFFE65100)],
      unlockCriteria: 'Racha global de 7 días.',
    ),
    ProfileBadge(
      id: 'streak_15',
      name: 'Quincena Perfecta',
      description: '15 días de racha consecutiva sin fallar.',
      emoji: '🎯',
      iconData: Icons.gps_fixed,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.gold,
      backgroundColors: [Color(0xFFFF8A80), Color(0xFFC62828)],
      unlockCriteria: 'Racha global de 15 días.',
    ),
    ProfileBadge(
      id: 'streak_30',
      name: 'Leyenda Mensual',
      description: '¡Un mes completo! 30 días de racha global.',
      emoji: '👑',
      iconData: Icons.workspace_premium,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.platinum,
      backgroundColors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
      unlockCriteria: 'Racha global de 30 días.',
    ),
    ProfileBadge(
      id: 'streak_60',
      name: 'Inquebrantable',
      description: '60 días seguidos de pura constancia y disciplina.',
      emoji: '💎',
      iconData: Icons.diamond_outlined,
      shape: BadgeShape.diamond,
      tier: BadgeTier.diamond,
      backgroundColors: [Color(0xFF4DD0E1), Color(0xFF00838F)],
      unlockCriteria: 'Racha global de 60 días.',
    ),
    ProfileBadge(
      id: 'streak_100',
      name: 'El Club del 100',
      description: '¡100 días de racha global! Un logro al alcance de muy pocos.',
      emoji: '💯',
      iconData: Icons.star,
      shape: BadgeShape.star,
      tier: BadgeTier.cosmic,
      backgroundColors: [Color(0xFFBA68C8), Color(0xFF4A148C)],
      unlockCriteria: 'Racha global de 100 días.',
    ),
    ProfileBadge(
      id: 'streak_365',
      name: 'Año Solar',
      description: '365 días de racha global ininterrumpida. Has cambiado tu vida.',
      emoji: '☀️',
      iconData: Icons.wb_sunny,
      shape: BadgeShape.shield,
      tier: BadgeTier.cosmic,
      backgroundColors: [Color(0xFFFFB74D), Color(0xFFD84315)],
      unlockCriteria: 'Racha global de 365 días.',
    ),

    // Completions count:
    ProfileBadge(
      id: 'comp_1',
      name: 'Acción Inicial',
      description: 'Has completado tu primer registro de hábito.',
      emoji: '✅',
      iconData: Icons.done,
      shape: BadgeShape.circle,
      tier: BadgeTier.bronze,
      backgroundColors: [Color(0xFFD4E157), Color(0xFF558B2F)],
      unlockCriteria: '1 hábito completado en total.',
    ),
    ProfileBadge(
      id: 'comp_10',
      name: 'Hábito en Marcha',
      description: 'Has completado hábitos 10 veces en total.',
      emoji: '🏃',
      iconData: Icons.directions_run,
      shape: BadgeShape.circle,
      tier: BadgeTier.silver,
      backgroundColors: [Color(0xFF80CBC4), Color(0xFF00695C)],
      unlockCriteria: '10 completados en total.',
    ),
    ProfileBadge(
      id: 'comp_50',
      name: 'Ruta Trazada',
      description: 'Has completado hábitos 50 veces en total.',
      emoji: '🗺️',
      iconData: Icons.map_outlined,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.gold,
      backgroundColors: [Color(0xFF80DEEA), Color(0xFF00838F)],
      unlockCriteria: '50 completados en total.',
    ),
    ProfileBadge(
      id: 'comp_100',
      name: 'Centenario Activo',
      description: 'Has completado hábitos 100 veces en total.',
      emoji: '🏅',
      iconData: Icons.emoji_events,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.platinum,
      backgroundColors: [Color(0xFFF48FB1), Color(0xFFAD1457)],
      unlockCriteria: '100 completados en total.',
    ),
    ProfileBadge(
      id: 'comp_500',
      name: 'Maestro Rutinario',
      description: 'Has completado hábitos 500 veces en total.',
      emoji: '🏆',
      iconData: Icons.star_border_purple500,
      shape: BadgeShape.diamond,
      tier: BadgeTier.diamond,
      backgroundColors: [Color(0xFFFFD54F), Color(0xFFF57C00)],
      unlockCriteria: '500 completados en total.',
    ),
    ProfileBadge(
      id: 'comp_1000',
      name: 'Dios del Hábito',
      description: '¡1000 registros completados! Eres el modelo a seguir.',
      emoji: '☯️',
      iconData: Icons.military_tech_outlined,
      shape: BadgeShape.shield,
      tier: BadgeTier.cosmic,
      backgroundColors: [Color(0xFF37474F), Color(0xFF212121)],
      unlockCriteria: '1000 completados en total.',
    ),

    // Posts:
    ProfileBadge(
      id: 'posts_1',
      name: 'Primer Post',
      description: 'Has compartido tu primera publicación con tu comunidad.',
      emoji: '📷',
      iconData: Icons.add_photo_alternate_outlined,
      shape: BadgeShape.circle,
      tier: BadgeTier.bronze,
      backgroundColors: [Color(0xFF90CAF9), Color(0xFF1565C0)],
      unlockCriteria: '1 publicación.',
    ),
    ProfileBadge(
      id: 'posts_5',
      name: 'Creador Activo',
      description: 'Has subido 5 publicaciones compartiendo tu día a día.',
      emoji: '🎨',
      iconData: Icons.palette_outlined,
      shape: BadgeShape.circle,
      tier: BadgeTier.silver,
      backgroundColors: [Color(0xFFB39DDB), Color(0xFF4527A0)],
      unlockCriteria: '5 publicaciones.',
    ),
    ProfileBadge(
      id: 'posts_15',
      name: 'Diario de Progreso',
      description: 'Has subido 15 publicaciones para registrar tu camino.',
      emoji: '🎙️',
      iconData: Icons.record_voice_over,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.gold,
      backgroundColors: [Color(0xFF80DEEA), Color(0xFF00796B)],
      unlockCriteria: '15 publicaciones.',
    ),
    ProfileBadge(
      id: 'posts_30',
      name: 'Foco Inspirador',
      description: 'Has subido 30 publicaciones. Tu disciplina inspira a otros.',
      emoji: '🌟',
      iconData: Icons.star_purple500_sharp,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.platinum,
      backgroundColors: [Color(0xFFCE93D8), Color(0xFFD81B60)],
      unlockCriteria: '30 publicaciones.',
    ),
    ProfileBadge(
      id: 'posts_50',
      name: 'Voz de Streaks',
      description: '50 publicaciones compartidas. Eres un pilar de la comunidad.',
      emoji: '📢',
      iconData: Icons.campaign_outlined,
      shape: BadgeShape.shield,
      tier: BadgeTier.cosmic,
      backgroundColors: [Color(0xFFEF9A9A), Color(0xFFB71C1C)],
      unlockCriteria: '50 publicaciones.',
    ),

    // Followers:
    ProfileBadge(
      id: 'followers_1',
      name: 'Primer Seguidor',
      description: 'Alguien ha comenzado a seguir tu progreso.',
      emoji: '👋',
      iconData: Icons.person_add_outlined,
      shape: BadgeShape.circle,
      tier: BadgeTier.bronze,
      backgroundColors: [Color(0xFFF48FB1), Color(0xFFC2185B)],
      unlockCriteria: '1 seguidor.',
    ),
    ProfileBadge(
      id: 'followers_5',
      name: 'Pequeño Círculo',
      description: 'Tienes a 5 personas siguiendo tus hábitos diarios.',
      emoji: '👥',
      iconData: Icons.people_outlined,
      shape: BadgeShape.circle,
      tier: BadgeTier.silver,
      backgroundColors: [Color(0xFF9FA8DA), Color(0xFF283593)],
      unlockCriteria: '5 seguidores.',
    ),
    ProfileBadge(
      id: 'followers_15',
      name: 'Líder de Rachas',
      description: 'Tienes una comunidad de 15 seguidores.',
      emoji: '📣',
      iconData: Icons.groups_outlined,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.gold,
      backgroundColors: [Color(0xFF80DEEA), Color(0xFF00695C)],
      unlockCriteria: '15 seguidores.',
    ),
    ProfileBadge(
      id: 'followers_30',
      name: 'Guía de Hábitos',
      description: '30 seguidores atentos a tu constancia diaria.',
      emoji: '🔮',
      iconData: Icons.diversity_3_outlined,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.platinum,
      backgroundColors: [Color(0xFFB39DDB), Color(0xFF5E35B1)],
      unlockCriteria: '30 seguidores.',
    ),
    ProfileBadge(
      id: 'followers_50',
      name: 'Referente Social',
      description: '¡50 seguidores! Tu constancia mueve montañas.',
      emoji: '👑',
      iconData: Icons.auto_awesome,
      shape: BadgeShape.shield,
      tier: BadgeTier.cosmic,
      backgroundColors: [Color(0xFFFFD54F), Color(0xFFC2185B)],
      unlockCriteria: '50 seguidores.',
    ),

    // Following:
    ProfileBadge(
      id: 'following_1',
      name: 'Explorador',
      description: 'Has comenzado a seguir a otro usuario en Streaks.',
      emoji: '🧭',
      iconData: Icons.explore_outlined,
      shape: BadgeShape.circle,
      tier: BadgeTier.bronze,
      backgroundColors: [Color(0xFFB0BEC5), Color(0xFF37474F)],
      unlockCriteria: 'Sigue a 1 usuario.',
    ),
    ProfileBadge(
      id: 'following_5',
      name: 'Compañero de Ruta',
      description: 'Sigues a 5 personas para apoyarlas en su constancia.',
      emoji: '🤝',
      iconData: Icons.handshake_outlined,
      shape: BadgeShape.circle,
      tier: BadgeTier.silver,
      backgroundColors: [Color(0xFFA5D6A7), Color(0xFF2E7D32)],
      unlockCriteria: 'Sigue a 5 usuarios.',
    ),
    ProfileBadge(
      id: 'following_15',
      name: 'Red de Inspiración',
      description: 'Sigues a 15 compañeros. ¡Gran sentido de comunidad!',
      emoji: '🕸️',
      iconData: Icons.hub_outlined,
      shape: BadgeShape.hexagon,
      tier: BadgeTier.gold,
      backgroundColors: [Color(0xFFFFCC80), Color(0xFF6A1B9A)],
      unlockCriteria: 'Sigue a 15 usuarios.',
    ),
  ];

  static ProfileBadge getById(String id) {
    return allBadges.firstWhere((b) => b.id == id, orElse: () => allBadges.first);
  }
}

class BadgePainter extends CustomPainter {
  final BadgeShape shape;
  final BadgeTier tier;
  final List<Color> gradientColors;
  final bool isUnlocked;

  BadgePainter({
    required this.shape,
    required this.tier,
    required this.gradientColors,
    required this.isUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Define the custom shape path based on the shape property
    switch (shape) {
      case BadgeShape.circle:
        path.addOval(Rect.fromLTWH(0, 0, w, h));
        break;
      case BadgeShape.hexagon:
        path.moveTo(w * 0.5, 0);
        path.lineTo(w, h * 0.25);
        path.lineTo(w, h * 0.75);
        path.lineTo(w * 0.5, h);
        path.lineTo(0, h * 0.75);
        path.lineTo(0, h * 0.25);
        path.close();
        break;
      case BadgeShape.shield:
        path.moveTo(w * 0.5, 0);
        path.quadraticBezierTo(w * 0.78, h * 0.04, w, h * 0.1);
        path.quadraticBezierTo(w * 0.96, h * 0.62, w * 0.5, h);
        path.quadraticBezierTo(w * 0.04, h * 0.62, 0, h * 0.1);
        path.quadraticBezierTo(w * 0.22, h * 0.04, w * 0.5, 0);
        path.close();
        break;
      case BadgeShape.diamond:
        path.moveTo(w * 0.5, 0);
        path.lineTo(w, h * 0.5);
        path.lineTo(w * 0.5, h);
        path.lineTo(0, h * 0.5);
        path.close();
        break;
      case BadgeShape.star:
        final cx = w / 2;
        final cy = h / 2;
        final rOuter = w / 2;
        final rInner = w / 3.4;
        for (int i = 0; i < 16; i++) {
          final angle = i * (math.pi / 8);
          final r = i % 2 == 0 ? rOuter : rInner;
          final x = cx + r * math.cos(angle);
          final y = cy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;
    }

    // Glow effect (Outer Aura)
    if (isUnlocked) {
      final paintGlow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..color = gradientColors.first.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawPath(path, paintGlow);
    }

    // Inner Glassmorphic Fill
    final paintFill = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked 
          ? Colors.black.withOpacity(0.4) 
          : Colors.white.withOpacity(0.04);
    canvas.drawPath(path, paintFill);

    // Gradient Stroke Border
    final paintBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..shader = LinearGradient(
        colors: isUnlocked 
            ? gradientColors 
            : [Colors.white24, Colors.white10],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, paintBorder);

    // Cosmic shine highlights
    if (isUnlocked && tier == BadgeTier.cosmic) {
      final paintShine = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withOpacity(0.5);
      
      canvas.drawCircle(Offset(w * 0.25, h * 0.25), 2, paintShine);
      canvas.drawCircle(Offset(w * 0.75, h * 0.3), 1, paintShine);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProfileBadgeWidget extends StatelessWidget {
  final ProfileBadge badge;
  final double size;
  final bool isUnlocked;

  const ProfileBadgeWidget({
    Key? key,
    required this.badge,
    required this.size,
    this.isUnlocked = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (badge.imagePath != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular clipped image asset to isolate the coin
            ClipOval(
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.4,
                child: Transform.scale(
                  scale: 1.35,
                  child: Image.asset(
                    badge.imagePath!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            if (!isUnlocked)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.white70,
                    size: size * 0.38,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background CustomPaint
          CustomPaint(
            size: Size(size, size),
            painter: BadgePainter(
              shape: badge.shape,
              tier: badge.tier,
              gradientColors: badge.backgroundColors,
              isUnlocked: isUnlocked,
            ),
          ),
          
          // Center Icon
          Positioned(
            child: isUnlocked
                ? ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: badge.backgroundColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Icon(
                      badge.iconData,
                      size: size * 0.42,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    badge.iconData,
                    size: size * 0.42,
                    color: Colors.white12,
                  ),
          ),
          
          // Bottom Stars representing tier
          Positioned(
            bottom: size * 0.08,
            child: _buildStars(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(BuildContext context) {
    int starCount = 0;
    Color starColor = Colors.grey;
    
    switch (badge.tier) {
      case BadgeTier.bronze:
        starCount = 1;
        starColor = const Color(0xFFCD7F32);
        break;
      case BadgeTier.silver:
        starCount = 2;
        starColor = const Color(0xFFC0C0C0);
        break;
      case BadgeTier.gold:
        starCount = 3;
        starColor = const Color(0xFFFFD700);
        break;
      case BadgeTier.platinum:
        starCount = 4;
        starColor = const Color(0xFFE5E4E2);
        break;
      case BadgeTier.diamond:
        starCount = 5;
        starColor = const Color(0xFFB9F2FF);
        break;
      case BadgeTier.cosmic:
        starCount = 5;
        starColor = const Color(0xFFE040FB);
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        starCount,
        (i) => Icon(
          Icons.star,
          size: size * 0.12,
          color: isUnlocked ? starColor : Colors.white12,
        ),
      ),
    );
  }
}
