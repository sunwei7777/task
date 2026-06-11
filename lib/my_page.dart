import 'package:flutter/material.dart' hide SimpleDialog;
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../store/task_controller.dart';
import '../utils/dialog.dart';
import '../utils/top_notification.dart';
import 'my/setting.dart';
import 'my/check_update_page.dart';
import 'utils/web_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final UpdateService _updateService = UpdateService();

  Map<String, dynamic>? _userInfo;
  String _currentVersion = '';
  bool _hasNewVersion = false;
  String? _latestVersion;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _checkForUpdate();
  }

  // 加载用户信息
  void _loadUserInfo() async {
    final userInfo = await StorageService.getUserInfo();
    if (mounted) {
      setState(() {
        _userInfo = userInfo;
      });
    }
  }

  /// 检查是否有新版本
  Future<void> _checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final buildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

      if (mounted) {
        setState(() => _currentVersion = version);
      }

      final versionInfo = await _updateService.checkUpdate(
        currentVersion: version,
        currentBuildNumber: buildNumber,
      );

      if (versionInfo != null &&
          versionInfo.latestVersion != version &&
          mounted) {
        setState(() {
          _hasNewVersion = true;
          _latestVersion = versionInfo.latestVersion;
        });
      }
    } catch (e) {
      // 静默失败，不影响页面
    }
  }

  // 格式化手机号显示（加密中间4位）
  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return '';
    }
    if (phone.length == 11) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEF2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: Text(
            '个人中心',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 用户信息区域
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  // 头像
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFF0073FF),
                    child: Text(
                      (_userInfo?['realName']?.toString() ?? '?').substring(
                        0,
                        1,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // 用户信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _userInfo?['realName'] ?? '未知用户',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '(${_userInfo?['userId']?.toString().padLeft(6, '0') ?? ''})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatPhoneNumber(
                            _userInfo?['phone'] ?? _userInfo?['userName'],
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 设置按钮
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings, color: Colors.black),
                        SizedBox(height: 2),
                        Text(
                          '设置',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 横幅广告
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Image.asset(
                'lib/assets/mybg.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 12),

            // 功能列表
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // 检查更新
                  _buildMenuItem(
                    icon: Icons.cloud_download,
                    title: '检查更新',
                    subtitle: _currentVersion.isNotEmpty
                        ? '当前 v$_currentVersion'
                        : null,
                    showBadge: _hasNewVersion,
                    badgeText: _latestVersion != null
                        ? 'v$_latestVersion'
                        : null,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckUpdatePage(),
                        ),
                      );
                      // 从更新页面返回后重新检查
                      if (mounted) _checkForUpdate();
                    },
                  ),
                  Container(height: 0.5, color: Colors.grey[200]!),
                  // 隐私政策
                  _buildMenuItem(
                    icon: Icons.local_police,
                    title: '隐私政策',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WebPage(
                            url:
                                'https://www.clevermax.com.cn/private_policy.html',
                            title: '隐私政策',
                          ),
                        ),
                      );
                    },
                  ),
                  Container(height: 0.5, color: Colors.grey[200]!),
                  // 隐私政策
                  _buildMenuItem(
                    icon: Icons.security,
                    title: '用户协议',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WebPage(
                            url:
                                'https://www.clevermax.com.cn/second_file.html',
                            title: '用户协议',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // 退出登录按钮
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text(
                  '退出登录',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示退出登录对话框
  void _showLogoutDialog() {
    DialogWithIcon.show(
      context: context,
      title: '确定退出?',
      message: '退出登录后将无法同步数据',
      dialogType: DialogType.EXIT,
      confirmText: '确定',
      cancelText: '取消',
      onConfirm: () async {
        // 清除当前任务
        Get.find<TaskController>().clearCurrentTask();
        // 清除登录信息和用户信息
        await StorageService.clearLoginInfo();
        await StorageService.clearUserInfo();
        await StorageService.clearToken();
        // 跳转到登录页面，并清除所有路由栈
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
    );
  }

  // 设置测试Token
  void _setTestToken() async {
    // 硬编码的测试Token
    const testToken =
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodWlzYW42NjYiLCJleHAiOjE3NzM4Mzk1MzEsImlhdCI6MTc3MzgwMzUzMSwidXNlcklkIjoiMTY4IiwidXNlcm5hbWUiOiLljY7kuK3nv7AifQ.NaX4nczOLyjSV6iFthhPtrqPQSp2LTSLkZYo4Tt2RD4';

    try {
      await StorageService.saveToken(testToken);
      if (mounted) {
        TopNotification.success(context, '测试Token已设置');
      }
    } catch (e) {
      if (mounted) {
        TopNotification.error(context, 'Token设置失败');
      }
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showBadge = false,
    String? badgeText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.blue.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            if (showBadge && badgeText != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
