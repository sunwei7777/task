import 'package:flutter/material.dart';

class DialogCustom extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String leftButtonText;
  final String rightButtonText;
  final VoidCallback? onRightButtonPressed;
  final VoidCallback? onLeftButtonPressed;

  const DialogCustom({
    super.key,
    this.title = '操作成功！',
    this.description = '您的操作已完成',
    this.icon = Icons.check,
    this.iconColor = Colors.green,
    this.leftButtonText = '关闭',
    this.rightButtonText = '去查看',
    this.onRightButtonPressed,
    this.onLeftButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 计算弹窗宽度，左右各留20边距
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth - 40; // 左右各留20

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: dialogWidth, // 最大宽度限制为500
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 关闭按钮
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: 20, color: Colors.grey),
              ),
            ),

            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            SizedBox(height: 16),

            // 标题
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),

            // 描述
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // 按钮区域
            Container(
              height: 44,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // 左侧按钮
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (onLeftButtonPressed != null) {
                          onLeftButtonPressed!();
                        }
                      },
                      style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        leftButtonText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),

                  // 分割线
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: Colors.grey[200],
                  ),

                  // 右侧按钮
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (onRightButtonPressed != null) {
                          onRightButtonPressed!();
                        }
                      },
                      style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        rightButtonText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0073FF),
                        ),
                      ),
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
}
