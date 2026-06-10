import 'package:flutter/material.dart';
import 'package:flutter_application_1/report/report_form.dart';
import 'package:flutter_application_1/task/task_list.dart';
import 'package:flutter_application_1/utils/common.dart';
import 'package:flutter_application_1/utils/top_notification.dart';
import 'package:get/get.dart';
import '../store/task_controller.dart';

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
  int? _selectedTaskId;

  int? _taskIdByIndex(int index) {
    final controller = Get.find<TaskController>();
    final tasks = controller.allTasks;
    if (index >= 0 && index < tasks.length) {
      return tasks[index].id;
    }
    return null;
  }

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
          // 标题和关闭按钮
          Common.topBar(context, '选择任务', showCloseButton: true),

          Expanded(
            child: TaskList(
              title: '全部任务',
              // isSearch: false,
              onTaskSelected: (index) {
                _curIndex = index;
                _selectedTaskId = _taskIdByIndex(index);
              },
            ),
          ),
          Container(
            width: double.infinity,
            height: 64,
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
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_curIndex == null) {
                      TopNotification.show(
                        context,
                        message: '请先勾选一个任务',
                        backgroundColor: Colors.orange,
                      );
                      return;
                    }

                    Navigator.pop(context);
                    widget.onTaskSelected(_curIndex!);
                    if (widget.isReport == 'report') {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ReportForm(taskId: _selectedTaskId),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0073FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
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
