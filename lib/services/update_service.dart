import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/http_client.dart';
import '../models/version_info.dart';

/// 更新服务
class UpdateService {
  static const String _versionCheckUrl = '/taskManage/api/version/check';

  final HttpClient _httpClient = HttpClient();

  /// 检查更新
  /// [currentVersion] 当前版本号
  /// [currentBuildNumber] 当前构建号
  Future<VersionInfo?> checkUpdate({
    required String currentVersion,
    required int currentBuildNumber,
  }) async {
    try {
      final response = await _httpClient.post(
        _versionCheckUrl,
        data: {
          'current_version': currentVersion,
        },
      );

      final result = response.data['result'];
      if (result == null) return null;

      final hasUpdate = result['has_update'] ?? false;

      // 有新版本，返回 version_info
      if (hasUpdate && result['version_info'] != null) {
        return VersionInfo.fromJson(result['version_info']);
      }

      // 无新版本，用 history 构造
      final historyList = (result['history'] as List?)
              ?.map((e) => VersionHistory.fromJson(e))
              .toList() ??
          [];

      return VersionInfo(
        latestVersion: currentVersion,
        buildNumber: currentBuildNumber,
        downloadUrl: '',
        fileSize: 0,
        forceUpdate: false,
        updateLog: '',
        releaseDate: DateTime.now().toString().substring(0, 10),
        history: historyList,
      );
    } catch (e) {
      debugPrint('检查更新失败: $e');
      return null;
    }
  }

  /// 下载并安装更新
  Future<void> downloadAndInstall({
    CancelToken? cancelToken,
    required VersionInfo versionInfo,
    required Function(double progress) onProgress,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      // 请求存储权限
      if (!await _requestStoragePermission()) {
        onError('存储权限被拒绝');
        return;
      }

      // 获取下载目录
      final directory = await _getDownloadDirectory();

      // 创建 Updates 子目录
      final updatesDir = Directory('${directory.path}/Updates');
      if (!await updatesDir.exists()) {
        await updatesDir.create(recursive: true);
      }

      final filePath =
          '${updatesDir.path}/app_${versionInfo.latestVersion}.apk';

      // 如果文件已存在，先删除
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      debugPrint('开始下载: ${versionInfo.downloadUrl}');
      debugPrint('保存路径: $filePath');

      // 下载文件
      await _httpClient.dio.download(
        versionInfo.downloadUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            final percentage = (progress * 100).toStringAsFixed(1);
            debugPrint('下载进度: $percentage% ($received / $total)');
            onProgress(progress);
          } else {
            debugPrint('已下载: $received bytes');
          }
        },
      );

      debugPrint('下载完成，准备安装');

      // 安装APK
      final result = await OpenFilex.open(filePath);

      debugPrint('打开结果: ${result.type}');

      if (result.type == ResultType.done) {
        onSuccess();
      } else {
        onError('打开文件失败');
      }
    } catch (e) {
      debugPrint('下载失败: $e');
      onError('下载失败: $e');
    }
  }

  /// 请求存储权限
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (Platform.version.contains('33') || Platform.version.contains('34')) {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  /// 获取下载目录
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) return directory;
      return await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  /// 保存已忽略的版本号
  Future<void> ignoreVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_version/ignored', version);
  }

  /// 获取已忽略的版本号
  Future<String?> getIgnoredVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_version/ignored');
  }

  /// 检查是否应该显示更新提示
  Future<bool> shouldShowUpdate(VersionInfo versionInfo) async {
    if (versionInfo.forceUpdate) return true;
    final ignoredVersion = await getIgnoredVersion();
    return ignoredVersion != versionInfo.latestVersion;
  }
}
