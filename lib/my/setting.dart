import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import '../services/auth_service.dart';
import 'change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await StorageService.getUserInfo();
    if (mounted) setState(() => _userInfo = userInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildInfoCard(context),
            const SizedBox(height: 20),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final name =
        _userInfo?['realName']?.toString() ??
        _userInfo?['userName']?.toString() ??
        '--';
    final phone =
        _userInfo?['phone']?.toString() ??
        _userInfo?['userName']?.toString() ??
        '--';
    final company = _userInfo?['companyName']?.toString() ?? 'Task';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoItem('企业', company),
          // _buildAvatarItem(),
          _buildInfoItem('姓名', name),
          _buildInfoItem('手机号码', phone),
          // _buildInfoItemWithAction(
          //   '登录密码',
          //   '••••••••',
          //   '修改',
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const ChangePasswordPage(),
          //       ),
          //     );
          //   },
          // ),
          // _buildInfoItemWithAction('邮箱', 'tanbig@mingyuanyun.com', '修改'),
          // _buildTagsItem('部门', ['超级APP组', '销售部', '客服部']),
          // _buildTagsItem('角色', ['部门主管', '组长']),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A1A)),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItemWithAction(
    String label,
    String value,
    String actionText, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    actionText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C5AA0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          const Text(
            '头像',
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2C5AA0), Color(0xFF1E3A7A)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      (_userInfo?['realName']?.toString() ?? '?').substring(
                        0,
                        1,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsItem(String label, List<String> tags) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: tags.map((tag) => _buildTag(tag)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF2C5AA0),
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          final phone =
              _userInfo?['phone']?.toString() ??
              _userInfo?['userName']?.toString() ??
              '';
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('确认注销'),
              content: const Text('注销后数据将无法恢复，确定要注销账号吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _handleDeleteUser(phone);
                  },
                  child: const Text(
                    '确定',
                    style: TextStyle(color: Color(0xFFE53E3E)),
                  ),
                ),
              ],
            ),
          );
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE53E3E)),
          ),
        ),
        child: const Text(
          '注销账号',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFE53E3E),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteUser(String phone) async {
    try {
      final authService = AuthService();
      final result = await authService.deleteUser(phone: phone);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '账户已注销'),
            duration: const Duration(seconds: 2),
          ),
        );
        // 清除本地数据并跳转到登录页
        await authService.logout();
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '注销失败'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String msg;
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        msg = (data is Map)
            ? (data['errorMsg']?.toString() ??
                  data['message']?.toString() ??
                  '注销失败')
            : '注销失败';
      } else if (e is Exception) {
        msg = e.toString().replaceFirst('Exception: ', '');
      } else {
        msg = '网络异常，请检查网络连接';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
    }
  }
}
