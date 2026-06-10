import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../config/api_config.dart';
import '../services/storage_service.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  const VideoPreview({super.key, required this.url});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final uri = _resolveVideoUri(widget.url);
      final token = await StorageService.getToken();
      final httpHeaders = token == null || token.isEmpty
          ? const <String, String>{}
          : <String, String>{'Token': token};

      final controller = VideoPlayerController.networkUrl(
        uri,
        formatHint: _getFormatHint(uri),
        httpHeaders: httpHeaders,
        viewType: VideoViewType.platformView,
      );
      _controller = controller;
      controller.addListener(_onControllerChanged);

      await controller.initialize();
      await controller.play();

      if (!mounted) return;
      setState(() => _initialized = true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  Uri _resolveVideoUri(String url) {
    final value = url.trim();
    final uri = Uri.tryParse(value);

    if (uri == null) {
      throw Exception('视频地址格式错误');
    }

    if (uri.hasScheme) {
      return uri;
    }

    return Uri.parse(ApiConfig.baseUrl).resolve(value);
  }

  VideoFormat _getFormatHint(Uri uri) {
    final path = uri.path.toLowerCase();
    if (path.endsWith('.m3u8')) return VideoFormat.hls;
    if (path.endsWith('.mpd')) return VideoFormat.dash;
    if (path.endsWith('.ism') || path.endsWith('.isml')) {
      return VideoFormat.ss;
    }
    return VideoFormat.other;
  }

  void _onControllerChanged() {
    final controller = _controller;
    if (controller == null || !mounted) return;

    final value = controller.value;
    if (value.hasError && _error == null) {
      setState(() => _error = value.errorDescription ?? '视频加载失败');
      return;
    }

    if (_initialized) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_onControllerChanged);
      controller.dispose();
    }
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _controller;
    if (!_initialized || controller == null) return;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam, size: 80, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('视频加载失败', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized || controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final aspectRatio = controller.value.aspectRatio == 0
        ? 16 / 9
        : controller.value.aspectRatio;

    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        Positioned(
          top: 40,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: _togglePlayback,
            child: Icon(
              controller.value.isPlaying
                  ? Icons.pause_circle
                  : Icons.play_circle,
              size: 60,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }
}
