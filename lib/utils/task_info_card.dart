import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/common.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../store/task_controller.dart';

class TaskInfoCard extends StatelessWidget {
  final Task? task;

  const TaskInfoCard({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    if (task?.id == null) return _buildCard(task);

    final taskController = Get.find<TaskController>();
    return Obx(() {
      Task? t = task;
      final fromList = taskController.allTasks.firstWhereOrNull(
        (item) => item.id == task!.id,
      );
      if (fromList != null) t = fromList;
      if (taskController.currentTask.value?.id == task!.id) {
        t = taskController.currentTask.value;
      }
      return _buildCard(t);
    });
  }

  Widget _buildCard(Task? t) {
    final isProject = t?.taskType == 1;
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border.all(color: Color(0xFFD4D4D4), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.work, color: Colors.blue, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(text: t?.taskName ?? ''),
                      TextSpan(
                        text: ' ${(t?.progress ?? 0).toInt()}%',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                if (t?.billNo?.isNotEmpty == true)
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      '${isProject ? '项目编号' : '订单编号'}：${t?.billNo ?? ''}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                if (!isProject && t?.styleCode?.isNotEmpty == true)
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      '款号：${t?.styleCode ?? ''}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                if (t?.relatedProjectOrder?.isNotEmpty == true)
                  Text(
                    '关联订单/款号：${t?.relatedProjectOrder ?? ''}',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                Text(
                  '要求完成时间：${t?.endTime ?? '-'}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (Common.statusBgColor[t?.statusDesc] ?? Colors.grey)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              t?.statusDesc ?? '',
              style: TextStyle(
                color: Common.statusBgColor[t?.statusDesc],
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
