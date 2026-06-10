import 'package:flutter/material.dart';
import 'package:flutter_application_1/assets/app_styles.dart';
import 'package:flutter_application_1/utils/common.dart';
import 'package:flutter_application_1/utils/top_notification.dart';

class InputNum extends StatefulWidget {
  final double initialValue;
  final String title;
  final String? unit;

  const InputNum({
    super.key,
    this.initialValue = 0,
    this.title = '',
    this.unit,
  });

  @override
  _InputNumState createState() => _InputNumState();
}

class _InputNumState extends State<InputNum> {
  late final TextEditingController _quantityController = TextEditingController(
    text: widget.initialValue.toString(),
  );

  void _increment() {
    final current = double.tryParse(_quantityController.text) ?? 0;
    _quantityController.text = (current + 1).toString();
  }

  void _decrement() {
    final current = double.tryParse(_quantityController.text) ?? 0;
    if (current > 0) {
      _quantityController.text = (current - 1).toString();
    }
  }

  void _submit() {
    final value = double.tryParse(_quantityController.text.trim());
    if (value == null) {
      TopNotification.show(
        context,
        message: '请输入有效数量',
        backgroundColor: Colors.orange,
      );
      return;
    }
    Navigator.pop(context, value);
  }

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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Common.topBar(context, widget.title, showCloseButton: true),
          Container(height: 0.5, color: Colors.grey[300]!),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row(
                  //   children: [
                  //     Text(
                  //       '汇报',
                  //       style: TextStyle(fontSize: 14, color: Colors.black),
                  //     ),
                  //     SizedBox(width: 16),
                  //     ElevatedButton(
                  //       onPressed: _increment,
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Color(0xFF0073FF),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(4),
                  //         ),
                  //         minimumSize: Size(60, 32),
                  //       ),
                  //       child: Text(
                  //         '增加',
                  //         style: TextStyle(fontSize: 14, color: Colors.white),
                  //       ),
                  //     ),
                  //     SizedBox(width: 12),
                  //     ElevatedButton(
                  //       onPressed: _decrement,
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.grey[200],
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(4),
                  //         ),
                  //         minimumSize: Size(60, 32),
                  //       ),
                  //       child: Text(
                  //         '减少',
                  //         style: TextStyle(fontSize: 14, color: Colors.black),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 24),
                  Text(
                    '数量',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          decoration: InputDecoration(
                            border: AppStyles.border,
                            enabledBorder: AppStyles.enabledBorder,
                            focusedBorder: AppStyles.focusedBorder,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      if (widget.unit != null) ...[
                        SizedBox(width: 8),
                        Text(
                          widget.unit!,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ],
                  ),
                  // SizedBox(height: 24),
                  // Text(
                  //   '备注',
                  //   style: TextStyle(fontSize: 14, color: Colors.black),
                  // ),
                  // SizedBox(height: 8),
                  // TextField(
                  //   controller: _remarkController,
                  //   style: TextStyle(fontSize: 14, color: Colors.black),
                  //   decoration: InputDecoration(
                  //     border: AppStyles.border,
                  //     enabledBorder: AppStyles.enabledBorder,
                  //     focusedBorder: AppStyles.focusedBorder,
                  //     hintText: '输入内容',
                  //     hintStyle: TextStyle(
                  //       fontSize: 14,
                  //       color: Colors.grey[400],
                  //     ),
                  //     contentPadding: EdgeInsets.symmetric(
                  //       horizontal: 12,
                  //       vertical: 10,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: 16),
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
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0073FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
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
