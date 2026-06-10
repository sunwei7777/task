import 'package:flutter/material.dart';

class CycleTaskExplain extends StatelessWidget {
  const CycleTaskExplain({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 280,
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
                padding: EdgeInsets.all(8),
              ),
            ),

            // 标题
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset('lib/assets/explain.png', width: 16, height: 16),
                  SizedBox(width: 8),
                  Text(
                    '周期任务说明',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // 说明内容
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '周期任务是指：根据设置的周期，系统自动给创建同一任务并分配到设定人员。',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '周期任务需设置周期（如：日、周、月），可分别设置特定一天（例：每月最后一天汇报此任务）',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // 分割线
            Container(height: 1, color: Colors.grey[200]),

            // 我知道了按钮
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '我知道了',
                style: TextStyle(fontSize: 14, color: Color(0xFF0073FF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
