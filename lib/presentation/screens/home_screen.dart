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
import '../providers/habit_providers.dart';
import '../providers/auth_providers.dart';
import 'create_post_screen.dart';
import '../../core/utils/image_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0; // 0 = Siguiendo, 1 = Grupos
  String? _selectedGroupFilter; // null = Todos los grupos

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final glassBarHeight = topPadding + 64; // Approx height of top bar
    
    final feedAsync = _selectedTab == 0 ? ref.watch(feedStreamProvider) : ref.watch(groupsFeedProvider(_selectedGroupFilter));
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.value;

    final bool showGroupSelection = _selectedTab == 1 && currentUser != null && currentUser.followedGroups.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Feed (full screen, scrolls behind the bar) ────────────────
          SafeArea(
            bottom: false,
            child: showGroupSelection
                ? _GroupSelectionView(currentUser: currentUser!)
                : feedAsync.when(
              data: (posts) {
                if (posts.isEmpty) return _EmptyFeed();
                return RefreshIndicator(
                  backgroundColor: AppColors.surface,
                  color: AppColors.primary,
                  edgeOffset: 90, // Desplaza el indicador hacia abajo para que no quede detrás del header
                  onRefresh: () async {
                    // Refresca el provider del feed
                    if (_selectedTab == 0) {
                      ref.invalidate(feedStreamProvider);
                    } else {
                      ref.invalidate(groupsFeedProvider);
                    }
                    // Pequeño delay visual
                    await Future.delayed(const Duration(milliseconds: 800));
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: _selectedTab == 1 ? 120 : 72,
                      bottom: 120
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == posts.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40, bottom: 40),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[700]),
                              const SizedBox(height: 16),
                              const Text(
                                '¡Estás al día!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No quedan más publicaciones por ver.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return _PostCard(post: posts[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),

          // ── Group Filters (horizontal chips below top bar) ───────────────
          if (_selectedTab == 1 && !showGroupSelection && currentUser != null)
            Positioned(
              top: glassBarHeight + 8,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _GroupChip(
                      label: 'Todos',
                      isSelected: _selectedGroupFilter == null,
                      onTap: () => setState(() => _selectedGroupFilter = null),
                    ),
                    const SizedBox(width: 8),
                    ...currentUser.followedGroups.map((g) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _GroupChip(
                          label: g,
                          isSelected: _selectedGroupFilter == g.trim().toLowerCase(),
                          onTap: () => setState(() => _selectedGroupFilter = g.trim().toLowerCase()),
                        ),
                      );
                    }),
                  ],
                ),
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
                          label: 'Grupos',
                          selected: _selectedTab == 1,
                          onTap: () => setState(() {
                            _selectedTab = 1;
                            _selectedGroupFilter = null;
                          }),
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
class _PostCard extends ConsumerStatefulWidget {
  final Post post;

  const _PostCard({required this.post});

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
  bool _isLiking = false;

  void _handleDoubleTap() async {
    final userId = ref.read(authStateProvider).value;
    if (userId == null) return;
    
    final isLiking = !widget.post.likedBy.contains(userId);
    
    if (isLiking) {
      setState(() { _isLiking = true; });
    }
    
    ref.read(likePostControllerProvider).likePost(widget.post.id, userId);
    
    if (isLiking) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) setState(() { _isLiking = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userByIdProvider(widget.post.userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: avatar + name + habit + streak
        userAsync.when(
          data: (user) => _PostHeader(post: widget.post, user: user),
          loading: () => _PostHeader(post: widget.post, user: null),
          error: (_, __) => _PostHeader(post: widget.post, user: null),
        ),

        // Image — 5:4 (Instagram portrait), cropped to fill
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: AspectRatio(
            aspectRatio: 5 / 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: ImageUtils.wrapProxy(widget.post.imageUrl),
                  width: double.infinity,
                  height: double.infinity,
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
                if (_isLiking)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: AnimatedOpacity(
                          opacity: _isLiking ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 120,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        // Footer: likes + time + three dots
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                widget.post.likedBy.contains(ref.watch(authStateProvider).value)
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: widget.post.likedBy.contains(ref.watch(authStateProvider).value)
                    ? Colors.amber
                    : Colors.white,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.post.likesCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                timeago.format(widget.post.timestamp, locale: 'es'),
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
        if (widget.post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              widget.post.caption,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
          ),

        const SizedBox(height: 6),
      ],
    );
  }
}

// ── Post header row ───────────────────────────────────────────────────────────
class _PostHeader extends ConsumerWidget {
  final Post post;
  final User? user;

  const _PostHeader({required this.post, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(post.habitId));
    final habitName = habitAsync.when(
      data: (habit) => habit?.title ?? 'Hábito',
      loading: () => '...',
      error: (_, __) => 'Hábito',
    );
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

class _GroupSelectionView extends ConsumerStatefulWidget {
  final User currentUser;
  const _GroupSelectionView({required this.currentUser});

  @override
  ConsumerState<_GroupSelectionView> createState() => _GroupSelectionViewState();
}

class _GroupSelectionViewState extends ConsumerState<_GroupSelectionView> with SingleTickerProviderStateMixin {
  final List<String> _availableGroups = [
    'Hiking', 'Running', 'Gym', 'Meditation', 'Reading', 'Coding', 'Yoga', 'Nutrition'
  ];
  final Set<String> _selected = {};
  bool _isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() async {
    if (_selected.isEmpty) return;
    setState(() => _isLoading = true);
    final updatedUser = widget.currentUser.copyWith(
      followedGroups: _selected.toList(),
    );
    await ref.read(userRepositoryProvider).updateUser(updatedUser);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    );

    final buttonAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeTransition(
              opacity: headerAnimation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(headerAnimation),
                child: Column(
                  children: [
                    const Text(
                      '¿Qué temas te interesan?',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecciona los grupos de los que quieres ver publicaciones.',
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(_availableGroups.length, (index) {
                final group = _availableGroups[index];
                final isSelected = _selected.contains(group);
                
                // Staggered animation for each chip
                final delayStart = 0.2 + (index * 0.05);
                final delayEnd = delayStart + 0.4;
                final chipAnimation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    delayStart.clamp(0.0, 1.0),
                    delayEnd.clamp(0.0, 1.0),
                    curve: Curves.elasticOut,
                  ),
                );

                return ScaleTransition(
                  scale: chipAnimation,
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _controller,
                      curve: Interval(delayStart.clamp(0.0, 1.0), (delayStart + 0.2).clamp(0.0, 1.0)),
                    ),
                    child: ChoiceChip(
                      label: Text(group),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) _selected.add(group);
                          else _selected.remove(group);
                        });
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            FadeTransition(
              opacity: buttonAnimation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(buttonAnimation),
                child: ElevatedButton(
                  onPressed: _selected.isEmpty || _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: _selected.isEmpty ? 0 : 8,
                    shadowColor: AppColors.primary.withOpacity(0.5),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Comenzar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}


