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

class _FloatingBubblesBackground extends ConsumerStatefulWidget {
  const _FloatingBubblesBackground();

  @override
  ConsumerState<_FloatingBubblesBackground> createState() => _FloatingBubblesBackgroundState();
}

class _FloatingBubblesBackgroundState extends ConsumerState<_FloatingBubblesBackground> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<_BubbleData> _bubbles = [];
  bool _initialized = false;
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!_initialized || _screenSize == Size.zero) return;

    setState(() {
      for (int i = 0; i < _bubbles.length; i++) {
        final b = _bubbles[i];
        
        // Move
        b.position += b.velocity;
        
        // Wave motion (S-curve)
        b.waveOffset = sin(b.position.dy / b.waveFrequency) * b.waveAmplitude;

        // Bounce off side walls (considering wave offset)
        final actualX = b.position.dx + b.waveOffset;
        if (actualX < b.radius) {
          b.velocity = Offset(b.velocity.dx.abs(), b.velocity.dy);
        } else if (actualX > _screenSize.width - b.radius) {
          b.velocity = Offset(-b.velocity.dx.abs(), b.velocity.dy);
        }

        // Reset at top
        if (b.position.dy < -b.radius * 2) {
          _resetBubble(b);
        }

        // Collision detection
        for (int j = i + 1; j < _bubbles.length; j++) {
          final b2 = _bubbles[j];
          final pos1 = Offset(b.position.dx + b.waveOffset, b.position.dy);
          final pos2 = Offset(b2.position.dx + b2.waveOffset, b2.position.dy);
          
          final dist = (pos1 - pos2).distance;
          final minDist = b.radius + b2.radius;

          if (dist < minDist) {
            // Collision detected!
            final overlap = minDist - dist;
            final normal = (pos1 - pos2) / dist;

            // Push apart
            b.position += normal * (overlap / 2);
            b2.position -= normal * (overlap / 2);

            // Bounce velocities (simple reflection)
            final relativeVelocity = b.velocity - b2.velocity;
            final velocityAlongNormal = relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;

            if (velocityAlongNormal < 0) {
              final impulse = normal * velocityAlongNormal;
              b.velocity -= impulse;
              b2.velocity += impulse;
            }
          }
        }
      }
    });
  }

  void _resetBubble(_BubbleData b) {
    final rand = Random();
    b.radius = 17.5 + rand.nextDouble() * 15.0; // 35 to 65 diameter -> 17.5 to 32.5 radius
    b.position = Offset(
      b.radius + rand.nextDouble() * (_screenSize.width - b.radius * 2),
      _screenSize.height + b.radius * 2,
    );
    b.velocity = Offset(
      (rand.nextDouble() - 0.5) * 1.0, // Slight horizontal movement
      -1.0 - rand.nextDouble() * 1.0, // Moving up
    );
    b.waveAmplitude = 10.0 + rand.nextDouble() * 20.0;
    b.waveFrequency = 40.0 + rand.nextDouble() * 40.0;
  }

  void _initializeBubbles(List<User> users) {
    if (_initialized || _screenSize == Size.zero) return;
    
    final rand = Random();
    _bubbles = List.generate(15, (index) {
      final user = users[index % users.length];
      final radius = 17.5 + rand.nextDouble() * 15.0;
      return _BubbleData(
        position: Offset(
          radius + rand.nextDouble() * (_screenSize.width - radius * 2),
          rand.nextDouble() * _screenSize.height, // Start at random heights initially
        ),
        velocity: Offset(
          (rand.nextDouble() - 0.5) * 1.0,
          -1.0 - rand.nextDouble() * 1.0,
        ),
        radius: radius,
        user: user,
        waveAmplitude: 10.0 + rand.nextDouble() * 20.0,
        waveFrequency: 40.0 + rand.nextDouble() * 40.0,
      );
    });
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final suggestedUsersAsync = ref.watch(suggestedUsersProvider);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        _screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        return suggestedUsersAsync.when(
          data: (users) {
            if (users.isEmpty) return const SizedBox.shrink();
            
            if (!_initialized) {
              _initializeBubbles(users);
            }
            
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
                children: _bubbles.map((b) {
                  final size = b.radius * 2;
                  return Positioned(
                    left: b.position.dx + b.waveOffset - b.radius,
                    top: b.position.dy - b.radius,
                    child: Opacity(
                      opacity: 0.4,
                      child: GestureDetector(
                        onTap: () {
                          context.go('/home/user/${b.user.uid}');
                        },
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: ClipOval(
                            child: b.user.photoUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: ImageUtils.wrapProxy(b.user.photoUrl),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: AppColors.surface,
                                    child: Center(
                                      child: Text(
                                        b.user.username.isNotEmpty ? b.user.username[0].toUpperCase() : 'U',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: size * 0.4),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }
}

class _BubbleData {
  Offset position;
  Offset velocity;
  double radius;
  User user;
  double waveOffset = 0.0;
  double waveAmplitude;
  double waveFrequency;

  _BubbleData({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.user,
    required this.waveAmplitude,
    required this.waveFrequency,
  });
}
