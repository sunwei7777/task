// 定义样式类
import 'package:flutter/material.dart';

class AppStyles {
  static const TextStyle fontMax = TextStyle(fontSize: 18);

  static const TextStyle fontMiddle = TextStyle(fontSize: 16);

  static const TextStyle fontmin = TextStyle(fontSize: 14);

  static const TextStyle fontmini = TextStyle(fontSize: 12);

  static final InputBorder borderBottom = UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
  );

  static final InputBorder enabledBorderBottom = UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
  );

  static final InputBorder focusedBorderBottom = UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.blue, width: 0.5),
  );

  static final InputBorder border = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
  );

  static final InputBorder enabledBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
  );

  static final InputBorder focusedBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue, width: 1),
  );
}
