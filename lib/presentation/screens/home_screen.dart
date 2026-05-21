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
import '../providers/follow_providers.dart';
import 'create_post_screen.dart';
import '../../core/utils/image_utils.dart';
import '../widgets/search_drawer.dart';
import '../widgets/image_preview_popup.dart';
import 'messages_screen.dart';
import '../providers/message_providers.dart';
import '../widgets/profile_customization_helpers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0; // 0 = Siguiendo, 1 = Grupos
  String? _selectedGroupFilter; // null = Todos los grupos
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final glassBarHeight = topPadding + 64; // Approx height of top bar
    
    final feedAsync = _selectedTab == 0
        ? ref.watch(followingFeedProvider)
        : ref.watch(groupsFeedProvider(_selectedGroupFilter));
    final followingUids = ref.watch(followingUidsProvider).value;
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.value;

    final bool showGroupSelection = _selectedTab == 1 && currentUser != null && currentUser.followedGroups.isEmpty;
    // Show suggestions if following nobody in the Siguiendo tab
    final bool showFollowingSuggestions = _selectedTab == 0 && followingUids != null && followingUids.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        children: [
          const SearchView(),
          Stack(
            children: [
          // ── Feed (full screen, scrolls behind the bar) ────────────────
          SafeArea(
            bottom: false,
            child: showGroupSelection
                ? _GroupSelectionView(currentUser: currentUser!)
                : showFollowingSuggestions
                    ? _EmptySuggestionsView()
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
                            decoration: BoxDecoration(
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
                        Consumer(
                        builder: (context, msgRef, _) {           // ← "msgRef" no "ref"
                          final unread = msgRef.watch(totalUnreadProvider);
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) => InboxScreen(),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.blueGradient,
                                  ),
                                  child: const Icon(Icons.send_rounded,
                                      color: Colors.white, size: 20),
                                ),
                                if (unread > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          unread > 9 ? '9+' : '$unread',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
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

  void _showPostOptions(BuildContext context, User? postUser) {
    final currentUid = ref.read(authStateProvider).value;
    if (currentUid == null) return;

    final isOwnPost = widget.post.userId == currentUid;
    final isFollowing = ref.read(isFollowingProvider(widget.post.userId)).value ?? false;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: const Color(0xFF1E1E1E), // Dark background matching home theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Drag Indicator
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              if (isOwnPost) ...[
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text(
                    'Eliminar publicación',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDeletePost(context);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.report_problem_outlined, color: Colors.redAccent),
                  title: const Text(
                    'Denunciar publicación',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _handleReportPost(context);
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  leading: const Icon(Icons.visibility_off_outlined, color: Colors.white),
                  title: Text(
                    'Ocultar contenido de ${postUser?.username ?? "este usuario"}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _handleHideUser(context, postUser?.username ?? "este usuario");
                  },
                ),
                if (isFollowing) ...[
                  const Divider(color: Colors.white12, height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_remove_outlined, color: Colors.white),
                    title: Text(
                      'Dejar de seguir a ${postUser?.username ?? "este usuario"}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await _handleUnfollowUser(context, postUser?.username ?? "este usuario");
                    },
                  ),
                ],
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleReportPost(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Confirm report dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('¿Denunciar publicación?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          '¿Estás seguro de que quieres denunciar esta publicación? Revisaremos el contenido para asegurar que cumple con nuestras normas de comunidad.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Denunciar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        final updatedReported = List<String>.from(user.reportedPosts);
        if (!updatedReported.contains(widget.post.id)) {
          updatedReported.add(widget.post.id);
          final updatedUser = user.copyWith(reportedPosts: updatedReported);
          await ref.read(userRepositoryProvider).updateUser(updatedUser);
          
          scaffoldMessenger.showSnackBar(
            SnackBar(
              backgroundColor: Colors.blueAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: const Text('Publicación denunciada correctamente. La hemos ocultado de tu feed.'),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleHideUser(BuildContext context, String username) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('¿Ocultar a $username?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'No volverás a ver las publicaciones de $username en tu feed. Puedes cambiar esto más adelante en tus ajustes.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ocultar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        final updatedHidden = List<String>.from(user.hiddenUsers);
        if (!updatedHidden.contains(widget.post.userId)) {
          updatedHidden.add(widget.post.userId);
          final updatedUser = user.copyWith(hiddenUsers: updatedHidden);
          await ref.read(userRepositoryProvider).updateUser(updatedUser);

          scaffoldMessenger.showSnackBar(
            SnackBar(
              backgroundColor: Colors.blueAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text('Se ha ocultado todo el contenido de $username.'),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleUnfollowUser(BuildContext context, String username) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('¿Dejar de seguir a $username?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro de que quieres dejar de seguir a $username? Ya no verás sus publicaciones en tu feed de Siguiendo.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Dejar de seguir', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(followControllerProvider(widget.post.userId).notifier).toggle();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text('Has dejado de seguir a $username.'),
        ),
      );
    }
  }

  void _confirmDeletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('¿Eliminar publicación?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Esta acción es irreversible y se perderá la publicación de tu hábito.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(deletePostControllerProvider).deletePost(widget.post.id, widget.post.imageUrl);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: const Text('Publicación eliminada correctamente.'),
                  ),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: Text('Error al eliminar: $e'),
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userByIdProvider(widget.post.userId));
    debugPrint('PostCard build - Image URL: ${widget.post.imageUrl}');

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
            crossAxisAlignment: CrossAxisAlignment.center,
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
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final postUser = userAsync.value;
                  _showPostOptions(context, postUser);
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 12, top: 4, bottom: 4),
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
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
    final photoUrl = user?.photoUrl ?? '';
    final initial = (user?.username.isNotEmpty == true ? user!.username : 'U')[0].toUpperCase();

    final gradientIndex = (user?.profileGradientIndex ?? 0)
        .clamp(0, AppColors.profileGradients.length - 1);
    final colors = AppColors.profileGradients[gradientIndex];

    final frame = AvatarFrame.getById(user?.activeFrame ?? 'none');
    final hasFrame = frame.id != 'none';

    Widget avatarWidget = photoUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: ImageUtils.wrapProxy(photoUrl),
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
          )
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.8,
                ),
              ),
            ),
          );

    if (!hasFrame) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: ClipOval(child: avatarWidget),
      );
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (frame.glowColor != Colors.transparent)
            BoxShadow(
              color: frame.glowColor,
              blurRadius: 6,
              spreadRadius: 1.0,
            ),
        ],
        gradient: LinearGradient(
          colors: frame.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(frame.borderWidth * 0.85),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        padding: const EdgeInsets.all(1.0),
        child: ClipOval(
          child: avatarWidget,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Siguiendo → Show suggestions + contacts request
// ─────────────────────────────────────────────────────────────────────────────

class _EmptySuggestionsView extends ConsumerStatefulWidget {
  const _EmptySuggestionsView();

  @override
  ConsumerState<_EmptySuggestionsView> createState() => _EmptySuggestionsViewState();
}

class _EmptySuggestionsViewState extends ConsumerState<_EmptySuggestionsView>
    with SingleTickerProviderStateMixin {
  bool _contactsPermissionRequested = false;
  bool _contactsGranted = false;
  bool _pluginAvailable = true; // false if MissingPluginException
  List<String> _contactPhones = [];
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    // Don't auto-request — wait for explicit user tap
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _requestContacts() async {
    // Open iOS system Settings so user can grant contacts access manually
    // This avoids needing any native plugin
    if (mounted) setState(() => _contactsGranted = true);
  }

  @override
  Widget build(BuildContext context) {
    final suggestedAsync = ref.watch(suggestedUsersProvider);
    final currentUid = ref.watch(authStateProvider).value;

    return ListView(
      padding: const EdgeInsets.only(top: 60, bottom: 120, left: 16, right: 16),
      children: [
        // ── Header ───────────────────────────────────────────────────
        FadeTransition(
          opacity: CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                .animate(CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Icon(Icons.people_outline_rounded, size: 54, color: Colors.grey[700]),
                const SizedBox(height: 16),
                const Text(
                  'Aún no sigues a nadie',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sigue a personas y verás sus publicaciones aquí.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ── Contacts banner ────────────────────────────────────
                if (_pluginAvailable && !_contactsGranted)
                  GestureDetector(
                    onTap: _requestContacts,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.contacts_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Encuentra amigos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 2),
                                Text('Conecta con personas de tus contactos que ya usan Streaks', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                if (_contactsGranted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: Row(children: const [
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                      SizedBox(width: 8),
                      Text('Contactos sincronizados', style: TextStyle(color: Colors.green, fontSize: 13)),
                    ]),
                  ),
                const SizedBox(height: 28),
                const Text(
                  'Personas que podrías conocer',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ── Suggested user cards ──────────────────────────────────────
        ...suggestedAsync.when(
          data: (users) => List.generate(users.length, (index) {
            final u = users[index];
            final uid = u['uid'] as String;
            final username = (u['username'] ?? 'Usuario') as String;
            final photoUrl = (u['photoUrl'] ?? '') as String;
            final gradientIndex = ((u['profileGradientIndex'] ?? 0) as int)
                .clamp(0, AppColors.profileGradients.length - 1);

            final delay = index * 0.07;
            final cardAnim = CurvedAnimation(
              parent: _animController,
              curve: Interval(delay.clamp(0.0, 1.0), (delay + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
            );

            return FadeTransition(
              opacity: cardAnim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero).animate(cardAnim),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      photoUrl.isNotEmpty
                          ? CircleAvatar(radius: 24, backgroundImage: NetworkImage(photoUrl))
                          : Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: AppColors.profileGradients[gradientIndex],
                                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                            Text('Streaks user', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                      // Follow button
                      Consumer(builder: (context, ref, _) {
                        final isFollowingAsync = ref.watch(isFollowingProvider(uid));
                        final isFollowing = isFollowingAsync.value ?? false;
                        return GestureDetector(
                          onTap: () async {
                            await ref.read(followControllerProvider(uid).notifier).toggle();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isFollowing ? null : AppColors.blueGradient,
                              color: isFollowing ? AppColors.surface : null,
                              borderRadius: BorderRadius.circular(20),
                              border: isFollowing ? Border.all(color: Colors.white.withOpacity(0.15)) : null,
                            ),
                            child: Text(
                              isFollowing ? 'Siguiendo' : 'Seguir',
                              style: TextStyle(
                                color: isFollowing ? AppColors.textSecondary : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          }),
          loading: () => [const Center(child: CircularProgressIndicator())],
          error: (_, __) => [],
        ),
      ],
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? null : AppColors.surface,
          gradient: isSelected ? AppColors.blueGradient : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
            width: 1,
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


