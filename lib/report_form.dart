import 'package:flutter/material.dart';
import 'package:flutter_application_1/report_progress.dart';
import 'package:flutter_application_1/select_principal.dart';
import 'package:flutter_application_1/task_look_bottom.dart';
import 'package:flutter_application_1/utils/form_widgets.dart';
import 'toast_custom.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  // 表单输入控制器
  final TextEditingController taskContentController = TextEditingController();
  // 日期选择器状态
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('补汇报')],
            ),
          ),
          Container(height: 0.5, color: Colors.grey[300]!),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '任务基本信息',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF001111),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (cotext) {
                                return TaskLookBottom();
                              },
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              minimumSize: Size(0, 28),
                            ),
                            child: Text(
                              '任务详情',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF080808),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.0),
                      Container(
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFAFAFA),
                          border: Border.all(
                            color: Color(0xFFD4D4D4),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.work, color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(text: '清理半成品仓库'),
                                      TextSpan(
                                        text: ' 80%',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '要求完成时间：11-09 18:00前',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(color: Colors.transparent),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFE0F2F1), // 浅绿色背景色，可根据实际需求调整
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                '待开始',
                                style: TextStyle(
                                  color: Color(0xFF1BA17D),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  FormWidgets.buildReadOnlyItem(
                    '申请类型',
                    true,
                    '补汇报',
                    Icons.category,
                  ),
                  FormWidgets.buildInputItem(
                    '申请原因',
                    true,
                    taskContentController,
                    Icons.description,
                  ),
                  // 计划开始时间
                  FormWidgets.buildDateItem(
                    context,
                    '计划开始时间',
                    true,
                    startDate,
                    Icons.access_time,
                    onPressed: (selectedDateTime) {
                      setState(() {
                        startDate = selectedDateTime;
                      });
                      Navigator.pop(context);
                      return null;
                    },
                  ),
                  // 计划结束时
                  FormWidgets.buildDateItem(
                    context,
                    '计划结束时间',
                    true,
                    endDate,
                    Icons.event,
                    onPressed: (selectedDateTime) {
                      setState(() {
                        endDate = selectedDateTime;
                      });
                      Navigator.pop(context);
                      return null;
                    },
                  ),
                  ReportProgress(),
                  // 负责人
                  FormWidgets.buildReadOnlyItem(
                    '申请人',
                    true,
                    '',
                    Icons.person,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (cotext) {
                          return SelectPrincipal('申请人');
                        },
                      );
                    },
                  ),

                  // 添加图片/视频
                  FormWidgets.buildImageUploadItem('图片/视频'),
                  FormWidgets.buildFileUploadItem('附件'),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: .5),
              ),
            ),
            child: Row(
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
                  onPressed: () {
                    //提交成功toast提示
                    Navigator.pop(context);
                    ToastCustom.showToast(context, '提交成功');
                  },
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
          ),
        ],
      ),
    );
  }
}
