import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_application_1/index.dart';
import 'login/login_page.dart';
import 'core/auth_manager.dart';
import 'core/navigator_key.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/store/task_controller.dart';
import 'package:flutter_application_1/store/message_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 初始化认证管理器
    AuthManager().setNavigatorKey(navigatorKey);

    return GetMaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // 设置登录页为首页
      home: const LoginPage(),
      // 添加路由配置，方便后续跳转
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => Index(key: Index.tabKey),
      },
      initialBinding: BindingsBuilder(() {
        // 注册 TaskController
        Get.put(TaskController());
        // 注册 MessageController
        Get.put(MessageController());
      }),
    );
  }
}
