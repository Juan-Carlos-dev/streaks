import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_utils.dart';
import '../../domain/entities/user.dart';
import '../providers/search_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class SearchView extends ConsumerWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _FloatingBubblesBackground(),
          SafeArea(
            child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar usuarios...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            // Results
            Expanded(
              child: resultsAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    if (query.isEmpty) {
                      return const _SearchHistoryView();
                    }
                    return const Center(
                      child: Text(
                        'No se encontraron usuarios',
                        style: TextStyle(color: Colors.white38),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: _UserAvatar(user: user),
                        title: Text(
                          user.username,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          user.bio.isNotEmpty ? user.bio : 'Sin descripción',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          ref.read(saveSearchHistoryProvider)(user.uid);
                          context.go('/home/user/${user.uid}');
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final User user;
  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(ImageUtils.wrapProxy(user.photoUrl)),
      );
    }
    final gradientIndex = (user.profileGradientIndex)
        .clamp(0, AppColors.profileGradients.length - 1);
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
          user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _SearchHistoryView extends ConsumerWidget {
  const _SearchHistoryView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentUsersAsync = ref.watch(recentUsersProvider);

    return recentUsersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(
            child: Text(
              'No hay búsquedas recientes',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recientes',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(clearSearchHistoryProvider)();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Borrar todo',
                      style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: _UserAvatar(user: user),
                    title: Text(
                      user.username,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      user.bio.isNotEmpty ? user.bio : 'Sin descripción',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                      onPressed: () {
                        ref.read(removeSearchHistoryItemProvider)(user.uid);
                      },
                    ),
                    onTap: () {
                      context.go('/home/user/${user.uid}');
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
    );
  }
}

class _FloatingBubblesBackground extends ConsumerStatefulWidget {
  const _FloatingBubblesBackground();

  @override
  ConsumerState<_FloatingBubblesBackground> createState() => _FloatingBubblesBackgroundState();
}

class _FloatingBubblesBackgroundState extends ConsumerState<_FloatingBubblesBackground> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<double> _randomXs;
  late List<double> _randomSizes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(8, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 5 + (index % 3) * 2),
      )..repeat();
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 1.2, end: -0.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.linear),
      );
    }).toList();

    _randomXs = List.generate(8, (index) => 0.05 + (index * 0.11));
    _randomSizes = List.generate(8, (index) => 40.0 + (index % 3) * 15.0);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestedUsersAsync = ref.watch(suggestedUsersProvider);
    final size = MediaQuery.of(context).size;

    return suggestedUsersAsync.when(
      data: (users) {
        if (users.isEmpty) return const SizedBox.shrink();
        
        return Stack(
          children: List.generate(_controllers.length, (index) {
            final user = users[index % users.length];
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Positioned(
                  left: _randomXs[index] * size.width,
                  top: _animations[index].value * size.height,
                  child: Opacity(
                    opacity: 0.4,
                    child: GestureDetector(
                      onTap: () {
                        context.go('/home/user/${user.uid}');
                      },
                      child: Container(
                        width: _randomSizes[index],
                        height: _randomSizes[index],
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: ClipOval(
                          child: user.photoUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: ImageUtils.wrapProxy(user.photoUrl),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.surface,
                                  child: Center(
                                    child: Text(
                                      user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
