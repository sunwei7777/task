import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// 检查相册权限，无权限时弹窗引导设置
  static Future<bool> ensurePhotoPermission(BuildContext context) async {
    final status = await _photoStatus();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showDialog(context, '相册', '请在系统设置中开启相册访问权限，以便选择图片。');
      return false;
    }

    final result = await _photoRequest();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) {
      _showDialog(context, '相册', '请在系统设置中开启相册访问权限，以便选择图片。');
    }
    return false;
  }

  /// 检查相机权限，无权限时弹窗引导设置
  static Future<bool> ensureCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showDialog(context, '相机', '请在系统设置中开启相机权限，以便拍摄照片。');
      return false;
    }

    final result = await Permission.camera.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) {
      _showDialog(context, '相机', '请在系统设置中开启相机权限，以便拍摄照片。');
    }
    return false;
  }

  /// 检查麦克风权限，无权限时弹窗引导设置
  static Future<bool> ensureMicrophonePermission(BuildContext context) async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showDialog(context, '麦克风', '请在系统设置中开启麦克风权限，以便录制视频。');
      return false;
    }

    final result = await Permission.microphone.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) {
      _showDialog(context, '麦克风', '请在系统设置中开启麦克风权限，以便录制视频。');
    }
    return false;
  }

  static Future<PermissionStatus> _photoStatus() async {
    if (Platform.isIOS) return Permission.photos.status;
    if (await _isAndroid13Plus()) return Permission.photos.status;
    return Permission.storage.status;
  }

  static Future<PermissionStatus> _photoRequest() async {
    if (Platform.isIOS || await _isAndroid13Plus())
      return Permission.photos.request();
    return Permission.storage.request();
  }

  static Future<bool> _isAndroid13Plus() async => Platform.isAndroid;

  static void _showDialog(
    BuildContext context,
    String permissionName,
    String content,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('需要$permissionName权限'),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }
}
