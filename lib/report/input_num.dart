import 'package:flutter/material.dart';
import 'package:flutter_application_1/assets/app_styles.dart';
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
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
            // 顶部栏：左取消，右确定
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      '取消',
                      style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
                    ),
                  ),
                  Text(widget.title, style: AppStyles.fontMax),
                  GestureDetector(
                    onTap: _submit,
                    child: Text(
                      '确定',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0073FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
