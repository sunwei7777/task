import 'package:flutter/material.dart';

class DialogWithIcon extends StatelessWidget {
  final String title;
  final String message;
  final DialogType dialogType;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCancel;

  const DialogWithIcon({
    Key? key,
    required this.title,
    required this.message,
    required this.dialogType,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.onConfirm,
    this.onCancel,
    this.showCancel = true,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    required DialogType dialogType,
    String confirmText = '确定',
    String cancelText = '取消',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    bool showCancel = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => DialogWithIcon(
        title: title,
        message: message,
        dialogType: dialogType,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showCancel: showCancel,
      ),
    );
  }

  /// 只显示确认按钮的对话框
  static Future<T?> showWithoutCancel<T>({
    required BuildContext context,
    required String title,
    required String message,
    required DialogType dialogType,
    String confirmText = '确定',
    VoidCallback? onConfirm,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => DialogWithIcon(
        title: title,
        message: message,
        dialogType: dialogType,
        confirmText: confirmText,
        onConfirm: onConfirm,
        showCancel: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标和标题在同一行
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 图标
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getIconBgColor(),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(_getIconData(), size: 18, color: _getIconColor()),
                ),
                SizedBox(width: 10),

                // 标题
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // 描述信息 - 使用 Row 包裹来实现对齐
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 占位空间，宽度等于图标宽度 + 间距
                SizedBox(width: 46),
                // 消息文本
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // 按钮组
            Row(
              children: [
                // 取消按钮（可选）
                if (showCancel) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (onCancel != null) onCancel!();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Color(0xFFF3F4F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                ],
                // 确认按钮
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onConfirm != null) onConfirm!();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: _getButtonColor(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (dialogType) {
      case DialogType.WARNING:
        return Icons.warning_amber_outlined;
      case DialogType.ERROR:
        return Icons.error_outline;
      case DialogType.SUCCESS:
        return Icons.check_circle_outline;
      case DialogType.INFO:
        return Icons.info_outline;
      case DialogType.EXIT:
      default:
        return Icons.logout_outlined;
    }
  }

  Color _getIconColor() {
    switch (dialogType) {
      case DialogType.WARNING:
        return Colors.orange.shade600;
      case DialogType.ERROR:
      case DialogType.EXIT:
        return Colors.red.shade600;
      case DialogType.SUCCESS:
        return Colors.green.shade600;
      case DialogType.INFO:
        return Colors.blue.shade600;
      default:
        return Colors.red.shade600;
    }
  }

  Color _getIconBgColor() {
    switch (dialogType) {
      case DialogType.WARNING:
        return Colors.orange.shade50;
      case DialogType.ERROR:
      case DialogType.EXIT:
        return Colors.red.shade50;
      case DialogType.SUCCESS:
        return Colors.green.shade50;
      case DialogType.INFO:
        return Colors.blue.shade50;
      default:
        return Colors.red.shade50;
    }
  }

  Color _getButtonColor() {
    switch (dialogType) {
      case DialogType.WARNING:
        return Colors.orange.shade600;
      case DialogType.ERROR:
      case DialogType.EXIT:
        return Colors.red.shade600;
      case DialogType.SUCCESS:
        return Colors.green.shade600;
      case DialogType.INFO:
        return Colors.blue.shade600;
      default:
        return Colors.red.shade600;
    }
  }
}

enum DialogType { EXIT, WARNING, ERROR, SUCCESS, INFO }
