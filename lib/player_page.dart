import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  static const String url = "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";

  @override
  Widget build(BuildContext context) {
    var player = FijkPlayer()..setDataSource(url, autoPlay: true);
    return FijkView(player: player);
  }
}
