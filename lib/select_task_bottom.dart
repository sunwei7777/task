import 'package:flutter/material.dart';
import 'package:flutter_application_1/report_form.dart';
import 'package:flutter_application_1/task_list.dart';

class SelectTaskBottom extends StatefulWidget {
  final String? isReport;
  final Function(int) onTaskSelected;

  const SelectTaskBottom({
    super.key,
    this.isReport,
    required this.onTaskSelected,
  });

  @override
  State<SelectTaskBottom> createState() => _SelectTaskBottomState();
}

class _SelectTaskBottomState extends State<SelectTaskBottom> {
  int? _curIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color(0xFFF4F6FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          // Container(
          //   width: 40,
          //   height: 4,
          //   margin: EdgeInsets.symmetric(vertical: 12),
          //   decoration: BoxDecoration(
          //     color: Colors.grey[300],
          //     borderRadius: BorderRadius.circular(2),
          //   ),
          // ),

          // 标题和关闭按钮
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('选择任务'),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),
          Expanded(child: TaskList(title: '全部任务')),
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    minimumSize: Size(0, 32),
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (_curIndex != null) {
                      widget.onTaskSelected(_curIndex!);
                    }
                    if (widget.isReport == 'report') {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (cotext) {
                          return ReportForm();
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0073FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    minimumSize: Size(0, 32),
                  ),
                  child: Text(
                    '确定',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
