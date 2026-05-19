import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_utils.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_providers.dart';
import '../providers/follow_providers.dart';

class FollowListModal extends ConsumerStatefulWidget {
  final String userId;
  final bool isFollowers;

  const FollowListModal({
    super.key,
    required this.userId,
    required this.isFollowers,
  });

  static void show(BuildContext context, String userId, bool isFollowers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FollowListModal(
        userId: userId,
        isFollowers: isFollowers,
      ),
    );
  }

  @override
  ConsumerState<FollowListModal> createState() => _FollowListModalState();
}

class _FollowListModalState extends ConsumerState<FollowListModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = widget.isFollowers
        ? ref.watch(followersListProvider(widget.userId))
        : ref.watch(followingListProvider(widget.userId));

    final currentUid = ref.watch(authStateProvider).value;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag indicator
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            widget.isFollowers ? 'Seguidores' : 'Siguiendo',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          // Search input
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF2E2E2E),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // User list
          Expanded(
            child: listAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error al cargar: $err',
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
              data: (users) {
                final filteredUsers = users.where((user) {
                  final username = user.username.toLowerCase();
                  return username.contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No se encontraron resultados'
                          : (widget.isFollowers ? 'No hay seguidores' : 'No sigues a nadie'),
                      style: const TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isMe = user.uid == currentUid;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // User profile info (clickable to navigate)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.of(context).pop();
                                if (isMe) {
                                  context.go('/profile');
                                } else {
                                  context.go('/home/user/${user.uid}');
                                }
                              },
                              child: Row(
                                children: [
                                  _buildAvatar(user),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.username,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (user.bio.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            user.bio,
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Follow button
                          if (!isMe) ...[
                            const SizedBox(width: 8),
                            _ModalFollowButton(targetUid: user.uid),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User user) {
    if (user.photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(ImageUtils.wrapProxy(user.photoUrl)),
      );
    }
    final gradientIndex = user.profileGradientIndex.clamp(0, AppColors.profileGradients.length - 1);
    final colors = AppColors.profileGradients[gradientIndex];
    return Container(
      width: 40,
      height: 40,
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
          (user.username.isNotEmpty ? user.username[0] : 'U').toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _ModalFollowButton extends ConsumerWidget {
  final String targetUid;
  const _ModalFollowButton({required this.targetUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = ref.watch(authStateProvider).value;
    if (currentUid == null || currentUid == targetUid) return const SizedBox.shrink();

    final isFollowingAsync = ref.watch(isFollowingProvider(targetUid));
    final controllerState = ref.watch(followControllerProvider(targetUid));

    return isFollowingAsync.when(
      loading: () => const SizedBox(
        width: 90,
        height: 32,
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (isFollowing) {
        return SizedBox(
          width: 90,
          height: 32,
          child: TextButton(
            onPressed: controllerState.isLoading
                ? null
                : () => ref.read(followControllerProvider(targetUid).notifier).toggle(),
            style: TextButton.styleFrom(
              backgroundColor: isFollowing ? Colors.white12 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: isFollowing ? const BorderSide(color: Colors.white24) : BorderSide.none,
              ),
              padding: EdgeInsets.zero,
            ),
            child: controllerState.isLoading
                ? const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                  )
                : Text(
                    isFollowing ? 'Siguiendo' : 'Seguir',
                    style: TextStyle(
                      color: isFollowing ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
