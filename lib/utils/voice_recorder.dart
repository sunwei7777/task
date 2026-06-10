import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorder {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _audioPath;
  Function(bool)? _onRecordingStatusChanged;

  // 初始化录音机
  Future<void> initRecorder() async {
    try {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();

      // 请求录音权限
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw Exception('录音权限被拒绝');
      }
      print('录音机初始化成功');
    } catch (e) {
      print('录音机初始化失败: $e');
      _recorder = null;
    }
  }

  // 开始录音
  Future<void> _startRecording() async {
    try {
      // 检查录音机是否初始化
      if (_recorder == null) {
        await initRecorder();
      }

      // 获取临时目录
      final directory = await getTemporaryDirectory();
      _audioPath = '${directory.path}/recording.aac';

      // 开始录音
      await _recorder!.startRecorder(toFile: _audioPath, codec: Codec.aacADTS);

      _isRecording = true;
      // 通知状态变化
      _onRecordingStatusChanged?.call(_isRecording);
      print('开始录音: $_audioPath');
    } catch (e) {
      print('录音开始失败: $e');
      // 显示错误提示
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('录音开始失败: $e')));
    }
  }

  // 停止录音
  Future<void> _stopRecording(BuildContext context) async {
    try {
      await _recorder!.stopRecorder();

      _isRecording = false;
      // 通知状态变化
      _onRecordingStatusChanged?.call(_isRecording);
      print('录音结束: $_audioPath');

      // 这里可以添加发送录音的逻辑
      _sendVoiceMessage(context);
    } catch (e) {
      print('录音停止失败: $e');
    }
  }

  // 发送语音消息
  void _sendVoiceMessage(BuildContext context) {
    if (_audioPath != null) {
      // 这里可以实现发送语音消息的逻辑
      // 例如上传到服务器，或者保存到本地
      print('发送语音消息: $_audioPath');

      // 模拟发送成功
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('语音消息发送成功')));
    }
  }

  // 显示语音录制界面
  void showVoiceRecorder(BuildContext context) {
    // 在显示界面时就初始化录音
    initRecorder();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // 使用StatefulBuilder来更新UI
        return StatefulBuilder(
          builder: (context, setState) {
            // 设置状态变化回调
            _onRecordingStatusChanged = (isRecording) {
              setState(() {
                // 这里的setState会更新StatefulBuilder内的UI
              });
            };

            return Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRecording ? '录音中...' : '按住录音',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isRecording ? Colors.red : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 40),
                  GestureDetector(
                    onLongPressStart: (details) {
                      // 开始录音
                      _startRecording();
                    },
                    onLongPressEnd: (details) {
                      // 结束录音并发送
                      _stopRecording(context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Color(0xFF0073FF),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Icon(Icons.mic, size: 50, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    '松开结束',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 释放资源
  void dispose() {
    _recorder?.closeRecorder();
  }
}
