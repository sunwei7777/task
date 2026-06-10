import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/store/message_controller.dart';

class Tabbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Tabbar({super.key, required this.currentIndex, required this.onTap});

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> {
  final int _taskCount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.assignment),
                // 工作任务消息提示
                if (_taskCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        _taskCount > 99 ? '99' : _taskCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon: Obx(() {
              final count = Get.isRegistered<MessageController>()
                  ? Get.find<MessageController>().totalUnreadCount.value
                  : 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.message),
                  if (count > 0)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          count > 99 ? '99' : count.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }),
            label: '消息',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
        selectedItemColor: Color(0xFF477DF3),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
