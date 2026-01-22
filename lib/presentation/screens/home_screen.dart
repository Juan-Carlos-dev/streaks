import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import '../providers/feed_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/habit_providers.dart';
import '../../domain/entities/post.dart';
import 'create_post_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: feedAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const Center(
                        child: Text('No posts yet! Be the first.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: posts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _PostCard(post: post);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleButton(
            icon: Icons.add,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
            },
          ),
          Row(
            children: [
              Text(
                'Siguiendo',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Para ti',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          _CircleButton(
            icon: Icons.near_me, // Looks like Telegram icon
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF0099FF),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final Post post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(post.userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User Info Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            children: [
              userAsync.when(
                data: (user) => CircleAvatar(
                  radius: 20,
                  backgroundImage: user.photoUrl != null &&
                          user.photoUrl!.isNotEmpty
                      ? NetworkImage(user.photoUrl!)
                      : const NetworkImage('https://i.pravatar.cc/150?img=32'),
                ),
                loading: () => const CircleAvatar(
                    radius: 20, backgroundColor: Colors.grey),
                error: (_, __) =>
                    const CircleAvatar(radius: 20, backgroundColor: Colors.red),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userAsync.when(
                    data: (user) => Text(
                      user.username,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    loading: () => Container(
                        width: 100, height: 14, color: Colors.grey[800]),
                    error: (error, __) => Text('Err: $error',
                        style: GoogleFonts.outfit(
                            color: Colors.red, fontSize: 10)),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final habitAsync =
                          ref.watch(habitByIdProvider(post.habitId));
                      return habitAsync.when(
                        data: (habit) => Text(
                          habit.title,
                          style: GoogleFonts.outfit(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        loading: () => Container(
                            width: 80, height: 12, color: Colors.grey[800]),
                        error: (_, __) => Text(
                          'Habit',
                          style: GoogleFonts.outfit(
                              color: Colors.grey[400], fontSize: 12),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${post.habitStreakSnapshot}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.water_drop, color: Color(0xFF0099FF), size: 18),
            ],
          ),
        ),

        // Post Image
        AspectRatio(
          aspectRatio: 4 / 5, // Portrait aspect ratio look
          child: Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[900],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                alignment: Alignment.center,
                child: const Icon(Icons.error, color: Colors.red),
              );
            },
          ),
        ),

        // Action Bar (Star, Time, Options)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.star_rate_rounded,
                  color: Colors.amber, size: 24),
              const SizedBox(width: 4),
              Text(
                '473', // Placeholder likes
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                timeago.format(post.timestamp),
                style: GoogleFonts.outfit(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
        ),

        // Caption
        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Text(
              post.caption,
              style: GoogleFonts.outfit(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}
