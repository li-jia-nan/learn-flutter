import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/player_page.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

const playerApp = MaterialApp(
  home: PlayerPage(videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
);

void main() {
  late VideoPlayerPlatform originalPlatform;
  late FakeVideoPlayerPlatform platform;

  setUp(() {
    originalPlatform = VideoPlayerPlatform.instance;
    platform = FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = platform;
  });

  tearDown(() {
    VideoPlayerPlatform.instance = originalPlatform;
  });

  testWidgets('Loads, autoplays, reuses and releases the player', (tester) async {
    await tester.pumpWidget(playerApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    platform.initializeVideo();
    await tester.pumpAndSettle();

    final controller = tester.widget<Chewie>(find.byType(Chewie)).controller;
    expect(controller.videoPlayerController.value.isPlaying, isTrue);
    expect(platform.isPlaying, isTrue);
    expect(platform.sources.single.uri, endsWith('/bee.mp4'));

    tester.element(find.byType(PlayerPage)).markNeedsBuild();
    await tester.pump();
    expect(platform.sources, hasLength(1));
    expect(tester.widget<Chewie>(find.byType(Chewie)).controller, same(controller));

    await controller.pause();
    await tester.pumpAndSettle();
    expect(platform.isPlaying, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(platform.disposeCount, 1);
  });

  testWidgets('Shows initialization failures instead of loading forever', (tester) async {
    await tester.pumpWidget(playerApp);

    platform.failVideo('Unable to load video');
    await tester.pumpAndSettle();

    expect(find.textContaining('视频加载失败'), findsOneWidget);
    expect(find.textContaining('Unable to load video'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Chewie), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(platform.disposeCount, 1);
  });

  testWidgets('Shows errors that occur during playback', (tester) async {
    await tester.pumpWidget(playerApp);
    platform.initializeVideo();
    await tester.pumpAndSettle();

    platform.failVideo('Playback interrupted');
    await tester.pumpAndSettle();

    expect(find.text('视频播放失败：Playback interrupted'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  });

  testWidgets('Releases the player when leaving before creation completes', (tester) async {
    platform.creationGate = Completer<void>();
    await tester.pumpWidget(playerApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    platform.creationGate!.complete();
    await tester.pump();

    expect(platform.disposeCount, 1);
    expect(platform.isPlaying, isFalse);
    expect(tester.takeException(), isNull);
  });
}

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final List<DataSource> sources = [];
  late final StreamController<VideoEvent> _events;
  Completer<void>? creationGate;
  bool isPlaying = false;
  int disposeCount = 0;

  void initializeVideo() {
    _events.add(
      VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 30),
        size: const Size(640, 360),
      ),
    );
  }

  void failVideo(String message) {
    _events.addError(PlatformException(code: 'VideoError', message: message));
  }

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    sources.add(options.dataSource);
    _events = StreamController<VideoEvent>.broadcast();
    await creationGate?.future;
    return 1;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _events.stream;

  @override
  Widget buildViewWithOptions(VideoViewOptions options) => const SizedBox.expand();

  @override
  Future<void> play(int playerId) async => isPlaying = true;

  @override
  Future<void> pause(int playerId) async => isPlaying = false;

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Future<void> dispose(int playerId) async {
    disposeCount++;
    await _events.close();
  }
}
