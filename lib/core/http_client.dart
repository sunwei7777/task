import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../services/storage_service.dart';
import '../utils/top_notification.dart';
import 'navigator_key.dart';

/// HTTP客户端封装类
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  late final Dio _dio;
  static void Function()? _onTokenExpired;

  factory HttpClient() => _instance;

  HttpClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _setupInterceptors();
  }

  /// 设置Token失效回调
  static void setOnTokenExpired(Function() callback) {
    _onTokenExpired = callback;
  }

  /// 设置拦截器
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加Token
          final token = await StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Token'] = token;
          }

          // 打印请求信息
          if (kDebugMode) {
            _printRequest(options);
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            _printResponse(response);
          }
          final data = response.data;
          // 非 JSON 响应（如下载文件）直接放行
          if (data is! Map) return handler.next(response);
          if (data['code'] == true) return handler.next(response);
          final errorMsg = data['errorMsg'] ?? '请求失败';
          // silentError: 跳过自动弹窗，由调用方自行处理错误
          final silent = response.requestOptions.extra['silentError'] == true;
          if (!silent && navigatorKey.currentContext != null) {
            TopNotification.error(navigatorKey.currentContext!, errorMsg);
          }
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              message: errorMsg,
            ),
          );
        },
        onError: (error, handler) {
          // 处理401 Token失效错误
          if (error.response?.statusCode == 401) {
            // 清除本地token
            StorageService.clearToken();
            StorageService.clearLoginInfo();

            print('Token已失效，请重新登录');

            // 通知上层跳转到登录页
            _onTokenExpired?.call();

            // 创建一个新的401错误，不再继续传递
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                type: error.type,
                error: 'Token已失效',
              ),
            );
          }

          // 打印错误信息
          if (kDebugMode) {
            _printError(error);
          }

          // 统一错误处理
          return handler.next(error);
        },
      ),
    );
  }

  /// 打印请求信息
  void _printRequest(RequestOptions options) {
    print('======= API 请求 =======');
    print('请求地址: ${options.baseUrl}${options.path}');
    print('请求方式: ${options.method}');
    print('请求参数: ${options.data}');
    print('请求头: ${options.headers}');
    print('查询参数1: ${options.queryParameters}');
    print('=======================');
  }

  /// 打印响应信息
  void _printResponse(Response response) {
    print('======= API 响应 =======');
    print('响应状态码: ${response.statusCode}');
    print('响应数据: ${response.data}');
    print('响应头: ${response.headers}');
    print('=======================');
  }

  /// 打印错误信息
  void _printError(DioException error) {
    print('======= API 错误 =======');
    print('错误类型: ${error.type}');
    print('错误消息: ${error.message}');
    print('响应状态码: ${error.response?.statusCode}');
    print('响应数据: ${error.response?.data}');
    print('=======================');
  }

  /// GET请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  /// POST请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool silentError = false,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: silentError ? Options(extra: {'silentError': true}) : options,
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  /// 文件上传
  Future<Response> uploadFile(
    String path, {
    required File file,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        ...?data,
      });

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  /// 文件下载
  Future<Response> downloadFile(
    String url, {
    required String savePath,
    ProgressCallback? onReceiveProgress,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: options,
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  /// 获取Dio实例（用于自定义请求）
  Dio get dio => _dio;
}
