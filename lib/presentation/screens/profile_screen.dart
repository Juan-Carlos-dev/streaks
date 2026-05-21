import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/image_preview_popup.dart';
import '../widgets/follow_list_modal.dart';
import '../widgets/banner_emoji_decoration.dart';
import '../widgets/profile_customization_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/post.dart';
import '../../core/utils/widget_utils.dart';
import '../providers/user_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/habit_providers.dart';
import '../providers/feed_providers.dart';
import '../../core/utils/image_utils.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final habitsAsync = ref.watch(habitListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: userAsync.when(
        data: (user) {
          final authUid = ref.watch(authStateProvider).value ?? '';
          final postsAsync = ref.watch(userPostsProvider(authUid));
          final isOwnProfile = user?.uid == authUid;
          return _ProfileBody(user: user, habitsAsync: habitsAsync, ref: ref, postsAsync: postsAsync, isOwnProfile: isOwnProfile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final User? user;
  final AsyncValue habitsAsync;
  final WidgetRef ref;
  final AsyncValue postsAsync;
  final bool isOwnProfile;

  final ValueNotifier<Post?> _draggingPost = ValueNotifier<Post?>(null);
  final ValueNotifier<bool> _isOverTrash = ValueNotifier<bool>(false);

  String _formatCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
  return '$count';
  }

  Future<void> _changeProfilePhoto(BuildContext context) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );
  if (picked == null) return;

  final authUid = ref.read(authStateProvider).value;
  if (authUid == null) return;

  try {
    // Subir a Firebase Storage
    final file = File(picked.path);
    final storageRef = FirebaseStorage.instanceFor(
      bucket: 'streaks-cc514.firebasestorage.app',
    ).ref().child('avatars/$authUid.jpg');

    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();

    // Guardar URL en Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(authUid)
        .set({'photoUrl': downloadUrl}, SetOptions(merge: true));

    ref.invalidate(currentUserProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto actualizada')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la foto: $e')),
      );
    }
  }
}

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.grey[950],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Personalizar Avatar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: Colors.white),
                title: const Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _changeProfilePhoto(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.blur_circular_outlined, color: Colors.white),
                title: const Text(
                  'Elegir marco de avatar',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showFrameSelector(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showFrameSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.grey[950],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String selectedFrameId = user?.activeFrame ?? 'none';
        
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                final habits = habitsAsync.value ?? [];
                
                return SafeArea(
                  bottom: false,
                  child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Marcos de Avatar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Interactive preview section
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _Avatar(
                            user: user?.copyWith(activeFrame: selectedFrameId),
                            radius: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AvatarFrame.getById(selectedFrameId).name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AvatarFrame.getById(selectedFrameId).id == 'none'
                                ? 'Sin marco seleccionado.'
                                : AvatarFrame.getById(selectedFrameId).description,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: AvatarFrame.allFrames.length,
                        itemBuilder: (context, index) {
                          final frame = AvatarFrame.allFrames[index];
                          final isSelected = selectedFrameId == frame.id;
                          final isUnlocked = frame.isUnlocked(user!, habits);
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.white10,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    if (isUnlocked && frame.glowColor != Colors.transparent)
                                      BoxShadow(
                                        color: frame.glowColor,
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                  ],
                                  gradient: LinearGradient(
                                    colors: isUnlocked 
                                        ? frame.gradientColors 
                                        : [Colors.grey[800]!, Colors.grey[700]!],
                                  ),
                                ),
                                padding: EdgeInsets.all(frame.borderWidth * 0.7),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                    child: isUnlocked 
                                        ? (isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null)
                                        : const Icon(Icons.lock_outline, color: Colors.white60, size: 16),
                                  ),
                                ),
                              ),
                              title: Text(
                                frame.name,
                                style: TextStyle(
                                  color: isUnlocked ? Colors.white : Colors.white38,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    isUnlocked ? frame.description : 'Requisito: ${frame.unlockCriteria}',
                                    style: TextStyle(
                                      color: isUnlocked ? Colors.grey[400] : Colors.amber[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: isUnlocked
                                  ? () => setState(() => selectedFrameId = frame.id)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    // Action button at bottom
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: selectedFrameId == user?.activeFrame
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _updateActiveFrame(context, selectedFrameId);
                                },
                          child: const Text(
                            'Equipar Marco',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
              },
            );
          },
        );
      },
    );
  }

  Future<void> _updateActiveFrame(BuildContext context, String frameId) async {
    final authUid = ref.read(authStateProvider).value;
    if (authUid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authUid)
          .update({'activeFrame': frameId});
      
      ref.invalidate(currentUserProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Marco equipado con éxito!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al equipar el marco: $e')),
        );
      }
    }
  }

  Widget _buildBadgesShowcase(BuildContext context) {
    final showcase = user?.showcaseBadges ?? [];

    // On other profiles, hide the whole section if no badges are showcased
    if (!isOwnProfile && showcase.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              if (isOwnProfile)
                GestureDetector(
                  onTap: () => _showBadgeShowcaseEditor(context),
                  child: const Text(
                    'Editar',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(3, (index) {
              final hasBadge = index < showcase.length;
              if (hasBadge) {
                final badgeId = showcase[index];
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
              } else {
                // On other profiles, don't show empty slots at all
                if (!isOwnProfile) return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () => _showBadgeShowcaseEditor(context),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white24,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                      color: Colors.white.withOpacity(0.02),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white30,
                        size: 20,
                      ),
                    ),
                  ),
                );
              }
            }),
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
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '¡Logro conseguido!',
                        style: TextStyle(
                          color: Colors.green[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBadgeShowcaseEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.grey[950],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        List<String> tempShowcase = List<String>.from(user?.showcaseBadges ?? []);
        
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                final habits = habitsAsync.value ?? [];
                
                return SafeArea(
                  bottom: false,
                  child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Editar Vitrina de Insignias',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Elige hasta 3 insignias para lucir en tu perfil (${tempShowcase.length}/3)',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Selected badges preview row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final hasBadge = index < tempShowcase.length;
                          if (hasBadge) {
                            final badge = ProfileBadge.getById(tempShowcase[index]);
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: ProfileBadgeWidget(
                                    badge: badge,
                                    size: 50,
                                    isUnlocked: true,
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tempShowcase.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(Icons.close, color: Colors.white, size: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white12, width: 1.5),
                              ),
                              child: const Center(
                                child: Icon(Icons.add, color: Colors.white12, size: 18),
                              ),
                            );
                          }
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: ProfileBadge.allBadges.length,
                        itemBuilder: (context, index) {
                          final badge = ProfileBadge.allBadges[index];
                          final isUnlocked = badge.isUnlocked(user!, habits);
                          final isSelected = tempShowcase.contains(badge.id);
                          
                          return GestureDetector(
                            onTap: isUnlocked
                                ? () {
                                    setState(() {
                                      if (isSelected) {
                                        tempShowcase.remove(badge.id);
                                      } else {
                                        if (tempShowcase.length < 3) {
                                          tempShowcase.add(badge.id);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Solo puedes destacar hasta 3 insignias'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      }
                                    });
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? badge.backgroundColors.first.withOpacity(0.12)
                                    : Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected 
                                      ? badge.backgroundColors.first 
                                      : Colors.white10,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ProfileBadgeWidget(
                                    badge: badge,
                                    size: 44,
                                    isUnlocked: isUnlocked,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    badge.name,
                                    style: TextStyle(
                                      color: isUnlocked ? Colors.white : Colors.white38,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Text(
                                      isUnlocked ? badge.description : 'Requisito: ${badge.unlockCriteria}',
                                      style: TextStyle(
                                        color: isUnlocked ? Colors.grey[400] : Colors.amber[700],
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Action button at bottom
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _updateShowcaseBadges(context, tempShowcase);
                          },
                          child: const Text(
                            'Guardar Vitrina',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
              },
            );
          },
        );
      },
    );
  }

  Future<void> _updateShowcaseBadges(BuildContext context, List<String> showcase) async {
    final authUid = ref.read(authStateProvider).value;
    if (authUid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authUid)
          .update({'showcaseBadges': showcase});
      
      ref.invalidate(currentUserProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Vitrina de insignias actualizada!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar vitrina: $e')),
        );
      }
    }
  }

  _ProfileBody({
    required this.user,
    required this.habitsAsync,
    required this.ref,
    required this.postsAsync,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    const bannerHeight = 160.0;
    const avatarRadius = 52.0;
    const avatarTop = bannerHeight - avatarRadius;

    return SizedBox.expand(
      child: Stack(
        children: [
          SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: gradient banner + overlapping avatar ──────────────
          SizedBox(
            height: bannerHeight + avatarRadius,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient banner
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
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
                // Black rounded-top section below banner
                Positioned(
                  top: bannerHeight - 24,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                  ),
                ),
                // Avatar overlapping
                Positioned(
                  top: avatarTop - 10,
                  left: 24,
                  child: GestureDetector(
                    onTap: () => isOwnProfile ? _showAvatarOptions(context) : null,
                    child: Stack(
                      children: [
                        _Avatar(user: user, radius: avatarRadius),
                      ],
                    ),
                  ),
                ),
                // Settings gear icon
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 12,
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
                    onPressed: () => _showSettingsModal(context, ref),
                  ),
                ),
              ],
            ),
          ),

          // ── Username row + follower stats ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    (user?.username.isNotEmpty == true) ? user!.username : 'Usuario',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FollowListModal.show(context, user?.uid ?? '', true),
                  child: _StatPair(
                    value: _formatCount(user?.stats.followersCount ?? 0),
                    label: 'Seguidores',
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FollowListModal.show(context, user?.uid ?? '', false),
                  child: _StatPair(
                    value: _formatCount(user?.stats.followingCount ?? 0),
                    label: 'Siguiendo',
                  ),
                ),
              ],
            ),
          ),

          // ── Bio ───────────────────────────────────────────────────────
          if ((user?.bio ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Text(
                user!.bio,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
            ),

          // ── Vitrina de Insignias ───────────────────────────────────────
          _buildBadgesShowcase(context),

          // ── Action buttons: Seguir + Enviar mensaje ───────────────────
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

          const SizedBox(height: 24),

          // ── Photo grid ────────────────────────────────────────────────
          postsAsync.when(
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, __) => SizedBox(
              height: 200,
              child: Center(
                child: Text('Error: $e', style: const TextStyle(color: Color(0xFFEF5350), fontSize: 12)),
              ),
            ),
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
                        Text(
                          'Aún no tienes publicaciones',
                          style: TextStyle(color: Colors.white38, fontSize: 15),
                        ),
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
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ValueListenableBuilder<Post?>(
                      valueListenable: _draggingPost,
                      builder: (context, draggingPost, _) {
                        final isThisDragging = draggingPost?.id == post.id;
                        return LongPressDraggable<Post>(
                          data: post,
                          maxSimultaneousDrags: 1,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: 110,
                              height: 88,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.redAccent, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: CachedNetworkImage(
                                  imageUrl: ImageUtils.wrapProxy(post.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: ImageUtils.wrapProxy(post.imageUrl),
                                    fit: BoxFit.cover,
                                    color: Colors.black54,
                                    colorBlendMode: BlendMode.darken,
                                  ),
                                  const Center(
                                    child: Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onDragStarted: () {
                            _draggingPost.value = post;
                            ref.read(showBottomNavBarProvider.notifier).state = false;
                          },
                          onDragEnd: (details) {
                            _draggingPost.value = null;
                            _isOverTrash.value = false;
                            ref.read(showBottomNavBarProvider.notifier).state = true;
                          },
                          child: GestureDetector(
                            onTap: () {
                              ImagePreviewWrapper.showPreviewDialog(
                                context,
                                imageUrl: post.imageUrl,
                                username: user?.username ?? '',
                                userPhotoUrl: user?.photoUrl ?? '',
                                profileGradientIndex: user?.profileGradientIndex ?? 0,
                                aspectRatio: 5 / 4,
                                likesCount: post.likesCount,
                                caption: post.caption,
                                isLiked: post.likedBy.contains(ref.read(authStateProvider).value),
                                onLike: () {
                                  final userId = ref.read(authStateProvider).value;
                                  if (userId != null) {
                                    ref.read(likePostControllerProvider).likePost(post.id, userId);
                                  }
                                },
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: ImageUtils.wrapProxy(post.imageUrl),
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: const Color(0xFF1A1A1A)),
                                errorWidget: (_, __, ___) => Container(color: const Color(0xFF1A1A1A)),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    ),
    // Floating trash target overlay
    ValueListenableBuilder<Post?>(
      valueListenable: _draggingPost,
      builder: (context, draggingPost, _) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          bottom: draggingPost != null ? 36 : -120,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: draggingPost == null,
            child: Center(
              child: DragTarget<Post>(
                onWillAcceptWithDetails: (details) {
                  _isOverTrash.value = true;
                  Feedback.forLongPress(context);
                  return true;
                },
                onLeave: (data) {
                  _isOverTrash.value = false;
                },
                onAcceptWithDetails: (details) {
                  _draggingPost.value = null;
                  _isOverTrash.value = false;
                  ref.read(showBottomNavBarProvider.notifier).state = true;
                  _confirmDeletePost(context, details.data, ref);
                },
                builder: (context, candidateData, rejectedData) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _isOverTrash,
                    builder: (context, isHovered, _) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: isHovered ? 90 : 76,
                        height: isHovered ? 90 : 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isHovered
                                ? [Colors.red, Colors.redAccent]
                                : [const Color(0xFF2E1515), const Color(0xFF1C0A0A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: isHovered ? Colors.white : Colors.redAccent.withOpacity(0.5),
                            width: isHovered ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isHovered
                                  ? Colors.redAccent.withOpacity(0.6)
                                  : Colors.redAccent.withOpacity(0.15),
                              blurRadius: isHovered ? 24 : 12,
                              spreadRadius: isHovered ? 6 : 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isHovered ? Icons.delete_forever_rounded : Icons.delete_outline_rounded,
                            color: isHovered ? Colors.white : Colors.redAccent,
                            size: isHovered ? 38 : 30,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    ),
    ],
    ),
    );
  }

  void _showPostDetailModal(BuildContext context, Post post, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final hasCaption = post.caption.isNotEmpty;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pull indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Post Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 5 / 4,
                      child: CachedNetworkImage(
                        imageUrl: ImageUtils.wrapProxy(post.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Post stats and details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likesCount} estrellas',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      if (hasCaption) ...[
                        const SizedBox(height: 8),
                        Text(
                          post.caption,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 24),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextButton.icon(
                    onPressed: () => _confirmDeletePost(context, post, ref, fromBottomSheet: true),
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    label: const Text(
                      'Eliminar publicación',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletePost(BuildContext parentContext, Post post, WidgetRef ref, {bool fromBottomSheet = false}) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          '¿Eliminar publicación?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Esta acción no se puede deshacer. ¿Seguro que quieres borrar este post permanentemente?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog
              Navigator.pop(context);
              // Close bottom sheet if needed
              if (fromBottomSheet) {
                Navigator.pop(parentContext);
              }
              
              // Show loading status
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Text('Eliminando publicación...'),
                    ],
                  ),
                  backgroundColor: Color(0xFF2A2A2A),
                  duration: Duration(seconds: 1),
                ),
              );

              // Execute delete operation
              await ref.read(deletePostControllerProvider).deletePost(post.id, post.imageUrl);

              // Show success
              if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Publicación eliminada correctamente'),
                    backgroundColor: Colors.green,
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

  void _showSettingsModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _SettingsTile(
                icon: Icons.mail_outline_rounded,
                title: 'Email',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      _showEditEmailModal(context, ref);
                    }
                  });
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.person_add_alt_1_outlined,
                title: 'Nombre de usuario',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      _showEditUsernameModal(context, ref);
                    }
                  });
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.edit_outlined,
                title: 'Descripción / Bio',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      _showEditBioModal(context, ref);
                    }
                  });
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.grid_view_rounded,
                title: 'Personalizar widget',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      _showWidgetCustomizer(context, ref);
                    }
                  });
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Personalizar degradado',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      _showGradientPicker(context, ref);
                    }
                  });
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.auto_awesome_outlined,
                title: 'Personalizar banner (Emojis)',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      _showBannerEmojiModal(context, ref);
                    }
                  });
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.phonelink_lock_outlined,
                title: 'Cambiar contraseña',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      _showChangePasswordModal(context, ref);
                    }
                  });
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notificaciones y recordatorios',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      _showNotificationsModal(context, ref);
                    }
                  });
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.block_flipped,
                title: 'Cuentas ocultas/bloqueadas',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      _showHiddenUsersModal(context, ref);
                    }
                  });
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.cancel_outlined,
                title: 'Cerrar sesión',
                onTap: () async {
                  Navigator.of(bottomSheetContext).pop();
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),
              const _Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop();
                      _showDeleteConfirmation(context, ref);
                    },
                    icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Eliminar cuenta',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditUsernameModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        final usernameController = TextEditingController(text: user?.username ?? '');
        bool isLoading = false;
        String? errorMessage;
        
        return StatefulBuilder(
          builder: (stateContext, setState) {
            final keyboardPadding = MediaQuery.of(stateContext).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(
                top: 12,
                bottom: keyboardPadding > 0 ? keyboardPadding + 16 : 24,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.of(sheetContext).pop();
                                    Future.delayed(Duration.zero, () {
                                      if (context.mounted) {
                                        _showSettingsModal(context, ref);
                                      }
                                    });
                                  },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Nombre de usuario',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.2), width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: usernameController,
                        enabled: !isLoading,
                        maxLength: 30,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Tu nombre de usuario...',
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.black45, size: 18),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: isLoading ? null : AppColors.blueGradient,
                            color: isLoading ? Colors.grey[200] : null,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final newUsername = usernameController.text.trim();
                                    if (newUsername.isEmpty) {
                                      setState(() {
                                        errorMessage = 'Por favor, introduce un nombre de usuario.';
                                      });
                                      return;
                                    }
                                    setState(() {
                                      isLoading = true;
                                      errorMessage = null;
                                    });
                                    try {
                                      final authUid = ref.read(authStateProvider).value;
                                      if (authUid == null) throw Exception('Usuario no autenticado.');
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(authUid)
                                          .set({'username': newUsername}, SetOptions(merge: true));
                                      ref.invalidate(currentUserProvider);
                                      if (sheetContext.mounted) {
                                        Navigator.of(sheetContext).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            content: const Text('Nombre de usuario actualizado correctamente.'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                        errorMessage = 'Error al guardar: $e';
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Guardar nombre de usuario',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditEmailModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        final emailController = TextEditingController(text: user?.email ?? '');
        bool isLoading = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (stateContext, setState) {
            final keyboardPadding = MediaQuery.of(stateContext).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(
                top: 12,
                bottom: keyboardPadding > 0 ? keyboardPadding + 16 : 24,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.of(sheetContext).pop();
                                    Future.delayed(Duration.zero, () {
                                      if (context.mounted) {
                                        _showSettingsModal(context, ref);
                                      }
                                    });
                                  },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Correo electrónico',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.2), width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Tu nuevo correo...',
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(Icons.mail_outline_rounded, color: Colors.black45, size: 18),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: isLoading ? null : AppColors.blueGradient,
                            color: isLoading ? Colors.grey[200] : null,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final newEmail = emailController.text.trim();
                                    if (newEmail.isEmpty) {
                                      setState(() {
                                        errorMessage = 'Por favor, introduce un correo electrónico.';
                                      });
                                      return;
                                    }
                                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegex.hasMatch(newEmail)) {
                                      setState(() {
                                        errorMessage = 'Por favor, introduce un correo electrónico válido.';
                                      });
                                      return;
                                    }
                                    setState(() {
                                      isLoading = true;
                                      errorMessage = null;
                                    });
                                    try {
                                      final authUid = ref.read(authStateProvider).value;
                                      if (authUid == null) throw Exception('Usuario no autenticado.');
                                      
                                      bool authUpdated = true;
                                      String? authWarning;
                                      
                                      // 1. Update in Firebase Auth
                                      try {
                                        final currentUser = fba.FirebaseAuth.instance.currentUser;
                                        if (currentUser != null) {
                                          await currentUser.updateEmail(newEmail);
                                        }
                                      } on fba.FirebaseAuthException catch (authError) {
                                        authUpdated = false;
                                        if (authError.code == 'requires-recent-login') {
                                          authWarning = 'Inicia sesión de nuevo para cambiar las credenciales.';
                                        } else {
                                          authWarning = authError.message;
                                        }
                                      } catch (e) {
                                        authUpdated = false;
                                        authWarning = e.toString();
                                      }
                                      
                                      // 2. Update in Firestore
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(authUid)
                                          .set({'email': newEmail}, SetOptions(merge: true));

                                      ref.invalidate(currentUserProvider);
                                      if (sheetContext.mounted) {
                                        Navigator.of(sheetContext).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: authUpdated ? Colors.green : Colors.orangeAccent,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            duration: const Duration(seconds: 5),
                                            content: Text(authUpdated 
                                                ? 'Correo electrónico actualizado correctamente.'
                                                : 'Perfil actualizado. Nota: No se pudo cambiar las credenciales de inicio de sesión (${authWarning ?? "Verificación requerida"}). Modifícalo en Firebase Console si es necesario.'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                        errorMessage = 'Error al guardar: $e';
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Guardar correo electrónico',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditBioModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        final bioController = TextEditingController(text: user?.bio ?? '');
        bool isLoading = false;
        String? errorMessage;
        
        return StatefulBuilder(
          builder: (stateContext, setState) {
            final keyboardPadding = MediaQuery.of(stateContext).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(
                top: 12,
                bottom: keyboardPadding > 0 ? keyboardPadding + 16 : 24,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.of(sheetContext).pop();
                                    Future.delayed(Duration.zero, () {
                                      if (context.mounted) {
                                        _showSettingsModal(context, ref);
                                      }
                                    });
                                  },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Descripción / Bio',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.2), width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: bioController,
                        enabled: !isLoading,
                        maxLines: 4,
                        maxLength: 150,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Cuéntanos algo sobre ti...',
                          hintStyle: const TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: isLoading ? null : AppColors.blueGradient,
                            color: isLoading ? Colors.grey[200] : null,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final newBio = bioController.text.trim();
                                    setState(() {
                                      isLoading = true;
                                      errorMessage = null;
                                    });
                                    try {
                                      final authUid = ref.read(authStateProvider).value;
                                      if (authUid == null) throw Exception('Usuario no autenticado.');
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(authUid)
                                          .set({'bio': newBio}, SetOptions(merge: true));
                                      ref.invalidate(currentUserProvider);
                                      if (sheetContext.mounted) {
                                        Navigator.of(sheetContext).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            content: const Text('Descripción actualizada correctamente.'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                        errorMessage = 'Error al guardar: $e';
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Guardar descripción',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        final currentPasswordController = TextEditingController();
        final newPasswordController = TextEditingController();
        final confirmPasswordController = TextEditingController();
        
        bool isLoading = false;
        String? errorMessage;
        
        bool obscureCurrent = true;
        bool obscureNew = true;
        bool obscureConfirm = true;
        
        return StatefulBuilder(
          builder: (stateContext, setState) {
            final keyboardPadding = MediaQuery.of(stateContext).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(
                top: 12,
                bottom: keyboardPadding > 0 ? keyboardPadding + 16 : 24,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.of(sheetContext).pop();
                                    Future.delayed(Duration.zero, () {
                                      if (context.mounted) {
                                        _showSettingsModal(context, ref);
                                      }
                                    });
                                  },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Cambiar contraseña',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.2), width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        enabled: !isLoading,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Contraseña actual',
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(Icons.vpn_key_outlined, color: Colors.black45, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.black45,
                              size: 18,
                            ),
                            onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final currentUser = fba.FirebaseAuth.instance.currentUser;
                                  if (currentUser == null || currentUser.email == null) {
                                    setState(() {
                                      errorMessage = 'No se pudo obtener tu correo electrónico.';
                                    });
                                    return;
                                  }
                                  final email = currentUser.email!;
                                  setState(() {
                                    isLoading = true;
                                    errorMessage = null;
                                  });
                                  try {
                                    await fba.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (sheetContext.mounted) {
                                      Navigator.of(sheetContext).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.blueAccent,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          content: Text('Hemos enviado un correo de recuperación a: $email'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      isLoading = false;
                                      errorMessage = 'Error al enviar recuperación: $e';
                                    });
                                  }
                                },
                          child: Text(
                            '¿Has olvidado tu contraseña?',
                            style: TextStyle(
                              color: AppColors.primary.withOpacity(0.95),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        enabled: !isLoading,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Nueva contraseña',
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.black45, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.black45,
                              size: 18,
                            ),
                            onPressed: () => setState(() => obscureNew = !obscureNew),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        enabled: !isLoading,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Confirmar nueva contraseña',
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(Icons.check_circle_outline_rounded, color: Colors.black45, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.black45,
                              size: 18,
                            ),
                            onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: isLoading ? null : AppColors.blueGradient,
                            color: isLoading ? Colors.grey[200] : null,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final currentPassword = currentPasswordController.text.trim();
                                    final newPassword = newPasswordController.text.trim();
                                    final confirmPassword = confirmPasswordController.text.trim();
                                    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                                      setState(() {
                                        errorMessage = 'Por favor, rellena todos los campos.';
                                      });
                                      return;
                                    }
                                    if (newPassword.length < 6) {
                                      setState(() {
                                        errorMessage = 'La nueva contraseña debe tener al menos 6 caracteres.';
                                      });
                                      return;
                                    }
                                    if (newPassword != confirmPassword) {
                                      setState(() {
                                        errorMessage = 'La nueva contraseña y la confirmación no coinciden.';
                                      });
                                      return;
                                    }
                                    setState(() {
                                      isLoading = true;
                                      errorMessage = null;
                                    });
                                    try {
                                      final currentUser = fba.FirebaseAuth.instance.currentUser;
                                      if (currentUser == null || currentUser.email == null) {
                                        throw Exception('No se encontró un usuario activo.');
                                      }
                                      final credential = fba.EmailAuthProvider.credential(
                                        email: currentUser.email!,
                                        password: currentPassword,
                                      );
                                      await currentUser.reauthenticateWithCredential(credential);
                                      await currentUser.updatePassword(newPassword);
                                      if (sheetContext.mounted) {
                                        Navigator.of(sheetContext).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            content: const Text('Contraseña actualizada correctamente.'),
                                          ),
                                        );
                                      }
                                    } on fba.FirebaseAuthException catch (e) {
                                      setState(() {
                                        isLoading = false;
                                        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                                          errorMessage = 'La contraseña actual es incorrecta.';
                                        } else if (e.code == 'weak-password') {
                                          errorMessage = 'La nueva contraseña es demasiado débil.';
                                        } else {
                                          errorMessage = e.message ?? 'Ocurrió un error al actualizar la contraseña.';
                                        }
                                      });
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                        errorMessage = 'Error inesperado: $e';
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Guardar nueva contraseña',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNotificationsModal(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final config = Map<String, dynamic>.from(user.notificationConfig);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stateContext, setState) {
            final dailyEnabled = config['dailyReminderEnabled'] ?? true;
            final dailyTime = config['dailyReminderTime'] ?? '20:00';
            final notifyLikes = config['notifyLikes'] ?? true;
            final notifyComments = config['notifyComments'] ?? true;
            final notifyFollowers = config['notifyFollowers'] ?? true;

            return Padding(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 24,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                              Future.delayed(Duration.zero, () {
                                if (context.mounted) {
                                  _showSettingsModal(context, ref);
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Notificaciones y recordatorios',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Reminders Section Title
                      const Text(
                        'RECORDATORIO DIARIO DE HÁBITOS',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Daily reminder Switch
                      _NotificationSwitchTile(
                        title: 'Activar recordatorio diario',
                        subtitle: 'Te enviaremos una alerta para que no pierdas tu racha.',
                        value: dailyEnabled,
                        onChanged: (val) async {
                          setState(() {
                            config['dailyReminderEnabled'] = val;
                          });
                          await _updateNotificationConfig(ref, config);
                        },
                      ),
                      
                      if (dailyEnabled) ...[
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          title: const Text(
                            'Hora del recordatorio',
                            style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dailyTime,
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          onTap: () async {
                            final parts = dailyTime.split(':');
                            final hour = int.tryParse(parts[0]) ?? 20;
                            final minute = int.tryParse(parts[1]) ?? 0;
                            
                            final selectedTime = await showTimePicker(
                              context: stateContext,
                              initialTime: TimeOfDay(hour: hour, minute: minute),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.blueAccent,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black87,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            
                            if (selectedTime != null) {
                              final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                              setState(() {
                                config['dailyReminderTime'] = formattedTime;
                              });
                              await _updateNotificationConfig(ref, config);
                            }
                          },
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Social Notifications Section Title
                      const Text(
                        'NOTIFICACIONES DE ACTIVIDAD',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      _NotificationSwitchTile(
                        title: 'Me gusta',
                        subtitle: 'Cuando a alguien le gusta una de tus publicaciones.',
                        value: notifyLikes,
                        onChanged: (val) async {
                          setState(() {
                            config['notifyLikes'] = val;
                          });
                          await _updateNotificationConfig(ref, config);
                        },
                      ),
                      
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      
                      _NotificationSwitchTile(
                        title: 'Comentarios',
                        subtitle: 'Cuando comentan en uno de tus hábitos o publicaciones.',
                        value: notifyComments,
                        onChanged: (val) async {
                          setState(() {
                            config['notifyComments'] = val;
                          });
                          await _updateNotificationConfig(ref, config);
                        },
                      ),
                      
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      
                      _NotificationSwitchTile(
                        title: 'Nuevos seguidores',
                        subtitle: 'Cuando alguien comienza a seguirte.',
                        value: notifyFollowers,
                        onChanged: (val) async {
                          setState(() {
                            config['notifyFollowers'] = val;
                          });
                          await _updateNotificationConfig(ref, config);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateNotificationConfig(WidgetRef ref, Map<String, dynamic> config) async {
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      final updatedUser = user.copyWith(notificationConfig: config);
      await ref.read(userRepositoryProvider).updateUser(updatedUser);
    }
  }

  void _showHiddenUsersModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final userAsync = ref.watch(currentUserProvider);
                return userAsync.when(
                  data: (user) {
                    if (user == null) return const SizedBox.shrink();
                    final hiddenUsers = user.hiddenUsers;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Header
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  Future.delayed(Duration.zero, () {
                                    if (context.mounted) {
                                      _showSettingsModal(context, ref);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Cuentas ocultas/bloqueadas',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          if (hiddenUsers.isEmpty)
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.block_flipped,
                                      size: 72,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No tienes ninguna cuenta oculta',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Las cuentas que ocultes aparecerán aquí.',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 48),
                                  ],
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: hiddenUsers.length,
                                itemBuilder: (context, index) {
                                  final targetUid = hiddenUsers[index];
                                  return Consumer(
                                    builder: (context, ref, child) {
                                      final targetUserAsync = ref.watch(userByIdProvider(targetUid));
                                      return targetUserAsync.when(
                                        data: (targetUser) {
                                          if (targetUser == null) return const SizedBox.shrink();
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: ListTile(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              leading: CircleAvatar(
                                                radius: 20,
                                                backgroundImage: targetUser.photoUrl.isNotEmpty
                                                    ? NetworkImage(ImageUtils.wrapProxy(targetUser.photoUrl))
                                                    : null,
                                                child: targetUser.photoUrl.isEmpty
                                                    ? const Icon(Icons.person, color: Colors.grey)
                                                    : null,
                                              ),
                                              title: Text(
                                                targetUser.username,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              subtitle: Text(
                                                targetUser.email,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              trailing: TextButton(
                                                onPressed: () => _unblockUser(context, ref, targetUid, targetUser.username),
                                                child: const Text(
                                                  'Desbloquear',
                                                  style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        loading: () => const ListTile(
                                          leading: CircularProgressIndicator(),
                                          title: Text('Cargando usuario...'),
                                        ),
                                        error: (_, __) => const SizedBox.shrink(),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error al cargar datos')),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _unblockUser(BuildContext context, WidgetRef ref, String targetUid, String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('¿Desbloquear a $username?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Volverás a ver las publicaciones de $username en tu feed.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Desbloquear', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        final updatedHidden = List<String>.from(user.hiddenUsers)..remove(targetUid);
        final updatedUser = user.copyWith(hiddenUsers: updatedHidden);
        await ref.read(userRepositoryProvider).updateUser(updatedUser);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.blueAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text('Se ha desbloqueado a $username.'),
            ),
          );
        }
      }
    }
  }

  void _showBannerEmojiModal(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final selectedEmojis = user.bannerEmojiPattern.characters.map((c) => c).toList();
    String selectedStyle = user.bannerEmojiStyle;
    double selectedSize = user.bannerEmojiSize;
    double selectedRotation = user.bannerEmojiRotation;
    double selectedOpacity = user.bannerEmojiOpacity;
    String selectedSeed = user.bannerEmojiSeed.isNotEmpty ? user.bannerEmojiSeed : user.uid;
    double selectedSpacing = user.bannerEmojiSpacing;
    String activeCategory = '😀';

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stateContext, setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(stateContext).size.height * 0.85,
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(stateContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FIXED TOP SECTION: Header + Vista Previa
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                Future.delayed(Duration.zero, () {
                                  if (context.mounted) {
                                    _showSettingsModal(context, ref);
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Patrón de Emojis del Banner',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Live Preview Area
                        const Text(
                          'VISTA PREVIA',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 90,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: user.customGradient.length == 2
                                ? LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(int.parse(user.customGradient[0].replaceAll('#', '0xFF'))),
                                      Color(int.parse(user.customGradient[1].replaceAll('#', '0xFF'))),
                                    ],
                                  )
                                : AppColors.blueGradient,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BannerEmojiDecoration(
                                  emojiString: selectedEmojis.join(''),
                                  style: selectedStyle,
                                  seed: selectedSeed,
                                  size: selectedSize,
                                  rotation: selectedRotation,
                                  opacity: selectedOpacity,
                                  spacingFactor: selectedSpacing,
                                ),
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '@${user.username}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black38,
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // SCROLLABLE CENTER SECTION: Customization controls
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selected Emojis Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'EMOJIS SELECCIONADOS',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                '${selectedEmojis.length} / 15',
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: selectedEmojis.isEmpty
                                      ? const Text(
                                          'Pulsa los emojis de abajo...',
                                          style: TextStyle(color: Colors.black38, fontSize: 13),
                                        )
                                      : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: selectedEmojis.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedEmojis.removeAt(index);
                                                });
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.black12),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      selectedEmojis[index],
                                                      style: const TextStyle(fontSize: 15),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Icon(
                                                      Icons.close_rounded,
                                                      size: 10,
                                                      color: Colors.black38,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                if (selectedEmojis.isNotEmpty) ...[
                                  IconButton(
                                    icon: const Icon(Icons.backspace_outlined, size: 18, color: Colors.black54),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        selectedEmojis.removeLast();
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_sweep_outlined, size: 20, color: Colors.redAccent),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        selectedEmojis.clear();
                                      });
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Emoji Picker Categories
                          const Text(
                            'SELECCIONA EMOJIS',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Tab row
                          Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _emojiCategories.keys.map((category) {
                                final isCatSelected = activeCategory == category;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      activeCategory = category;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: isCatSelected ? Colors.blueAccent : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: isCatSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Emojis Grid
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[50],
                            ),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: _emojiCategories[activeCategory]!.length,
                              itemBuilder: (context, index) {
                                final emoji = _emojiCategories[activeCategory]![index];
                                return GestureDetector(
                                  onTap: () {
                                    if (selectedEmojis.length < 15) {
                                      setState(() {
                                        selectedEmojis.add(emoji);
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Máximo 15 emojis permitidos'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Style Selector
                          const Text(
                            'ESTILO DEL PATRÓN',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 2.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              _buildStyleOption(
                                stateContext,
                                id: 'none',
                                title: 'Ninguno',
                                icon: Icons.close_rounded,
                                isSelected: selectedStyle == 'none',
                                onTap: () => setState(() => selectedStyle = 'none'),
                              ),
                              _buildStyleOption(
                                stateContext,
                                id: 'grid',
                                title: 'Rejilla',
                                icon: Icons.grid_on_rounded,
                                isSelected: selectedStyle == 'grid',
                                onTap: () => setState(() => selectedStyle = 'grid'),
                              ),
                              _buildStyleOption(
                                stateContext,
                                id: 'diagonal',
                                title: 'Diagonal',
                                icon: Icons.texture_rounded,
                                isSelected: selectedStyle == 'diagonal',
                                onTap: () => setState(() => selectedStyle = 'diagonal'),
                              ),
                              _buildStyleOption(
                                stateContext,
                                id: 'scattered',
                                title: 'Disperso',
                                icon: Icons.bubble_chart_rounded,
                                isSelected: selectedStyle == 'scattered',
                                onTap: () {
                                  setState(() {
                                    selectedStyle = 'scattered';
                                    selectedSeed = DateTime.now().microsecondsSinceEpoch.toString();
                                  });
                                },
                              ),
                              _buildStyleOption(
                                stateContext,
                                id: 'radial',
                                title: 'Radial',
                                icon: Icons.blur_circular_rounded,
                                isSelected: selectedStyle == 'radial',
                                onTap: () => setState(() => selectedStyle = 'radial'),
                              ),
                              _buildStyleOption(
                                stateContext,
                                id: 'spiral',
                                title: 'Espiral',
                                icon: Icons.filter_tilt_shift_rounded,
                                isSelected: selectedStyle == 'spiral',
                                onTap: () => setState(() => selectedStyle = 'spiral'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Emoji Size Slider
                          const Text(
                            'TAMAÑO DE EMOJIS',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.format_size_rounded, color: Colors.black54, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Slider(
                                  value: selectedSize,
                                  min: 10.0,
                                  max: 52.0,
                                  divisions: 42,
                                  label: '${selectedSize.toInt()}px',
                                  activeColor: Colors.blueAccent,
                                  inactiveColor: Colors.grey[200],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedSize = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedSize.toInt()}px',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Emoji Spacing Slider
                          const Text(
                            'SEPARACIÓN DE EMOJIS',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.space_bar_rounded, color: Colors.black54, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Slider(
                                  value: selectedSpacing,
                                  min: 0.5,
                                  max: 3.0,
                                  divisions: 25,
                                  label: '${(selectedSpacing * 100).toInt()}%',
                                  activeColor: Colors.blueAccent,
                                  inactiveColor: Colors.grey[200],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedSpacing = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(selectedSpacing * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Emoji Rotation Slider
                          const Text(
                            'ROTACIÓN DE EMOJIS',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.rotate_right_rounded, color: Colors.black54, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Slider(
                                  value: selectedRotation,
                                  min: -180.0,
                                  max: 180.0,
                                  divisions: 72,
                                  label: '${selectedRotation.toInt()}°',
                                  activeColor: Colors.blueAccent,
                                  inactiveColor: Colors.grey[200],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedRotation = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedRotation.toInt()}°',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Emoji Opacity Slider
                          const Text(
                            'OPACIDAD DE EMOJIS',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.opacity, color: Colors.black54, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Slider(
                                  value: selectedOpacity,
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 20,
                                  label: '${(selectedOpacity * 100).toInt()}%',
                                  activeColor: Colors.blueAccent,
                                  inactiveColor: Colors.grey[200],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedOpacity = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(selectedOpacity * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // FIXED BOTTOM SECTION: Save button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.blueGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final updatedUser = user.copyWith(
                              bannerEmojiPattern: selectedEmojis.join(''),
                              bannerEmojiStyle: selectedStyle,
                              bannerEmojiSize: selectedSize,
                              bannerEmojiRotation: selectedRotation,
                              bannerEmojiOpacity: selectedOpacity,
                              bannerEmojiSeed: selectedSeed,
                              bannerEmojiSpacing: selectedSpacing,
                            );
                            await ref.read(userRepositoryProvider).updateUser(updatedUser);
                            
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Guardar Cambios',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStyleOption(
    BuildContext context, {
    required String id,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withOpacity(0.08) : Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blueAccent : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blueAccent : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGradientPicker(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    userAsync.whenData((user) {
      if (user == null) return;
      
      final color1Controller = TextEditingController(text: user.customGradient[0]);
      final color2Controller = TextEditingController(text: user.customGradient[1]);

      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => Padding(
            padding: EdgeInsets.only(
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Future.delayed(Duration.zero, () {
                          if (context.mounted) {
                            _showSettingsModal(context, ref);
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Personalizar degradado',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Introduce los códigos HEX para los dos colores del degradado.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                
                // Preview
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        _parseColor(color1Controller.text),
                        _parseColor(color2Controller.text),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Vista previa',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Color 1
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showColorPresets(context, _parseColor(color1Controller.text), (color) {
                        color1Controller.text = _colorToHex(color);
                        setState(() {});
                      }),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _parseColor(color1Controller.text),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: color1Controller,
                        style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600),
                        maxLength: 7,
                        decoration: InputDecoration(
                          hintText: '#00C6FF',
                          hintStyle: const TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          counterText: '',
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Color 2
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showColorPresets(context, _parseColor(color2Controller.text), (color) {
                        color2Controller.text = _colorToHex(color);
                        setState(() {});
                      }),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _parseColor(color2Controller.text),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: color2Controller,
                        style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600),
                        maxLength: 7,
                        decoration: InputDecoration(
                          hintText: '#0072FF',
                          hintStyle: const TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          counterText: '',
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final c1 = color1Controller.text.trim();
                      final c2 = color2Controller.text.trim();
                      
                      if (!_isValidHex(c1) || !_isValidHex(c2)) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Introduce códigos HEX válidos (ej: #FF0000)')),
                        );
                        return;
                      }

                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({
                          'customGradient': [c1, c2],
                        });
                        
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Error al guardar: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Guardar degradado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return Colors.grey; // Fallback
    }
  }

  bool _isValidHex(String hex) {
    final regExp = RegExp(r'^#[0-9A-Fa-f]{6}$');
    return regExp.hasMatch(hex);
  }

  void _showColorPresets(BuildContext context, Color initialColor, Function(Color) onColorSelected) {
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.blue, Colors.lightBlue, Colors.cyan, Colors.teal,
      Colors.green, Colors.lightGreen, Colors.lime, Colors.yellow,
      Colors.orange, Colors.deepOrange, Colors.brown, Colors.grey,
      Colors.black, Colors.white,
    ];

    double currentHue = HSVColor.fromColor(initialColor).hue;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selecciona un color'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (ctx, index) {
                    final color = colors[index];
                    return GestureDetector(
                      onTap: () {
                        onColorSelected(color);
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'O selecciona un tono específico:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                ColorPicker(
                  pickerColor: initialColor,
                  onColorChanged: onColorSelected,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                  displayThumbColor: true,
                  paletteType: PaletteType.hsvWithHue,
                  labelTypes: const [],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Confirmar este color'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar cuenta',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer y borrará permanentemente todos tus hábitos y publicaciones.',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close confirmation dialog
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingCtx) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              final result = await ref.read(authRepositoryProvider).deleteAccount();

              if (context.mounted) {
                Navigator.of(context).pop(); // Dismiss loading indicator
              }

              result.fold(
                (failure) {
                  showDialog(
                    context: context,
                    builder: (errCtx) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        failure.message,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(errCtx).pop(),
                          style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                },
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cuenta eliminada con éxito.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showWidgetCustomizer(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    userAsync.whenData((user) {
      if (user == null) return;

      final config = user.widgetConfig;
      String widgetType = config['widgetType'] ?? 'streak';
      String widgetBg = config['widgetBg'] ?? 'dark';
      String widgetColor = config['widgetColor'] ?? '#0052FF';
      String selectedHabitId = config['selectedHabitId'] ?? 'all';

      final habits = habitsAsync.value ?? [];

      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        isScrollControlled: true,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) {
            final colors = AppColors.habitColors;
            final globalStreak = ref.read(globalStreakProvider);
            final Color accentColor = _parseColor(widgetColor);
            final bool isDarkBg = widgetBg == 'dark';

            final Color previewAccentColor = isDarkBg ? accentColor : Colors.white;
            final Color previewTextColor = isDarkBg ? Colors.white : Colors.white.withOpacity(0.9);
            final Color previewSubtextColor = isDarkBg ? Colors.white70 : Colors.white.withOpacity(0.7);

            BoxDecoration previewBoxDecoration;
            if (widgetBg == 'dark') {
              previewBoxDecoration = BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                ],
              );
            } else if (widgetBg == 'gradient') {
              previewBoxDecoration = BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _parseColor(user.customGradient[0]),
                    _parseColor(user.customGradient[1]),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              );
            } else {
              previewBoxDecoration = BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Future.delayed(Duration.zero, () {
                            if (context.mounted) {
                              _showSettingsModal(context, ref);
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Personalizar Widget',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Configura la vista previa del widget para tu pantalla de inicio.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: previewBoxDecoration.copyWith(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: SizedBox(
                      height: 110,
                      child: _buildPreviewContent(
                        widgetType: widgetType,
                        globalStreak: globalStreak,
                        previewTextColor: previewTextColor,
                        previewSubtextColor: previewSubtextColor,
                        previewAccentColor: previewAccentColor,
                        habits: habits,
                        selectedHabitId: selectedHabitId,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Tipo de Widget',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSelectionChip(
                        isSelected: widgetType == 'streak',
                        icon: Icons.local_fire_department_rounded,
                        label: 'Racha',
                        onTap: () => setState(() => widgetType = 'streak'),
                      ),
                      const SizedBox(width: 10),
                      _buildSelectionChip(
                        isSelected: widgetType == 'progress',
                        icon: Icons.donut_large_rounded,
                        label: 'Progreso',
                        onTap: () => setState(() => widgetType = 'progress'),
                      ),
                      const SizedBox(width: 10),
                      _buildSelectionChip(
                        isSelected: widgetType == 'star',
                        icon: Icons.star_rounded,
                        label: 'Estrella',
                        onTap: () => setState(() => widgetType = 'star'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Estilo del Fondo',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSelectionChip(
                        isSelected: widgetBg == 'dark',
                        icon: Icons.dark_mode_rounded,
                        label: 'Oscuro',
                        onTap: () => setState(() => widgetBg = 'dark'),
                      ),
                      const SizedBox(width: 10),
                      _buildSelectionChip(
                        isSelected: widgetBg == 'gradient',
                        icon: Icons.gradient_rounded,
                        label: 'Degradado',
                        onTap: () => setState(() => widgetBg = 'gradient'),
                      ),
                      const SizedBox(width: 10),
                      _buildSelectionChip(
                        isSelected: widgetBg == 'solid',
                        icon: Icons.color_lens_rounded,
                        label: 'Color Sólido',
                        onTap: () => setState(() => widgetBg = 'solid'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Color de Acento',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: colors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final colorHex = colors[index];
                        final isSelected = widgetColor == colorHex;
                        final c = _parseColor(colorHex);
                        return GestureDetector(
                          onTap: () => setState(() => widgetColor = colorHex),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (widgetType == 'star') ...[
                    const Text(
                      'Hábito a Destacar',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    if (habits.isEmpty)
                      const Text(
                        'Crea un hábito primero para poder destacarlo aquí.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: habits.any((h) => h.id == selectedHabitId) ? selectedHabitId : habits.first.id,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                          onChanged: (String? val) {
                            if (val != null) {
                              setState(() => selectedHabitId = val);
                            }
                          },
                          items: habits.map<DropdownMenuItem<String>>((h) {
                            return DropdownMenuItem<String>(
                              value: h.id,
                              child: Row(
                                children: [
                                  Icon(
                                    AppColors.habitIconFromString(h.icon),
                                    color: AppColors.habitColorFromHex(h.color),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(h.title),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final updatedConfig = {
                            ...config,
                            'widgetType': widgetType,
                            'widgetBg': widgetBg,
                            'widgetColor': widgetColor,
                            'selectedHabitId': selectedHabitId,
                          };

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({
                            'widgetConfig': updatedConfig
                          });

                          // Update native home screen widget
                          await WidgetUtils.updateNativeWidget(
                            user: user.copyWith(widgetConfig: updatedConfig),
                            habits: habits,
                            globalStreak: globalStreak,
                          );

                          ref.invalidate(currentUserProvider);
                          
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Widget personalizado con éxito!'),
                                backgroundColor: Colors.black,
                              ),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Error al guardar: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Guardar configuración',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPreviewContent({
    required String widgetType,
    required int globalStreak,
    required Color previewTextColor,
    required Color previewSubtextColor,
    required Color previewAccentColor,
    required List<Habit> habits,
    required String selectedHabitId,
  }) {
    if (widgetType == 'streak') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: previewAccentColor,
                size: 28,
              ),
              const SizedBox(width: 6),
              Text(
                'RACHA GLOBAL',
                style: TextStyle(
                  color: previewSubtextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '🔥 ${globalStreak > 0 ? globalStreak : 14} Días',
            style: TextStyle(
              color: previewTextColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '¡Cada día cuenta! Sigue sumando.',
            style: TextStyle(
              color: previewSubtextColor,
              fontSize: 11,
            ),
          ),
        ],
      );
    } else if (widgetType == 'progress') {
      const completed = 4;
      final total = habits.isNotEmpty ? habits.length : 6;
      final double percent = total > 0 ? completed / total : 0.66;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PROGRESO DIARIO',
            style: TextStyle(
              color: previewSubtextColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed de $total completados',
                style: TextStyle(
                  color: previewTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(
                  color: previewAccentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: previewTextColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(previewAccentColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '¡Vas por buen camino hoy!',
            style: TextStyle(
              color: previewSubtextColor,
              fontSize: 10,
            ),
          ),
        ],
      );
    } else {
      final selectedHabit = habits.firstWhere(
        (h) => h.id == selectedHabitId,
        orElse: () => habits.isNotEmpty
            ? habits.first
            : Habit(
                id: 'mock',
                userId: 'mock',
                title: 'Hacer Ejercicio',
                color: '#0052FF',
                icon: 'fitness_center',
                frequency: const HabitFrequency(daysOfWeek: [1, 2, 3]),
                startDate: DateTime.now(),
                completedDates: const {},
              ),
      );

      final completions = selectedHabit.completedDates.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: previewAccentColor,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                'HABITO ESTRELLA',
                style: TextStyle(
                  color: previewSubtextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: previewTextColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  AppColors.habitIconFromString(selectedHabit.icon),
                  color: previewAccentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedHabit.title,
                      style: TextStyle(
                        color: previewTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completions completados en total',
                      style: TextStyle(
                        color: previewSubtextColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSelectionChip({
    required bool isSelected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final User? user;
  final double radius;
  const _Avatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl ?? '';
    final initial = (user?.username.isNotEmpty == true)
        ? user!.username[0].toUpperCase()
        : 'U';

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
            color: AppColors.primary,
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: radius * 0.7,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
          border: Border.all(color: Colors.black, width: 3),
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
              blurRadius: 10,
              spreadRadius: 1.5,
            ),
        ],
        gradient: LinearGradient(
          colors: frame.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(frame.borderWidth),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        padding: const EdgeInsets.all(1.5),
        child: ClipOval(
          child: avatarWidget,
        ),
      ),
    );
  }
}

// ── Stat pair ─────────────────────────────────────────────────────────────────

class _StatPair extends StatelessWidget {
  final String value;
  final String label;
  const _StatPair({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.black45,
        size: 22,
      ),
      onTap: onTap,
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Color(0xFFE0E0E0),
    );
  }
}

class _NotificationSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch.adaptive(
            value: value,
            activeColor: Colors.blueAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

const Map<String, List<String>> _emojiCategories = {
  '😀': [
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇', '🙂', '🙃', '😉', '😌',
    '😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓',
    '😎', '🥸', '🤩', '🥳', '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣', '😖',
    '😫', '😩', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱',
    '😨', '😰', '😥', '😓', '🤗', '🤔', '🫣', '🤭', '🤫', '🤥', '😶', '😐', '😑', '😬', 
    '🫠', '🙄', '😯', '😦', '😧', '😮', '😲', '🥱', '😴', '🤤', '😪', '😵', '😵‍💫', '🤐', 
    '🥴', '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '💵', '🤠', '😈', '👿', '👹', '👺', '💀', 
    '☠️', '💩', '🤡', '👻', '👽', '👾', '🤖', '👋', '🤚', '🖐️', '✋', '🖖', '👌', 
    '🤌', '🤏', '✌️', '🤞', '🫰', '🤟', '🤘', '🤙', '👈', '👉', '👆', '🖕', '👇', '☝️', 
    '👍', '👎', '✊', '👊', '🤛', '🤜', '👏', '🙌', '👐', '🫶', '🤝', '✍️', '💅', '🤳', 
    '💪', '🦾', '🧠'
  ],
  '🐶': [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐽', 
    '🐸', '🐵', '🙈', '🙉', '🙊', '🐒', '🐔', '🐧', '🐦', '🐤', '🐣', '🐥', '🦆', '🦅', 
    '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝', '🐛', '🦋', '🐌', '🐞', '🐜', '🪰', '🪲', 
    '🪳', '🦂', '🕷️', '🕸️', '🐢', '🐍', '🦎', '🦖', '🦕', '🐙', '🦑', '🦞', '🦀', '🐡', 
    '🐠', '🐟', '🐬', '🐳', '🐋', '🦈', '🐊', '🐅', '🐆', '🦓', '🦍', '🦧', '🐘', '🦛', 
    '🦏', '🐪', '🐫', '🦒', '🦘', '🦬', '🐃', '🐂', '🐄', '🐎', '🐖', '🐏', '🐑', '🐐', 
    '🦌', '🐕', '🐩', '🐈', '🐈‍⬛', '🐓', '🦃', '🦤', '🦚', '🦜', '🦢', '🦩', '🕊️', '🐇', 
    '🦝', '🦨', '🦡', '🦦', '🦥', '🐁', '🐀', '🐿️', '🦔', '🐾', '🐉', '🐲', '🌵', '🎄', 
    '🌲', '🌳', '🌴', '🌱', '🌿', '☘️', '🍀', '🍁', '🍂', '🍃', '🍄', '🐚', '🌾', '💐', 
    '🌷', '🌹', '🥀', '🌺', '🌸', '🌼', '🌻', '💮'
  ],
  '🍕': [
    '🍕', '🍔', '🍟', '🌭', '🥪', '🌮', '🌯', '🍳', '🥘', '🍲', '🥣', '🥗', '🍿', 
    '🧈', '🧂', '🥫', '🍱', '🍘', '🍙', '🍚', '🍛', '🍜', '🍝', '🍠', '🍢', '🍣', '🍤', 
    '🍥', '🦪', '🍡', '🥟', '🥠', '🥡', '🍦', '🍧', '🍨', '🍩', '🍪', '🎂', '🍰', '🧁', 
    '🥧', '🍫', '🍬', '🍭', '🍮', '🍯', '🍼', '🥛', '☕', '🫖', '🍵', '🍶', '🍾', '🍷', 
    '🍸', '🍹', '🍺', '🍻', '🥂', '🥃', '🥤', '🧋', '🧃', '🧉', '🧊', '🍇', '🍉', '🍊', 
    '🍋', '🍌', '🍍', '🥭', '🍎', '🍏', '🍐', '🍑', '🍒', '🍓', '🫐', '🥝', '🍅', 
    '🫒', '🥥', '🥑', '🍆', '🥔', '🥕', '🌽', '🌶️', '🫑', '🧅', '🧄', '🍄'
  ],
  '⚽': [
    '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉', '🥏', '🎱', '🪀', '🏓', '🏸', '🏒', 
    '🏑', '🥍', '🏏', '🪃', '⛳', '🏹', '🎣', '🥊', '🥋', '🎽', '🛹', '🛷', 
    '🛼', '🎿', '🏂', '🪂', '🏋️', '🤸', '🚴', '🚵', '🧗', '🧘', '🏆', '🥇', '🥈', 
    '🥉', '🏅', '🎖️', '🎫', '🎗️', '🎟️', '🎭', '🎨', '🎬', '🎤', '🎧', '🎼', '🎹', '🥁', 
    '🪘', '🎷', '🎺', '🎸', '🪕', '🎻', '🎲', '♟️', '🎯', '🎳', '🎮'
  ],
  '🚗': [
    '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐', '🛻', '🚚', '🚛', '🚜', 
    '🛵', '🏍️', '🚲', '🛴', '🦽', '🦼', '🛹', '🛞', '🚂', '🚆', '🚇', '🚈', '🚄', '🚅', 
    '🛸', '🚀', '🚁', '✈️', '⛵', '🛥️', '🚢', '⚓', '🚨', '⛽', '🚧', '🗺️', '🗽', '🗼', 
    '🏰', '🏟️', '🎡', '🎢', '🌋', '🗻', '🏜️', '🏕️', '⛺', '🏠', '🏢', '🏫', '🏪', 
    '🏥'
  ],
  '💡': [
    '💡', '⚡️', '🔥', '💧', '❄️', '✨', '🌟', '⭐', '🌈', '🌪️', '🌀', '🌊', '💨', '☄️', 
    '🪐', '🔭', '🔬', '🛡️', '⚔️', '🏹', '🔑', '🗝️', '🧬', '🧪', '🌡️', '🧭', '🔮', '🧿', 
    '🕯️', '🪔', '🏮', '🎀', '🎁', '🎈', '🎉', '🎊', '🧸', '📧', '✉️', '📦', '✏️', '✒️', 
    '🖌️', '🖍️', '📝', '📁', '💼', '📌', '📎', '🔒', '🔓', '🔏', '🔐', '🔑', '🔨', '⚒️', 
    '🔧', '🔩', '⚙️', '🧱', '⛓️', '🪓', '⛏️', '🧹', '🧺', '🧻', '🛁', '🚿', '🛀', '🧼'
  ],
  '❤️': [
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💖', '💗', '💓', '💞', '💕', 
    '💟', '❣️', '💔', '❤️‍🔥', '❤️‍🩹', '💋', '💯', '💮', '💥', '💫', '💬', '💭', '🗯️', '💤', 
    '🌐', '🌀', '💤', '🔱', '🛟', '〽️', '⚠️', '🚸', '⛔', '🚫', '🚳', '🚭', '🚯', '🚱', 
    '🏳️', '🏴', '🏴‍☠️', '🏁', '🚩', '🏳️‍🌈', '🏳️‍⚧️', '🇪🇸', '🇺🇸', '🇲🇽', '🇦🇷', '🇨🇴', '🇻🇪', 
    '🇧🇷'
  ]
};
