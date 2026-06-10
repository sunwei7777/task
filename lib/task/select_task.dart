import 'package:flutter/material.dart';
import 'package:flutter_application_1/report/report_form.dart';
import 'package:flutter_application_1/task/task_list.dart';
import 'package:flutter_application_1/utils/top_notification.dart';
import 'package:get/get.dart';
import '../store/task_controller.dart';

class SelectTask extends StatefulWidget {
  final String title;
  final Function(int) onTaskSelected;
  final String? searchTaskNo;

  const SelectTask({
    super.key,
    required this.title,
    this.searchTaskNo,
    required this.onTaskSelected,
  });

  @override
  State<SelectTask> createState() => _SelectTaskState();
}

class _SelectTaskState extends State<SelectTask> {
  int? _selectedTaskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(Icons.notifications_none, color: Colors.black),
          // ),
        ],
      ),
      body: TaskList(
        title: widget.title,
        searchTaskNo: widget.searchTaskNo,
        onTaskSelected: (index) {
          final tasks = Get.find<TaskController>().allTasks;
          if (index >= 0 && index < tasks.length) {
            final taskId = tasks[index].id;
            _selectedTaskId = taskId;
            widget.onTaskSelected(taskId);
          }
        },
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!, width: .5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                if (_selectedTaskId == null) {
                  TopNotification.show(
                    context,
                    message: '请先勾选一个任务',
                    backgroundColor: Colors.orange,
                  );
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ReportForm(taskId: _selectedTaskId),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0073FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                '补汇报',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
