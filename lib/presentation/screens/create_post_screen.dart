import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/habit.dart';
import '../providers/feed_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/habit_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  File? _imageFile;
  final _picker = ImagePicker();
  Habit? _selectedHabit;
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (pickedFile != null) {
      final File rawFile = File(pickedFile.path);
      
      if (!mounted) return;
      final File? croppedFile = await Navigator.of(context).push<File?>(
        MaterialPageRoute(
          builder: (context) => ImageCropperDialog(imageFile: rawFile),
        ),
      );

      if (croppedFile != null) {
        setState(() => _imageFile = croppedFile);
      }
    }
  }

  void _submit() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen')),
      );
      return;
    }
    if (_selectedHabit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un hábito')),
      );
      return;
    }

    final uid = ref.read(authStateProvider).value;
    if (uid == null) return;

    final newPost = Post(
      id: const Uuid().v4(),
      userId: uid,
      habitId: _selectedHabit!.id,
      imageUrl: '',
      caption: _captionController.text.trim(),
      likesCount: 0,
      habitStreakSnapshot: _selectedHabit!.calculatedStreak,
      timestamp: DateTime.now(),
    );

    setState(() => _isLoading = true);
    try {
      await ref.read(createPostControllerProvider.notifier).createPost(
            post: newPost,
            imageFile: _imageFile!,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nueva publicación'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              size: 48, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          const Text('Toca para añadir foto',
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Hábito asociado',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            habitsAsync.when(
              data: (habits) {
                final today = DateTime.now();
                final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                
                final completedHabits = habits.where((h) => h.completedDates.containsKey(dateKey)).toList();

                if (completedHabits.isEmpty) {
                  return const Text('No tienes hábitos completados hoy para compartir',
                      style: TextStyle(color: AppColors.textHint));
                }
                
                // Validar que el hábito seleccionado sigue existiendo en la lista filtrada
                if (_selectedHabit != null && !completedHabits.any((h) => h.id == _selectedHabit!.id)) {
                  _selectedHabit = null;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Habit>(
                      value: _selectedHabit,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      hint: const Text('Selecciona un hábito completado hoy',
                          style: TextStyle(color: AppColors.textHint)),
                      items: completedHabits.map((h) {
                        return DropdownMenuItem(
                          value: h,
                          child: Text(h.title,
                              style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedHabit = v),
                    ),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe una descripción...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Compartir'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageCropperDialog extends StatefulWidget {
  final File imageFile;

  const ImageCropperDialog({super.key, required this.imageFile});

  @override
  State<ImageCropperDialog> createState() => _ImageCropperDialogState();
}

class _ImageCropperDialogState extends State<ImageCropperDialog> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isProcessing = false;
  double? _imageAspectRatio;

  // Custom gesture states
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  // Starting values for scale/drag gestures
  double _startScale = 1.0;
  Offset _startOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadImageAspectRatio();
  }

  void _onScaleChanged(double scale) {
    setState(() {
      _scale = scale;
      // When changing zoom slider, reset translation to center
      _offset = Offset.zero;
    });
  }

  void _loadImageAspectRatio() {
    final Image image = Image.file(widget.imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _imageAspectRatio = info.image.width / info.image.height;
            });
          }
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          print('Error loading image dimensions: $exception');
          if (mounted) {
            setState(() {
              _imageAspectRatio = 1.0; // fallback
            });
          }
        },
      ),
    );
  }

  Future<void> _cropAndSave() async {
    setState(() => _isProcessing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final RenderRepaintBoundary? boundary =
          _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception("No se pudo iniciar el proceso de recorte");
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Error al procesar los píxeles de la imagen");
      }
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = Directory.systemTemp;
      final File croppedFile = File(
        '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await croppedFile.writeAsBytes(pngBytes);

      if (mounted) {
        Navigator.of(context).pop(croppedFile);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al encuadrar la imagen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageAspectRatio == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Encuadrar foto', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isProcessing)
            TextButton(
              onPressed: _cropAndSave,
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Arrastra para encuadrar y usa la barra para zoom',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 20),
          // Viewfinder Container
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AspectRatio(
                aspectRatio: 5 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: Container(
                      color: const Color(0xFF1E1E1E),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final viewportWidth = constraints.maxWidth;
                          final viewportHeight = constraints.maxHeight;
                          final viewportRatio = viewportWidth / viewportHeight;

                          double childWidth;
                          double childHeight;

                          if (_imageAspectRatio! > viewportRatio) {
                            // Landscape: height matches viewport, width overflows
                            childHeight = viewportHeight;
                            childWidth = viewportHeight * _imageAspectRatio!;
                          } else {
                            // Portrait: width matches viewport, height overflows
                            childWidth = viewportWidth;
                            childHeight = viewportWidth / _imageAspectRatio!;
                          }

                          // Calculate maximum panning bounds dynamically based on scale
                          final double maxOffsetX = (childWidth * _scale - viewportWidth) / 2;
                          final double maxOffsetY = (childHeight * _scale - viewportHeight) / 2;

                          // Clamp the offset to keep image edges aligned with viewport edges
                          final double clampedX = maxOffsetX > 0 ? _offset.dx.clamp(-maxOffsetX, maxOffsetX) : 0.0;
                          final double clampedY = maxOffsetY > 0 ? _offset.dy.clamp(-maxOffsetY, maxOffsetY) : 0.0;
                          
                          final clampedOffset = Offset(clampedX, clampedY);
                          if (clampedOffset != _offset) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _offset = clampedOffset;
                                });
                              }
                            });
                          }

                          return GestureDetector(
                            onScaleStart: (details) {
                              _startScale = _scale;
                              _startOffset = _offset;
                            },
                            onScaleUpdate: (details) {
                              setState(() {
                                if (details.scale != 1.0) {
                                  _scale = (_startScale * details.scale).clamp(1.0, 3.0);
                                }
                                _offset = _startOffset + details.focalPointDelta;
                              });
                            },
                            child: Container(
                              color: Colors.transparent,
                              width: viewportWidth,
                              height: viewportHeight,
                              child: ClipRect(
                                child: OverflowBox(
                                  minWidth: 0.0,
                                  minHeight: 0.0,
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity,
                                  child: Transform(
                                    transform: Matrix4.identity()
                                      ..translate(_offset.dx, _offset.dy)
                                      ..scale(_scale),
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: childWidth,
                                      height: childHeight,
                                      child: Image.file(
                                        widget.imageFile,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Zoom Slider Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                const Icon(Icons.zoom_out_rounded, color: Colors.white54, size: 20),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.amber,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.amber,
                      overlayColor: Colors.amber.withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _scale,
                      min: 1.0,
                      max: 3.0,
                      onChanged: _onScaleChanged,
                    ),
                  ),
                ),
                const Icon(Icons.zoom_in_rounded, color: Colors.white54, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
