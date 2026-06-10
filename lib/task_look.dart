import 'package:flutter/material.dart';
import 'package:flutter_application_1/create_task_page.dart';
import 'package:flutter_application_1/dialog_custom.dart';
import 'package:flutter_application_1/report_form.dart';
import 'package:flutter_application_1/task_look_bottom.dart';

class TaskLook extends StatefulWidget {
  final bool? isHasDetail;
  const TaskLook({super.key, this.isHasDetail = false});

  @override
  State<TaskLook> createState() => _TaskLookState();
}

class _TaskLookState extends State<TaskLook> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF0073FF),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '任务详情',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 任务卡片
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0073FF), Color(0xFFffffff)],
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: 16,
                            color: Color(0xFF0073FF),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '清理半成品仓库',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '0%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1BA17D),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFDDF6F8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '待开始',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1BA17D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '要求完成时间：11-09 18：00前',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(width: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            size: 12,
                            color: Colors.red,
                          ),
                          Text(
                            '可能延期',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 内容区域
          Expanded(
            child: TaskLookBottom(
              isEmbedded: true,
              isHasDetail: widget.isHasDetail,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => DialogCustom(
                    title: '确定作废任务吗？',
                    description: '作废后任务将失效，无法恢复。如需修改内容您可「编辑任务」',
                    icon: Icons.warning_amber,
                    iconColor: Color(0xFFFF7B00),
                    leftButtonText: '确定作废',
                    rightButtonText: '编辑任务',
                    onLeftButtonPressed: () {
                      // 处理作废任务逻辑
                      showDialog(
                        context: context,
                        builder: (context) => DialogCustom(
                          title: '任务作废成功',
                          description: '您可以在任务列表-已取消，查看已作废任务',
                          iconColor: Color(0xFF04C15F),
                          rightButtonText: '我知道了',
                        ),
                      );
                    },
                  ),
                );
              },
              child: SizedBox(
                width: 50,
                height: 30,
                child: Column(
                  children: [
                    Icon(
                      Icons.highlight_off,
                      size: 14,
                      color: Color(0xffFF7B00),
                    ),
                    Text(
                      '作废任务',
                      style: TextStyle(fontSize: 10, color: Color(0xFF080808)),
                    ),
                  ],
                ),
              ),
            ),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateTaskPage(isEdit: true),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    minimumSize: Size(0, 32),
                  ),
                  child: Text(
                    '编辑',
                    style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => ReportForm(),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
