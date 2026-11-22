
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AutoCutApp());
}

class AutoCutApp extends StatelessWidget {
  const AutoCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoCut',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090B10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker picker = ImagePicker();

  VideoPlayerController? controller;

  bool loading = false;

  Future<void> pickVideo() async {
    try {
      final XFile? file = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (file == null || !mounted) return;

      setState(() {
        loading = true;
      });

      final newController = VideoPlayerController.file(
        File(file.path),
      );

      await newController.initialize();

      if (!mounted) {
        await newController.dispose();
        return;
      }

      final oldController = controller;

      setState(() {
        controller = newController;
        loading = false;
      });

      await oldController?.dispose();

    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video Error: $e'),
        ),
      );
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget featureButton(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF171A24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 27,
              color: const Color(0xFFAC8AFF),
            ),
            const SizedBox(height: 9),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = controller;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090B10),
        title: const Text(
          'AutoCut',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.auto_awesome,
              color: Color(0xFFAC8AFF),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Create Amazing Videos',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Simple editing. Smarter results.',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),

              const SizedBox(height: 25),

              GestureDetector(
                onTap: loading ? null : pickVideo,

                child: Container(
                  height: 220,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: const Color(0xFF171A24),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF7651C8),
                      width: 1.2,
                    ),
                  ),

                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : video != null &&
                              video.value.isInitialized
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio:
                                      video.value.aspectRatio,
                                  child: VideoPlayer(video),
                                ),
                              ),
                            )
                          : const Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_library_outlined,
                                  size: 55,
                                  color: Color(0xFFAC8AFF),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Upload Your Video',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 7),
                                Text(
                                  'Select a video from your gallery',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),

              if (video != null &&
                  video.value.isInitialized) ...[

                const SizedBox(height: 12),

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (video.value.isPlaying) {
                            video.pause();
                          } else {
                            video.play();
                          }
                        });
                      },
                      icon: Icon(
                        video.value.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        size: 38,
                        color: const Color(0xFFAC8AFF),
                      ),
                    ),

                    const Text('Video Preview'),

                    const Spacer(),

                    TextButton(
                      onPressed: pickVideo,
                      child: const Text('Change Video'),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 27),

              const Text(
                'Editing Tools',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,

                children: [

                  featureButton(
                    Icons.content_cut,
                    'Trim Video',
                    () => showMessage(
                      'Trim feature coming next',
                    ),
                  ),

                  featureButton(
                    Icons.graphic_eq,
                    'Audio Effects',
                    () => showMessage(
                      'Audio feature coming next',
                    ),
                  ),

                  featureButton(
                    Icons.branding_watermark_outlined,
                    'Watermark Tools',
                    () => showMessage(
                      'Watermark tools coming next',
                    ),
                  ),

                  featureButton(
                    Icons.auto_awesome,
                    'Auto Edit',
                    () => showMessage(
                      'Automatic editing coming next',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(19),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF49318B),
                      Color(0xFF211B3D),
                    ],
                  ),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Icon(
                      Icons.auto_awesome,
                      size: 30,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Copyright-Safe Auto Edit',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Upload your video and let AutoCut '
                      'prepare it with licensed audio and effects.',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
