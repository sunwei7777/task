import 'package:flutter/material.dart';
import 'package:flutter_application_1/toast_custom.dart';

class InputNum extends StatefulWidget {
  const InputNum({Key? key}) : super(key: key);

  @override
  _InputNumState createState() => _InputNumState();
}

class _InputNumState extends State<InputNum> {
  int _quantity = 0;
  TextEditingController _remarkController = TextEditingController();

  void _increment() {}

  void _decrement() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '黑色 L',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, size: 20, color: Colors.black),
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: Colors.grey[300]!),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '汇报',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _increment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0073FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          minimumSize: Size(60, 32),
                        ),
                        child: Text(
                          '增加',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _decrement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          minimumSize: Size(60, 32),
                        ),
                        child: Text(
                          '减少',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    '数量',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: '$_quantity'),
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF0073FF),
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    '备注',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _remarkController,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      hintText: '输入内容',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: .5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      minimumSize: Size(0, 48),
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 提交成功toast提示
                      Navigator.pop(context, _quantity);
                      ToastCustom.showToast(context, '提交成功');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0073FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      minimumSize: Size(0, 48),
                    ),
                    child: Text(
                      '确定',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
