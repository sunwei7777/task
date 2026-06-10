import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      image: DecorationImage(
                        image: AssetImage('lib/assets/user.png'),
                        fit: BoxFit.cover,
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
                              '张三',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '(001762)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          '188 **** 5288',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 设置按钮
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.settings, color: Colors.black),
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
                    subtitle: '当前 v1.0',
                    showBadge: true,
                    badgeText: '新版本',
                  ),
                  Container(height: 0.5, color: Colors.grey[200]!),
                  // 隐私政策
                  _buildMenuItem(icon: Icons.shield, title: '隐私政策'),
                  Container(height: 0.5, color: Colors.grey[200]!),
                  // 关于我们
                  _buildMenuItem(icon: Icons.info, title: '关于我们'),
                ],
              ),
            ),

            SizedBox(height: 30),

            // 退出登录按钮
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  // 退出登录逻辑
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showBadge = false,
    String? badgeText,
  }) {
    return Container(
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
    );
  }
}
