import 'package:flutter/material.dart';
import 'http_client.dart';
import '../utils/dialog.dart';

/// 认证管理类 - 处理Token失效和登录跳转
class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() => _instance;

  AuthManager._internal();

  GlobalKey<NavigatorState>? _navigatorKey;

  /// 设置导航Key
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;

    // 设置Token失效回调
    HttpClient.setOnTokenExpired(() {
      _handleTokenExpired();
    });
  }

  /// 处理Token失效
  void _handleTokenExpired() {
    print('Token失效，准备跳转到登录页');

    // 延迟执行，确保在UI线程
    Future.delayed(Duration.zero, () async {
      // 先显示提示对话框
      if (_navigatorKey?.currentContext != null) {
        final context = _navigatorKey!.currentContext!;
        DialogWithIcon.showWithoutCancel(
          context: context,
          title: '登录已过期',
          message: '您的登录已过期，请重新登录',
          dialogType: DialogType.WARNING,
          confirmText: '重新登录',
          onConfirm: () {
            // 跳转到登录页
            _navigateToLogin(context);
          },
        );
      }
    });
  }

  /// 跳转到登录页
  void _navigateToLogin(BuildContext context) {
    // 清除所有路由栈，跳转到登录页
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
