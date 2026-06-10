import 'package:flutter/material.dart';
import '../core/navigator_key.dart';

/// 顶部提示组件
class TopNotification {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.red,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      overlayEntry.remove();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // 自动隐藏
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  /// 显示成功提示
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      backgroundColor: const Color(0xFF22C55E),
      icon: Icons.check_circle,
      duration: duration,
    );
  }

  /// 显示错误提示
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      backgroundColor: const Color(0xFFFF4D4F),
      icon: Icons.error,
      duration: duration,
    );
  }

  /// 显示警告提示
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      backgroundColor: const Color(0xFFFFA726),
      icon: Icons.warning,
      duration: duration,
    );
  }

  /// 显示信息提示
  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      backgroundColor: const Color(0xFF4A6CF7),
      icon: Icons.info,
      duration: duration,
    );
  }
}
