import 'package:flutter/material.dart';
import 'package:flutter_application_1/task/create_task_page.dart';

class FloatButton extends StatefulWidget {
  const FloatButton({super.key});

  @override
  State<FloatButton> createState() => _FloatButtonState();
}

class _FloatButtonState extends State<FloatButton> {
  // 可拖拽悬浮按钮状态
  double? _screenWidth;
  double? _screenHeight;
  Offset? _fabOffset; // 初始位置

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _fabOffset ??= Offset(_screenWidth! - 60, _screenHeight! - 120); // 初始位置

    return Positioned(
      left: _fabOffset?.dx ?? 0,
      top: _fabOffset?.dy ?? 0,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskPage()),
          );
        },
        onPanUpdate: (details) {
          setState(() {
            _fabOffset = (_fabOffset ?? Offset.zero) + details.delta;
          });
        },
        onPanEnd: (details) {
          // 贴边逻辑
          _snapToEdge();
        },
        child: Container(
          width: 56,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset('lib/assets/xf.png'),
        ),
      ),
    );
  }

  // 贴边逻辑
  void _snapToEdge() {
    setState(() {
      // 水平贴边
      if (_fabOffset!.dx < _screenWidth! / 2) {
        _fabOffset = Offset(4, _fabOffset!.dy); // 贴左边
      } else {
        _fabOffset = Offset(_screenWidth! - 60, _fabOffset!.dy); // 贴右边
      }

      // 垂直边界检查
      if (_fabOffset!.dy < 24) {
        _fabOffset = Offset(_fabOffset!.dx, 24); // 距离顶部最小20
      } else if (_fabOffset!.dy > _screenHeight! - 120) {
        _fabOffset = Offset(_fabOffset!.dx, _screenHeight! - 120); // 距离底部最小120
      }
    });
  }
}
