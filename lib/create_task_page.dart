import 'package:flutter/material.dart';
import 'package:flutter_application_1/create_task.dart';

class CreateTaskPage extends StatefulWidget {
  final bool? isEdit;
  const CreateTaskPage({super.key, this.isEdit});

  @override
  State<CreateTaskPage> createState() => _CreateTaskStatePage();
}

class _CreateTaskStatePage extends State<CreateTaskPage> {
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
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.arrow_back_ios, // 图标类型
        //     size: 20, // 图标大小
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: SingleChildScrollView(child: CreateTask()),
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
              minimumSize: Size(0, 32),
            ),
            child: Text(
              '取消',
              style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
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
    );
  }
}
