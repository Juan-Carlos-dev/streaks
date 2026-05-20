import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/image_preview_popup.dart';
import '../widgets/follow_list_modal.dart';
import '../widgets/banner_emoji_decoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/user.dart';
import '../providers/user_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/feed_providers.dart';
import '../../core/utils/image_utils.dart';
import '../providers/follow_providers.dart';
import '../widgets/profile_customization_helpers.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));
    final postsAsync = ref.watch(userPostsProvider(userId));
    final authUid = ref.watch(authStateProvider).value ?? '';
    final isOwnProfile = userId == authUid;

    return Scaffold(
      backgroundColor: Colors.black,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('No se pudo cargar el perfil', style: TextStyle(color: Colors.white54)),
        ),
        data: (user) => _UserProfileBody(
          user: user,
          postsAsync: postsAsync,
          ref: ref,
          isOwnProfile: isOwnProfile,
        ),
      ),
    );
  }
}

class _UserProfileBody extends StatelessWidget {
  final User? user;
  final AsyncValue postsAsync;
  final WidgetRef ref;
  final bool isOwnProfile;

  const _UserProfileBody({
    required this.user,
    required this.postsAsync,
    required this.ref,
    required this.isOwnProfile,
  });

  void _showLargeAvatar(BuildContext context) {
    final photoUrl = user?.photoUrl ?? '';
    if (photoUrl.isEmpty) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: anim1.drive(CurveTween(curve: Curves.easeOutBack)),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: ImageUtils.wrapProxy(photoUrl),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(color: Colors.amber),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '@${user?.username ?? ""}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca para cerrar',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bannerHeight = 160.0;
    const avatarRadius = 52.0;
    const avatarTop = bannerHeight - avatarRadius;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: bannerHeight + avatarRadius,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: bannerHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: (user != null && user!.customGradient.length == 2)
                          ? LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(int.parse(user!.customGradient[0].replaceAll('#', '0xFF'))),
                                Color(int.parse(user!.customGradient[1].replaceAll('#', '0xFF'))),
                              ],
                            )
                          : AppColors.blueGradient,
                    ),
                    child: Stack(
                      children: [
                        BannerEmojiDecoration(
                          emojiString: user?.bannerEmojiPattern ?? '',
                          style: user?.bannerEmojiStyle ?? 'none',
                          seed: (user?.bannerEmojiSeed != null && user!.bannerEmojiSeed.isNotEmpty)
                              ? user!.bannerEmojiSeed
                              : (user?.uid ?? 'default_seed'),
                          size: user?.bannerEmojiSize ?? 16.0,
                          rotation: user?.bannerEmojiRotation ?? 0.0,
                          opacity: user?.bannerEmojiOpacity ?? 0.20,
                          spacingFactor: user?.bannerEmojiSpacing ?? 1.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: bannerHeight - 24, left: 0, right: 0, bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 4,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: avatarTop - 10,
                  left: 24,
                  child: GestureDetector(
                    onTap: () => _showLargeAvatar(context),
                    child: _UPAvatar(user: user, radius: avatarRadius),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    (user?.username.isNotEmpty == true) ? user!.username : 'Usuario',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FollowListModal.show(context, user?.uid ?? '', true),
                  child: _LiveStatPair(uid: user?.uid ?? '', label: 'Seguidores', isFollowers: true),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FollowListModal.show(context, user?.uid ?? '', false),
                  child: _LiveStatPair(uid: user?.uid ?? '', label: 'Siguiendo', isFollowers: false),
                ),
              ],
            ),
          ),

          if ((user?.bio ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Text(user!.bio,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
            ),

          // ── Vitrina de Insignias ──────────────────────────────────────
          _buildBadgesShowcase(context),

          if (!isOwnProfile)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _FollowButtons(userId: user?.uid ?? ''),
            ),

          const SizedBox(height: 16),

          postsAsync.when(
            loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
            data: (posts) {
              if (posts.isEmpty) {
                return const SizedBox(
                  height: 280,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_outlined, color: Colors.white24, size: 48),
                        SizedBox(height: 12),
                        Text('Aún no hay publicaciones',
                            style: TextStyle(color: Colors.white38, fontSize: 15)),
                      ],
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) => ImagePreviewWrapper(
                    imageUrl: posts[index].imageUrl,
                    username: user?.username ?? '',
                    userPhotoUrl: user?.photoUrl ?? '',
                    profileGradientIndex: user?.profileGradientIndex ?? 0,
                    aspectRatio: 5 / 4,
                    likesCount: posts[index].likesCount,
                    caption: posts[index].caption,
                    isLiked: posts[index].likedBy.contains(ref.read(authStateProvider).value),
                    onLike: () {
                      final userId = ref.read(authStateProvider).value;
                      if (userId != null) {
                        ref.read(likePostControllerProvider).likePost(posts[index].id, userId);
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: ImageUtils.wrapProxy(posts[index].imageUrl),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: const Color(0xFF1A1A1A)),
                        errorWidget: (_, __, ___) => Container(color: const Color(0xFF1A1A1A)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }


  Widget _buildBadgesShowcase(BuildContext context) {
    final showcase = user?.showcaseBadges ?? [];
    if (showcase.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vitrina de Insignias',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: showcase.map((badgeId) {
              final badge = ProfileBadge.getById(badgeId);
              return GestureDetector(
                onTap: () => _showBadgeDetails(context, badge),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ProfileBadgeWidget(
                    badge: badge,
                    size: 56,
                    isUnlocked: true,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, ProfileBadge badge) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.grey[950],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileBadgeWidget(
                  badge: badge,
                  size: 72,
                  isUnlocked: true,
                ),
                const SizedBox(height: 16),
                Text(
                  badge.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  badge.unlockCriteria,
                  style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Widgets privados corregidos ──────────────────────────────────────────────────────────

class _UPAvatar extends StatelessWidget {
  final User? user;
  final double radius;
  const _UPAvatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl ?? '';
    final initial = (user?.username.isNotEmpty == true) ? user!.username[0].toUpperCase() : 'U';
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: ClipOval(
        child: photoUrl.isNotEmpty
            ? CachedNetworkImage(imageUrl: ImageUtils.wrapProxy(photoUrl), fit: BoxFit.cover, width: radius * 2, height: radius * 2)
            : Container(
                color: AppColors.primary,
                child: Center(
                  child: Text(initial,
                      style: TextStyle(fontSize: radius * 0.7, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
      ),
    );
  }
}

class _UPStatPair extends StatelessWidget {
  final String value;
  final String label;
  const _UPStatPair({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
      ],
    );
  }
} 

class _LiveStatPair extends ConsumerWidget {
  final String uid;
  final String label;
  final bool isFollowers;

  const _LiveStatPair({
    required this.uid,
    required this.label,
    required this.isFollowers,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = isFollowers
        ? ref.watch(followersCountProvider(uid))
        : ref.watch(followingCountProvider(uid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        countAsync.when(
          data: (n) => Text(_fmt(n),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          loading: () => const Text('—',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          error: (_, __) => const Text('0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white60)),
      ],
    );
  }
}// <--- FALTA ESTA LLAVE EN TU CÓDIGO

class _FollowButtons extends ConsumerWidget {
  final String userId;

  const _FollowButtons({required this.userId}); // Quitamos 'ref' del constructor, no es necesario en ConsumerWidget

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowingAsync = ref.watch(isFollowingProvider(userId));
    final controllerState = ref.watch(followControllerProvider(userId));

    return isFollowingAsync.when(
      loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
      data: (isFollowing) => Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isFollowing ? null : AppColors.blueGradient,
                color: isFollowing ? Colors.white12 : null,
                borderRadius: BorderRadius.circular(12),
                border: isFollowing ? Border.all(color: Colors.white24) : null,
              ),
              child: ElevatedButton(
                onPressed: controllerState.isLoading
                    ? null
                    : () => ref.read(followControllerProvider(userId).notifier).toggle(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: controllerState.isLoading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        isFollowing ? 'Siguiendo' : 'Seguir',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Mensaje', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}