import 'package:flutter/material.dart';
import 'package:flutter_application_1/report_form.dart';
import 'package:flutter_application_1/task_list.dart';

class SelectTask extends StatefulWidget {
  final String title;
  final Function(int) onTaskSelected;

  const SelectTask({
    super.key,
    required this.title,
    required this.onTaskSelected,
  });

  @override
  State<SelectTask> createState() => _SelectTaskState();
}

class _SelectTaskState extends State<SelectTask> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Center(
          child: Text(
            widget.title,
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: TaskList(title: widget.title),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!, width: .5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (cotext) {
                    return ReportForm();
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0073FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                minimumSize: Size(0, 32),
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
