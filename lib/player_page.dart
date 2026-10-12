import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  static const String url = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  late final VideoPlayerController _videoPlayerController;
  late final Future<void> _initializeFuture;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    _initializeFuture = _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _videoPlayerController.initialize();
    if (!mounted) {
      return;
    }
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      errorBuilder: (context, errorMessage) =>
          Padding(padding: const EdgeInsets.all(16), child: Text('视频播放失败：$errorMessage')),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('视频播放')),
      body: SafeArea(
        child: Center(
          child: FutureBuilder<void>(
            future: _initializeFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('视频加载失败：${snapshot.error}'),
                );
              }

              final controller = _chewieController;
              if (snapshot.connectionState != ConnectionState.done || controller == null) {
                return const CircularProgressIndicator();
              }

              return Chewie(controller: controller);
            },
          ),
        ),
      ),
    );
  }
}
