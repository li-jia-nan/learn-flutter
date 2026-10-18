import 'dart:convert';

class VideoController {
  // 本地 mock 数据，模拟接口返回的网络数据
  static const _serverData =
      """{"title": "default title", "url": "default url", "playCount": 888}""";

  Map<String, dynamic> _videoData = {};

  void init() {
    _videoData = fetchVideoData();
  }

  String get title => _videoData['title'] ?? '';
  String get url => _videoData['url'] ?? '';
  int get playCount => _videoData['playCount'] ?? 0;

  // 从服务端拉取视频数据
  Map<String, dynamic> fetchVideoData() {
    return jsonDecode(_serverData);
  }
}
