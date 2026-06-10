import 'package:flutter/material.dart';

class TaskType extends StatefulWidget {
  const TaskType({super.key});

  @override
  State<TaskType> createState() => _TaskTypeState();
}

class _TaskTypeState extends State<TaskType> {
  // 定义任务类型列表，包含名称和是否选中状态
  final List<Map<String, dynamic>> taskTypes = [
    {'name': '周期任务', 'selected': false},
    {'name': '临时任务', 'selected': true},
    {'name': '外派任务', 'selected': false},
    {'name': '会议任务', 'selected': false},
  ];

  // 处理单选按钮点击事件
  void _onTaskTypeChanged(int index) {
    setState(() {
      // 先将所有任务类型设为未选中
      for (var type in taskTypes) {
        type['selected'] = false;
      }
      // 再将点击的任务类型设为选中
      taskTypes[index]['selected'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: Colors.white,
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
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('选择任务类型'),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 16.0),
              child: ListView.builder(
                itemCount: taskTypes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(taskTypes[index]['name']),
                    trailing: Checkbox(
                      value: taskTypes[index]['selected'],
                      onChanged: (bool? value) {
                        if (value != null) {
                          _onTaskTypeChanged(index);
                        }
                      },
                      activeColor: Color(0xFF0073FF), // 设置选中时的颜色
                      shape: CircleBorder(), // 设置为圆形
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
