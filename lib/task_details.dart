import 'package:flutter/material.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails({super.key});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  // 构建任务信息项
  Widget buildTaskInfoItem(
    String label,
    String value, {
    bool isProgress = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: isProgress ? Color(0xFF0073FF) : Color(0xFF444444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildTaskInfoItem('任务名称', '这里这里名字很长很长，大概有二十个字 TOP-104圆领衫'),
        buildTaskInfoItem('任务类型', '临时任务'),
        buildTaskInfoItem('任务内容', '--'),
        buildTaskInfoItem('单据编号', 'xsd001765363763'),
        buildTaskInfoItem('计划开始时间', '11-01 09:00'),
        buildTaskInfoItem('计划结束时间', '11-10 09:00 (10天)'),
        buildTaskInfoItem('负责人', '张三、李四'),
        buildTaskInfoItem('任务进度', '20%', isProgress: true),
        buildTaskInfoItem('协作人', '王五'),
        buildTaskInfoItem('抄送', '--'),
        buildTaskInfoItem('关联企业', '--'),
        buildTaskInfoItem('关联订单/项目', '--'),
        buildTaskInfoItem('联络人', '--'),
        buildTaskInfoItem('联络电话', '--'),
        buildTaskInfoItem('添加地址', '--'),

        // 分割线
        Container(
          height: 10,
          color: Color(0xFFE3E3E3),
          margin: EdgeInsets.symmetric(vertical: 10),
        ),

        // 图片部分
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '图片',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 12),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 7,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(child: Text('图片 ${index + 1}')),
                  );
                },
              ),
            ],
          ),
        ),

        // 附件部分
        Container(
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '附件',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          size: 20,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 12),
                        Text(
                          '文件名称名称文件名称...exl',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.cloud_download,
                      size: 20,
                      color: Color(0xFF0073FF),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 其他信息
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Column(
            children: [
              buildTaskInfoItem('创建人', '陈圆圆'),
              buildTaskInfoItem('发布时间', '2025-10-12'),
              buildTaskInfoItem('最新更新', '2025-11-22 09:03'),
              buildTaskInfoItem('更新人', '张三'),
              buildTaskInfoItem('实际完成时间', '--'),
            ],
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
