import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../config/api_config.dart';
import '../services/storage_service.dart';

class VideoThumbnail extends StatefulWidget {
  final String? url;
  final File? file;
  final double width;
  final double height;
  final VoidCallback? onTap;

  /// 网络视频缩略图
  const VideoThumbnail({
    super.key,
    required this.url,
    this.file,
    this.width = 40,
    this.height = 40,
    this.onTap,
  });

  /// 本地文件视频缩略图
  const VideoThumbnail.fromFile({
    super.key,
    required this.file,
    this.url,
    this.width = 40,
    this.height = 40,
    this.onTap,
  });

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final VideoPlayerController controller;

      if (widget.file != null) {
        // 本地文件
        controller = VideoPlayerController.file(
          widget.file!,
          viewType: VideoViewType.platformView,
        );
      } else {
        // 网络视频
        final uri = _resolveVideoUri(widget.url!);
        final token = await StorageService.getToken();
        final httpHeaders = token == null || token.isEmpty
            ? const <String, String>{}
            : <String, String>{'Token': token};

        controller = VideoPlayerController.networkUrl(
          uri,
          formatHint: _getFormatHint(uri),
          httpHeaders: httpHeaders,
          viewType: VideoViewType.platformView,
        );
      }

      _controller = controller;

      await controller.initialize();
      // 定位到第一帧
      await controller.seekTo(Duration.zero);

      if (!mounted) return;
      setState(() => _initialized = true);
    } catch (e) {
      // 加载失败时保持默认黑色背景+播放图标
      if (mounted) {
        setState(() => _initialized = true);
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 已初始化且有可用 controller 时，显示第一帧缩略图
    if (_initialized &&
        _controller != null &&
        _controller!.value.isInitialized) {
      return GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: VideoPlayer(_controller!)),
                // 播放图标覆盖层
                const Icon(
                  Icons.play_circle_fill,
                  size: 18,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 加载中或加载失败时，显示默认黑色背景+播放图标
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Icon(Icons.play_circle_fill, size: 24, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
