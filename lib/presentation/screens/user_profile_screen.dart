import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/user.dart';
import '../providers/user_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/feed_providers.dart';
import '../../core/utils/image_utils.dart';

/// Shows the profile of any user (identified by [userId]).
/// If the logged-in user visits their own uid, action buttons are hidden.
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

  @override
  Widget build(BuildContext context) {
    const bannerHeight = 160.0;
    const avatarRadius = 52.0;
    const avatarTop = bannerHeight - avatarRadius;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: gradient banner + back button + avatar ────────────
          SizedBox(
            height: bannerHeight + avatarRadius,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient banner
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: bannerHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF64B5F6), Color(0xFF1565C0)],
                      ),
                    ),
                  ),
                ),
                // Black rounded-top section
                Positioned(
                  top: bannerHeight - 24, left: 0, right: 0, bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 4,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                // Avatar
                Positioned(
                  top: avatarTop - 10,
                  left: 24,
                  child: _UPAvatar(user: user, radius: avatarRadius),
                ),
              ],
            ),
          ),

          // ── Username + stats ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  (user?.username.isNotEmpty == true) ? user!.username : 'Usuario',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                const _UPStatPair(value: '0', label: 'Seguidores'),
                const SizedBox(width: 24),
                const _UPStatPair(value: '0', label: 'Siguiendo'),
              ],
            ),
          ),

          // ── Bio ───────────────────────────────────────────────────────
          if ((user?.bio ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Text(user!.bio,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
            ),

          // ── Action buttons (only for other users) ─────────────────────
          if (!isOwnProfile)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Seguir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
            ),

          const SizedBox(height: 16),

          // ── Photo grid ────────────────────────────────────────────────
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
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: ImageUtils.wrapProxy(posts[index].imageUrl),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: const Color(0xFF1A1A1A)),
                      errorWidget: (_, __, ___) => Container(color: const Color(0xFF1A1A1A)),
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
}

// ── Widgets privados ──────────────────────────────────────────────────────────

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
