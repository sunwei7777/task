import 'package:flutter/material.dart';

class ToastCustom {
  static void showToast(BuildContext context, String message) {
    final overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 80,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // 2秒后移除Toast
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry?.remove();
    });
  }
}
