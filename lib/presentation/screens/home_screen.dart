import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_colors.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/user.dart';
import '../providers/feed_providers.dart';
import '../providers/user_providers.dart';
import 'create_post_screen.dart';
import '../../core/utils/image_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0; // 0 = Siguiendo, 1 = Para ti

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Feed (full screen, scrolls behind the bar) ────────────────
          SafeArea(
            child: feedAsync.when(
              data: (posts) {
                if (posts.isEmpty) return _EmptyFeed();
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 72, bottom: 12),
                  itemCount: posts.length,
                  itemBuilder: (context, index) => _PostCard(post: posts[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),

          // ── Glass top bar (overlay) ───────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                          ),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.blueGradient,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 24),
                          ),
                        ),
                        const Spacer(),
                        _TabButton(
                          label: 'Siguiendo',
                          selected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        const SizedBox(width: 24),
                        _TabButton(
                          label: 'Para ti',
                          selected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                        const Spacer(),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.blueGradient,
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab button with underline indicator ───────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? Colors.white : Colors.white54,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: selected ? label.length * 8.5 : 0,
            decoration: BoxDecoration(
              gradient: AppColors.blueGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera_outlined,
              size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          const Text('¡Aún no hay publicaciones!',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Sé el primero en compartir tu progreso',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Post card ─────────────────────────────────────────────────────────────────
class _PostCard extends ConsumerWidget {
  final Post post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(post.userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: avatar + name + habit + streak
        userAsync.when(
          data: (user) => _PostHeader(post: post, user: user),
          loading: () => _PostHeader(post: post, user: null),
          error: (_, __) => _PostHeader(post: post, user: null),
        ),

        // Image — 5:4 (Instagram portrait), cropped to fill
        AspectRatio(
          aspectRatio: 5 / 4,
          child: CachedNetworkImage(
            imageUrl: ImageUtils.wrapProxy(post.imageUrl),
            width: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            placeholder: (_, __) => Container(
              color: AppColors.surfaceLight,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.surfaceLight,
              child: const Icon(Icons.broken_image,
                  color: Colors.grey, size: 48),
            ),
          ),
        ),

        // Footer: likes + time + three dots
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                '${post.likesCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                timeago.format(post.timestamp, locale: 'es'),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              const Spacer(),
              const Icon(Icons.more_vert,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),

        // Caption
        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              post.caption,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
          ),

        const SizedBox(height: 6),
      ],
    );
  }
}

// ── Post header row ───────────────────────────────────────────────────────────
class _PostHeader extends StatelessWidget {
  final Post post;
  final User? user;

  const _PostHeader({required this.post, required this.user});

  @override
  Widget build(BuildContext context) {
    const habitName = 'Hábito';         // TODO: resolve from habitId if needed
    final username = user?.username ?? 'Usuario';
    final streak = post.habitStreakSnapshot;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          // Avatar — tappable → perfil
          GestureDetector(
            onTap: () => context.go('/home/user/${post.userId}'),
            child: _UserAvatar(user: user, radius: 22),
          ),
          const SizedBox(width: 10),
          // Name + habit — tappable → perfil
          Expanded(
            child: GestureDetector(
              onTap: () => context.go('/home/user/${post.userId}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    habitName,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          // Streak count + flame
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.local_fire_department,
                  color: AppColors.primary, size: 22),
            ],
          ),
        ],
      ),
    );
  }
}

// ── User avatar ───────────────────────────────────────────────────────────────
class _UserAvatar extends StatelessWidget {
  final User? user;
  final double radius;

  const _UserAvatar({required this.user, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    if (user != null && user!.photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(ImageUtils.wrapProxy(user!.photoUrl)),
      );
    }
    final gradientIndex = (user?.profileGradientIndex ?? 0)
        .clamp(0, AppColors.profileGradients.length - 1);
    final colors = AppColors.profileGradients[gradientIndex];
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          (user?.username.isNotEmpty == true ? user!.username : 'U')[0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.8,
          ),
        ),
      ),
    );
  }
}


