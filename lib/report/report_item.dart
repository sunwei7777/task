import 'package:flutter/material.dart';
import 'package:flutter_application_1/task/task_look.dart';
import '../models/task.dart';

class ReportItem extends StatelessWidget {
  final ReportDataItem data;

  const ReportItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data.taskName ?? '';
    final totalProgress = '${data.totalProgress ?? ''}%';
    final reportedProgress = '${data.reportedProgress ?? ''}%';
    final creator = data.createUser ?? '';
    final reportType = data.applyType ?? '';
    final duration = data.workTime ?? '';
    final startEnd = data.formattedWorkTime ?? '';
    final submitter = data.reportUser ?? '';
    final reportTime = data.reportTime ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskLook(taskId: data.taskId),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        shadowColor: Colors.grey.withOpacity(0.1),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.work, color: Colors.blue),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(text: title),
                            TextSpan(
                              text: ' $totalProgress',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '创建人：$creator',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  Expanded(child: Container(color: Colors.transparent)),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                ],
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 0.5,
                color: Colors.grey.withOpacity(0.2),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('汇报类型：'),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          reportType,
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('汇报进度：'),
                      SizedBox(width: 8),
                      Text(
                        reportedProgress,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text('持续时间：$duration'),
              SizedBox(height: 8),
              Text('开始/结束：$startEnd'),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 0.5,
                color: Colors.grey.withOpacity(0.2),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('提交人：$submitter', style: TextStyle(color: Colors.grey)),
                  Text(
                    '汇报时间：$reportTime',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
