import 'package:flutter/material.dart';
import 'package:flutter_application_1/assets/app_styles.dart';

class Common {
  static const Map<String, Color> statusBgColor = {
    '待处理': Color(0xFF409EFF),
    '已超时': Color(0xFFff0000),
    '已完成': Color(0xFF67c23a),
    '已取消': Color(0xFF909090),
    '进行中': Color(0xFF67c23a),
    '待开始': Color(0xFF409EFF),
    '预计延误': Color(0xFFff0000),
  };

  static Widget topBar(
    BuildContext context,
    String title, {
    bool showCloseButton = false,
  }) => Container(
    color: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Column(
      children: [
        // 拖拽指示器
        // Container(
        //   width: 40,
        //   height: 4,
        //   margin: EdgeInsets.symmetric(vertical: 12),
        //   decoration: BoxDecoration(
        //     color: Colors.grey[300],
        //     borderRadius: BorderRadius.circular(2),
        //   ),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 36, height: 36, color: Colors.transparent),
            Text(title, style: AppStyles.fontMax),
            Container(
              width: 36,
              height: 36,
              color: Colors.transparent,
              child: showCloseButton
                  ? IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 20),
                    )
                  : null,
            ),
          ],
        ),
      ],
    ),
  );
}
