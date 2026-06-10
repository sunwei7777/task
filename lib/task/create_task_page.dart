import 'package:flutter/material.dart';
import 'package:flutter_application_1/task/create_task.dart';
import '../models/task.dart';

class CreateTaskPage extends StatefulWidget {
  final bool? isEdit;
  final Task? task;
  const CreateTaskPage({super.key, this.isEdit, this.task});

  @override
  State<CreateTaskPage> createState() => _CreateTaskStatePage();
}

class _CreateTaskStatePage extends State<CreateTaskPage> {
  final GlobalKey<CreateTaskState> _formKey = GlobalKey<CreateTaskState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit == true ? '编辑任务' : '新建任务',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: CreateTask(key: _formKey, initTask: widget.task),
      ),
      bottomNavigationBar: Row(
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
              _formKey.currentState?.submitTask();
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
    );
  }
}
