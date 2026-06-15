// services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../core/http_client.dart';
import '../config/api_config.dart';
import '../store/task_controller.dart';
import 'storage_service.dart';
import 'websocket_service.dart';

class AuthService {
  final HttpClient _httpClient = HttpClient();

  // 登录
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        ApiConfig.login,
        data: {'userName': phone, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // 检查登录是否成功
        if (data['code'] == true && data['result'] != null) {
          // token 在 result 对象里面
          final token = data['result']['token']?.toString() ?? '';

          // 保存 token
          if (token.isNotEmpty) {
            await StorageService.saveToken(token);
          }

          // 保存用户信息
          await StorageService.saveUserInfo(data['result']);

          // 登录成功，建立 WebSocket 连接
          WebSocketService().connect();

          return {
            'success': true,
            'token': token,
            'message': '登录成功',
            'userInfo': data['result'],
          };
        } else {
          return {'success': false, 'message': data['errorMsg'] ?? '登录失败'};
        }
      } else {
        return {'success': false, 'message': '网络错误：${response.statusCode}'};
      }
    } catch (e) {
      String msg;
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        msg = (data is Map)
            ? (data['errorMsg']?.toString() ??
                  data['message']?.toString() ??
                  e.message ??
                  '登录失败')
            : (e.message ?? '登录失败');
      } else {
        msg = e.toString().replaceFirst('Exception: ', '');
      }
      return {'success': false, 'message': msg};
    }
  }

  // 注册
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String rePassword,
  }) async {
    try {
      final response = await _httpClient.post(
        ApiConfig.register,
        data: {
          'phone': phone,
          'password': password,
          'rePassword': rePassword,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] == true) {
          return {
            'success': true,
            'message': data['errorMsg']?.toString() ?? '注册成功',
          };
        } else {
          return {
            'success': false,
            'message': data['errorMsg']?.toString() ?? '注册失败',
          };
        }
      } else {
        return {'success': false, 'message': '网络错误：${response.statusCode}'};
      }
    } catch (e) {
      String msg;
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        msg = (data is Map)
            ? (data['errorMsg']?.toString() ??
                  data['message']?.toString() ??
                  e.message ??
                  '注册失败')
            : (e.message ?? '注册失败');
      } else {
        msg = e.toString().replaceFirst('Exception: ', '');
      }
      return {'success': false, 'message': msg};
    }
  }

  // 注销账户
  Future<Map<String, dynamic>> deleteUser({required String phone}) async {
    try {
      final response = await _httpClient.post(
        ApiConfig.deleteUser,
        data: {'phone': phone},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] == true) {
          return {
            'success': true,
            'message': data['errorMsg']?.toString() ?? '账户已注销',
          };
        } else {
          return {
            'success': false,
            'message': data['errorMsg']?.toString() ?? '注销失败',
          };
        }
      } else {
        return {'success': false, 'message': '网络错误：${response.statusCode}'};
      }
    } catch (e) {
      String msg;
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        msg = (data is Map)
            ? (data['errorMsg']?.toString() ??
                  data['message']?.toString() ??
                  e.message ??
                  '注销失败')
            : (e.message ?? '注销失败');
      } else {
        msg = e.toString().replaceFirst('Exception: ', '');
      }
      return {'success': false, 'message': msg};
    }
  }

  // 退出登录
  Future<void> logout() async {
    // 断开 WebSocket
    WebSocketService().disconnect();
    // 清除当前任务
    Get.find<TaskController>().clearCurrentTask();
    // 清除本地 token
    await StorageService.clearToken();
    await StorageService.clearLoginInfo();
    await StorageService.clearUserInfo();
  }

  // 手动设置 token（用于测试或调试）
  Future<void> setTestToken(String token) async {
    await StorageService.saveToken(token);
    print('[AuthService] 测试 Token 已设置');
  }
}
