import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// 检查相册权限（仅 Android 需要，iOS 由插件自动处理）
  static Future<bool> ensurePhotoPermission(BuildContext context) async {
    if (Platform.isIOS) return true;
    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showDialog(context, '相册', '请在系统设置中开启存储权限，以便选择图片。');
      return false;
    }
    final result = await Permission.storage.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) {
      _showDialog(context, '相册', '请在系统设置中开启存储权限，以便选择图片。');
    }
    return false;
  }

  /// 检查相机权限（仅 Android 需要，iOS 由插件自动处理）
  static Future<bool> ensureCameraPermission(BuildContext context) async {
    if (Platform.isIOS) return true;
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showDialog(context, '相机', '请在系统设置中开启相机权限。');
      return false;
    }
    final result = await Permission.camera.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) {
      _showDialog(context, '相机', '请在系统设置中开启相机权限。');
    }
    return false;
  }

  /// 检查麦克风权限（仅 Android 需要，iOS 由插件自动处理）
  static Future<bool> ensureMicrophonePermission(BuildContext context) async {
    if (Platform.isIOS) return true;
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showDialog(context, '麦克风', '请在系统设置中开启麦克风权限。');
      return false;
    }
    final result = await Permission.microphone.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) {
      _showDialog(context, '麦克风', '请在系统设置中开启麦克风权限。');
    }
    return false;
  }

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
