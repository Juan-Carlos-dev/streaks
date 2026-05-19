import 'dart:io';
import 'dart:ui' as ui;
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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

  @override
  void initState() {
    super.initState();
    _loadImageAspectRatio();
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
            'Pellizca para zoom y arrastra para encuadrar',
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

                          return InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 5.0,
                            boundaryMargin: EdgeInsets.zero,
                            clipBehavior: Clip.none,
                            child: SizedBox(
                              width: childWidth,
                              height: childHeight,
                              child: Image.file(
                                widget.imageFile,
                                fit: BoxFit.fill,
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
