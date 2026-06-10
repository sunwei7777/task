import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/common.dart';

class RepZt extends StatefulWidget {
  final String selectedProgress;
  const RepZt({Key? key, this.selectedProgress = ''}) : super(key: key);

  @override
  _RepZtState createState() => _RepZtState();
}

class _RepZtState extends State<RepZt> {
  late double _selectedProgress;

  @override
  void initState() {
    super.initState();
    final parsed = int.tryParse(widget.selectedProgress.replaceAll('%', ''));
    _selectedProgress = (parsed ?? 0).toDouble().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Common.topBar(context, '选择汇报进度', showCloseButton: true),
          Container(height: 0.5, color: Colors.grey[300]!),

          // 进度显示
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              '${_selectedProgress.toInt()}%',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0073FF),
              ),
            ),
          ),

          // 滑块
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                const Text(
                  '0%',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Expanded(
                  child: Slider(
                    value: _selectedProgress,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: const Color(0xFF0073FF),
                    inactiveColor: Colors.grey[200],
                    label: '${_selectedProgress.toInt()}%',
                    onChanged: (value) {
                      setState(() => _selectedProgress = value);
                    },
                  ),
                ),
                const Text(
                  '100%',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 底部操作按钮
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, '${_selectedProgress.toInt()}%');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0073FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text('确定', style: TextStyle(color: Colors.white)),
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
