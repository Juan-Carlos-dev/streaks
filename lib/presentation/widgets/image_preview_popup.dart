import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_utils.dart';

class ImagePreviewWrapper extends StatefulWidget {
  final String imageUrl;
  final String username;
  final String userPhotoUrl;
  final int profileGradientIndex;
  final double aspectRatio;
  final int? likesCount;
  final String? caption;
  final bool isLiked;
  final VoidCallback? onLike;
  final Widget child;

  const ImagePreviewWrapper({
    super.key,
    required this.imageUrl,
    required this.username,
    required this.userPhotoUrl,
    required this.profileGradientIndex,
    required this.aspectRatio,
    this.likesCount,
    this.caption,
    required this.isLiked,
    this.onLike,
    required this.child,
  });

  static void showPreviewDialog(
    BuildContext context, {
    required String imageUrl,
    required String username,
    required String userPhotoUrl,
    required int profileGradientIndex,
    required double aspectRatio,
    int? likesCount,
    String? caption,
    required bool isLiked,
    VoidCallback? onLike,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, anim1, anim2) {
        return PreviewOverlayWidget(
          imageUrl: imageUrl,
          username: username,
          userPhotoUrl: userPhotoUrl,
          profileGradientIndex: profileGradientIndex,
          aspectRatio: aspectRatio,
          likesCount: likesCount,
          caption: caption,
          isLiked: isLiked,
          onDismiss: () => Navigator.of(context).pop(),
          onLike: onLike,
        );
      },
    );
  }

  @override
  State<ImagePreviewWrapper> createState() => _ImagePreviewWrapperState();
}

class _ImagePreviewWrapperState extends State<ImagePreviewWrapper> {
  OverlayEntry? _overlayEntry;
  final GlobalKey<PreviewOverlayWidgetState> _overlayKey = GlobalKey<PreviewOverlayWidgetState>();
  bool _isShowing = false;

  void _showPreview() {
    if (_isShowing) return;
    _isShowing = true;

    // Trigger haptic feedback
    Feedback.forLongPress(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => PreviewOverlayWidget(
        key: _overlayKey,
        imageUrl: ImageUtils.wrapProxy(widget.imageUrl),
        username: widget.username,
        userPhotoUrl: widget.userPhotoUrl.isNotEmpty ? ImageUtils.wrapProxy(widget.userPhotoUrl) : '',
        profileGradientIndex: widget.profileGradientIndex,
        aspectRatio: widget.aspectRatio,
        likesCount: widget.likesCount,
        caption: widget.caption,
        isLiked: widget.isLiked,
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePreview() {
    if (!_isShowing) return;
    _isShowing = false;
    _overlayKey.currentState?.dismiss();
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ImagePreviewWrapper.showPreviewDialog(
          context,
          imageUrl: widget.imageUrl,
          username: widget.username,
          userPhotoUrl: widget.userPhotoUrl,
          profileGradientIndex: widget.profileGradientIndex,
          aspectRatio: widget.aspectRatio,
          likesCount: widget.likesCount,
          caption: widget.caption,
          isLiked: widget.isLiked,
          onLike: widget.onLike,
        );
      },
      onLongPressStart: (_) => _showPreview(),
      onLongPressEnd: (_) => _hidePreview(),
      onLongPressCancel: () => _hidePreview(),
      child: widget.child,
    );
  }
}

class PreviewOverlayWidget extends StatefulWidget {
  final String imageUrl;
  final String username;
  final String userPhotoUrl;
  final int profileGradientIndex;
  final double aspectRatio;
  final int? likesCount;
  final String? caption;
  final bool isLiked;
  final VoidCallback onDismiss;
  final VoidCallback? onLike;

  const PreviewOverlayWidget({
    super.key,
    required this.imageUrl,
    required this.username,
    required this.userPhotoUrl,
    required this.profileGradientIndex,
    required this.aspectRatio,
    this.likesCount,
    this.caption,
    required this.isLiked,
    required this.onDismiss,
    this.onLike,
  });

  @override
  State<PreviewOverlayWidget> createState() => PreviewOverlayWidgetState();
}

class PreviewOverlayWidgetState extends State<PreviewOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _showStarAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  Future<void> triggerStarAnimation() async {
    Feedback.forLongPress(context);
    setState(() {
      _showStarAnimation = true;
    });
    // Wait for the star popup to complete its animation before dismissing
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFooter = widget.likesCount != null || (widget.caption != null && widget.caption!.isNotEmpty);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: GestureDetector(
              onTap: dismiss,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
              ),
            ),
          ),
          // Preview Card and Actions Column
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.88,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Avatar
                                  _buildAvatar(),
                                  const SizedBox(width: 10),
                                  // Username
                                  Text(
                                    widget.username.isNotEmpty ? widget.username : 'Usuario',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Image with Double Tap support
                            GestureDetector(
                              onDoubleTap: () {
                                if (widget.onLike != null && !widget.isLiked) {
                                  triggerStarAnimation().then((_) {
                                    widget.onLike!();
                                    dismiss();
                                  });
                                }
                              },
                              child: AspectRatio(
                                aspectRatio: widget.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: const Color(0xFF121212),
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: const Color(0xFF121212),
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                                    if (_showStarAnimation)
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.4, end: 1.0),
                                        duration: const Duration(milliseconds: 550),
                                        curve: Curves.elasticOut,
                                        builder: (context, scale, child) {
                                          return Transform.scale(
                                            scale: scale,
                                            child: AnimatedOpacity(
                                              opacity: _showStarAnimation ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 250),
                                              child: const Icon(
                                                Icons.star_rounded,
                                                color: Colors.amber,
                                                size: 110,
                                                shadows: [
                                                  Shadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 4))
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            // Footer (likes & caption)
                            if (hasFooter)
                              Container(
                                padding: const EdgeInsets.all(14),
                                color: const Color(0xFF161616),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.likesCount != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            color: Colors.amber,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${widget.likesCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (widget.likesCount != null && widget.caption != null && widget.caption!.isNotEmpty)
                                      const SizedBox(height: 8),
                                    if (widget.caption != null && widget.caption!.isNotEmpty)
                                      Text(
                                        widget.caption!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13.5,
                                          height: 1.4,
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionsBar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsBar() {
    final Color activeColor = widget.isLiked ? Colors.redAccent : Colors.amber;
    final Color iconColor = widget.isLiked ? Colors.amber : Colors.white70;
    final String text = widget.isLiked ? 'Quitar estrella' : 'Destacar';

    return GestureDetector(
      onTap: () {
        if (widget.onLike != null) {
          if (!widget.isLiked) {
            triggerStarAnimation().then((_) {
              widget.onLike!();
              dismiss();
            });
          } else {
            widget.onLike!();
            dismiss();
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.isLiked ? Icons.star_rounded : Icons.star_outline_rounded,
              color: iconColor,
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.userPhotoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: CachedNetworkImageProvider(widget.userPhotoUrl),
      );
    }
    final gradientIndex = widget.profileGradientIndex.clamp(0, AppColors.profileGradients.length - 1);
    final colors = AppColors.profileGradients[gradientIndex];
    return Container(
      width: 32,
      height: 32,
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
          (widget.username.isNotEmpty ? widget.username[0] : 'U').toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
