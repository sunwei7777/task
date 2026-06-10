import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/common.dart';

class TaskType extends StatefulWidget {
  final Function(int) onTaskTypeChanged;
  final String? initialValue;
  const TaskType(this.onTaskTypeChanged, {super.key, this.initialValue});

  @override
  State<TaskType> createState() => _TaskTypeState();
}

class _TaskTypeState extends State<TaskType> {
  late final List<Map> taskTypes;

  @override
  void initState() {
    super.initState();
    final current = widget.initialValue;
    taskTypes = [
      {'name': '周期任务', 'selected': current == '周期任务'},
      {'name': '临时任务', 'selected': current == '临时任务'},
      {'name': '外派任务', 'selected': current == '外派任务'},
      {'name': '会议任务', 'selected': current == '会议任务'},
    ];
  }

  // 处理单选按钮点击事件
  void _onTaskTypeChanged(int index) {
    setState(() {
      // 先将所有任务类型设为未选中
      for (var type in taskTypes) {
        type['selected'] = false;
      }
      // 再将点击的任务类型设为选中
      taskTypes[index]['selected'] = true;
      Navigator.pop(context);
      widget.onTaskTypeChanged(index);
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Common.topBar(context, '选择任务类型', showCloseButton: true),
          Container(height: 0.5, color: Colors.grey[300]!),

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
                      shape: CircleBorder(),
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
