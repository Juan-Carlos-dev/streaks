import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/habit.dart';
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

  const _ProfileBody({
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

    return SingleChildScrollView(
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
                      gradient: AppColors.blueGradient,
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
                    onTap: () => _changeProfilePhoto(context),
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
                _StatPair(
                  value: _formatCount(user?.stats.followersCount ?? 0),
                  label: 'Seguidores',
                ),
                const SizedBox(width: 24),
                _StatPair(
                  value: _formatCount(user?.stats.followingCount ?? 0),
                  label: 'Siguiendo',
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

          const SizedBox(height: 16),

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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: ImageUtils.wrapProxy(posts[index].imageUrl),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: const Color(0xFF1A1A1A)),
                        errorWidget: (_, __, ___) => Container(color: const Color(0xFF1A1A1A)),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 100),
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
              _SettingsTile(icon: Icons.mail_outline_rounded, title: 'Email', onTap: () {}),
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
              _SettingsTile(icon: Icons.notifications_none_rounded, title: 'Notificaciones y recordatorios', onTap: () {}),
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
                      _showDeleteConfirmation(context);
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: color1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Color 1 (HEX)',
                          hintText: '#00C6FF',
                          border: OutlineInputBorder(),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: color2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Color 2 (HEX)',
                          hintText: '#0072FF',
                          border: OutlineInputBorder(),
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar cuenta',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.error)),
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
