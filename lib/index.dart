import 'package:flutter/material.dart';
import 'package:flutter_application_1/float_button.dart';
import 'package:flutter_application_1/home_page.dart';
import 'package:flutter_application_1/message_page.dart';
import 'package:flutter_application_1/my_page.dart';
import 'package:flutter_application_1/task_page.dart';
import 'tabbar.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  int _currentIndex = 0;

  // 页面列表
  final List<Widget> _pages = [
    // 首页
    Stack(children: [HomePage(), FloatButton()]),
    // 任务
    Stack(children: [TaskPage(), FloatButton()]),
    // 消息
    MessagePage(),
    // 我的
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Tabbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
