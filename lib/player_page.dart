import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final VideoPlayerController _videoPlayerController;
  late final Future<void> _initializeFuture;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
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

              return GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('提示'),
                      content: const Text('需要下载本视频吗？'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('关闭'),
                        ),
                        TextButton(
                          onPressed: () {
                            _downloadVideo(widget.videoUrl);
                          },
                          child: const Text('下载'),
                        ),
                      ],
                    ),
                  );
                },
                child: Chewie(controller: controller),
              );
            },
          ),
        ),
      ),
    );
  }

  void _downloadVideo(String url) async {
    // 在这里添加下载视频的逻辑
    debugPrint('Downloading video: $url');

    final Directory dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else if (Platform.isMacOS) {
      dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationSupportDirectory();
    }
    await dir.create(recursive: true);

    String savePath = '${dir.path}/video.mp4';

    // 开始下载视频并显示下载进度
    var result = await Dio().download(
      url,
      savePath,
      onReceiveProgress: (count, total) {
        String progress = '${(count / total * 100).toInt()}%';
        debugPrint('下载进度: $progress');
      },
    );

    if (result.statusCode == 200) {
      debugPrint('Download successful: ${result.data}');
    } else {
      debugPrint('Download failed with status: ${result.statusCode}');
    }
  }
}
