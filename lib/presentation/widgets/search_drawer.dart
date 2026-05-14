import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_utils.dart';
import '../../domain/entities/user.dart';
import '../providers/search_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

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
          if (query.isEmpty) const _FloatingBubblesBackground(),
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

class _FloatingBubblesBackground extends ConsumerWidget {
  const _FloatingBubblesBackground();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedUsersAsync = ref.watch(suggestedUsersProvider);

    return suggestedUsersAsync.when(
      data: (users) {
        if (users.isEmpty) return const SizedBox.shrink();
        
        return ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.white, Colors.transparent],
              stops: [0.3, 0.6],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Stack(
            children: List.generate(15, (index) {
              return _FloatingBubble(user: users[index % users.length]);
            }),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _FloatingBubble extends StatefulWidget {
  final User user;
  const _FloatingBubble({required this.user});

  @override
  State<_FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<_FloatingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _randomX;
  late double _size;
  late double _waveAmplitude;
  late double _waveFrequency;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 1.2, end: -0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _randomize();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _randomize();
        _controller.forward(from: 0.0);
      }
    });

    _controller.forward(from: Random().nextDouble());
  }

  void _randomize() {
    final rand = Random();
    _randomX = 0.05 + rand.nextDouble() * 0.9; // 5% to 95% of width
    _size = 35.0 + rand.nextDouble() * 30.0; // 35 to 65
    _waveAmplitude = 10.0 + rand.nextDouble() * 25.0; // 10 to 35
    _waveFrequency = 2.0 + rand.nextDouble() * 2.0; // 2 to 4 waves
    _controller.duration = Duration(seconds: 5 + rand.nextInt(5)); // 5 to 10 seconds
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = widget.user;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final wave = sin(_animation.value * _waveFrequency * pi) * _waveAmplitude;
        return Positioned(
          left: (_randomX * size.width) + wave,
          top: _animation.value * size.height,
          child: Opacity(
            opacity: 0.4,
            child: GestureDetector(
              onTap: () {
                context.go('/home/user/${user.uid}');
              },
              child: Container(
                width: _size,
                height: _size,
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
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: _size * 0.4),
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
  }
}
