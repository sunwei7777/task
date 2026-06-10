import 'package:flutter/material.dart';

class ToastCustom {
  static void showToast(BuildContext context, String title, String message) {
    final overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 60),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800]?.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 感叹号图标
                  Icon(Icons.error, color: Colors.white, size: 44),
                  SizedBox(height: 16),
                  // 标题
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  // 消息内容
                  Text(
                    message,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // 3秒后移除Toast
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry?.remove();
    });
  }
}
