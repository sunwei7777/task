import 'package:flutter/material.dart';
import '../../utils/top_notification.dart';

/// 社交登录按钮
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({Key? key}) : super(key: key);

  void _handleWeChatLogin(BuildContext context) {
    TopNotification.warning(context, '微信登录功能开发中...');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleWeChatLogin(context),
      borderRadius: BorderRadius.circular(25),
      splashColor: const Color(0xFF07C160).withOpacity(0.1),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE1E1E1), width: 1),
        ),
        child: const Icon(Icons.wechat, size: 24, color: Color(0xFF07C160)),
      ),
    );
  }
}
