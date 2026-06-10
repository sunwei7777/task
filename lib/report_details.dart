import 'package:flutter/material.dart';
import 'package:flutter_application_1/create_task.dart';
import 'package:flutter_application_1/dialog_custom.dart';
import 'package:flutter_application_1/report_progress.dart';
import 'package:flutter_application_1/select_principal.dart';
import 'package:flutter_application_1/select_principal_more.dart';
import 'package:flutter_application_1/select_task_bottom.dart';
import 'package:flutter_application_1/task_look_bottom.dart';
import 'package:flutter_application_1/utils/form_widgets.dart';

class ReportDetails extends StatefulWidget {
  final String? status;
  const ReportDetails(this.status, {super.key});

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  List<String> _selectedPersons = [];
  String taskTitle = '采购-面料染色';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.status == 'dynamic' ? '任务汇报' : '汇报详情',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[50],
        child: ListView(
          children: [
            // 任务信息部分
            taskTitle == ''
                ? CreateTask(wherePage: 'report')
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    margin: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 任务标题
                        widget.status == 'static'
                            ? buildTaskItem('任务标题', taskTitle)
                            : Container(
                                padding: const EdgeInsets.only(top: 12.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      // ignore: deprecated_member_use
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            // 左侧图标
                                            Icon(
                                              Icons.assignment,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            // 标签（带红色星号）
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                  color: Color(0xFF010101),
                                                ),
                                                children: [
                                                  TextSpan(text: '任务标题'),
                                                  TextSpan(
                                                    text: '*',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        // 蓝色选择按钮
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            minimumSize: const Size(0, 28),
                                          ),
                                          onPressed: () => {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (cotext) {
                                                return SelectTaskBottom(
                                                  onTaskSelected: (int index) {
                                                    print(index);
                                                  },
                                                );
                                              },
                                            ),
                                          },
                                          child: const Text(
                                            '选择',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // 任务标题文本
                                        Text(
                                          '采购-面料染色',
                                          style: TextStyle(
                                            color: Color(0xFF444444),
                                          ),
                                        ),
                                        // 右侧关闭按钮
                                        IconButton(
                                          onPressed: () => {
                                            taskTitle = '',
                                            setState(() {}),
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          style: ButtonStyle(
                                            padding: WidgetStateProperty.all(
                                              const EdgeInsets.all(0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                        // 单据编号
                        buildTaskItem('单据编号', 'xsd001765363763'),
                        // 任务类型
                        buildTaskItem('任务类型', '项目任务'),
                        buildTaskItem('当前进度', '50%', isStatus: true),
                        // 关联订单
                        buildTaskItem('关联订单', 'TOP-104', isOrder: true),
                        // 任务详情按钮
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFEEEEEE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              minimumSize: const Size(0, 32),
                            ),
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (cotext) {
                                return TaskLookBottom();
                              },
                            ),
                            child: const Text(
                              '任务详情',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

            // 汇报信息部分
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 持续时间
                  buildTaskItem('持续时间', '11-02 09:11:00~12:31 (3小时25分)'),
                  // 汇报进度
                  // buildTaskItem('汇报进度', '100% → 100%', isOrder: true),
                  ReportProgress(),
                  // 汇报人
                  buildTaskItem(
                    '汇报人',
                    '',
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (cotext) {
                        return SelectPrincipal(
                          '汇报人',
                          onConfirm: (selectedPersons) {
                            setState(() {
                              _selectedPersons = selectedPersons;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  // 汇报人标签
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedPersons.map((person) => buildUserTag(person)),
                    ],
                  ),
                  Container(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.2),
                    height: 0.5,
                    margin: _selectedPersons.isNotEmpty
                        ? const EdgeInsets.only(top: 8)
                        : EdgeInsets.zero,
                  ),
                  // 备注
                  buildTaskItem('备注', ''),
                  // 多行输入框
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      readOnly: widget.status == 'static',
                      maxLines: null, // 允许多行
                      minLines: 2, // 最小3行
                      decoration: InputDecoration(
                        hintText: '请输入备注',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      controller: TextEditingController(text: '11'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 图片/视频部分
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.status == 'static'
                      ? buildTaskItem('图片/视频', '')
                      : FormWidgets.buildImageUploadItem('图片/视频'),
                  // 图片网格
                  // GridView.builder(
                  //   shrinkWrap: true,
                  //   physics: const NeverScrollableScrollPhysics(),
                  //   gridDelegate:
                  //       const SliverGridDelegateWithFixedCrossAxisCount(
                  //         crossAxisCount: 5,
                  //         crossAxisSpacing: 8,
                  //         mainAxisSpacing: 8,
                  //         childAspectRatio: 1,
                  //       ),
                  //   itemCount: 3,
                  //   itemBuilder: (context, index) {
                  //     return Container(
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(8),
                  //         image: const DecorationImage(
                  //           image: AssetImage('lib/assets/user.png'),
                  //           fit: BoxFit.cover,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // 附件
                  widget.status == 'static'
                      ? buildTaskItem('附件', '')
                      : FormWidgets.buildFileUploadItem('附件'),
                ],
              ),
            ),

            // 底部信息部分
            ?widget.status == 'static'
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 汇报类型
                        buildTaskItem('汇报类型', '正常', isStatus: true),
                        // 提交人
                        buildTaskItem('提交人', '陈圆圆'),
                        // 汇报时间
                        buildTaskItem('汇报时间', '11-02 06: 00: 31'),
                      ],
                    ),
                  )
                : null,
          ],
        ),
      ),
      bottomNavigationBar: widget.status == 'dynamic'
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => SelectPrincipalMore('汇报多人'),
                      );
                    },
                    child: SizedBox(
                      width: 50,
                      height: 30,
                      child: Column(
                        children: [
                          Icon(Icons.group, size: 14, color: Color(0xFF477DF3)),
                          Text(
                            '汇报多人',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF080808),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Row(
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF080808),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => DialogCustom(
                              title: '任务提交成功！',
                              description: '您可以在首页-汇报统计，查看历史提交',
                              iconColor: Color(0xFF04C15F),
                            ),
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
                          '确定提交',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // 通用任务项构建方法
  Widget buildTaskItem(
    String label,
    String value, {
    bool isOrder = false,
    bool isStatus = false,
    void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: value.isEmpty
              ? null
              : Border(
                  bottom: BorderSide(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(_getIconForLabel(label), color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            // 左侧标签
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF010101)),
                children: [
                  TextSpan(text: label),
                  if (label == '汇报进度')
                    TextSpan(
                      text: '  整体',
                      style: TextStyle(color: Color(0xFF1BA17D), fontSize: 12),
                    ),
                ],
              ),
            ),
            // 右侧值
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: isOrder
                      ? Colors.blue
                      : isStatus
                      ? Colors.green
                      : Color(0xFF444444),
                  fontWeight: isOrder ? FontWeight.w500 : FontWeight.normal,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            if (label == '汇报进度' && widget.status == 'dynamic')
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // 根据标签获取对应图标
  IconData _getIconForLabel(String label) {
    switch (label) {
      case '任务标题':
        return Icons.assignment;
      case '单据编号':
        return Icons.receipt;
      case '任务类型':
        return Icons.category;
      case '当前进度':
        return Icons.percent;
      case '关联订单':
        return Icons.shopping_cart;
      case '持续时间':
        return Icons.access_time;
      case '汇报进度':
        return Icons.timeline;
      case '汇报人':
        return Icons.person;
      case '备注':
        return Icons.note;
      case '图片/视频':
        return Icons.image;
      case '附件':
        return Icons.attach_file;
      case '汇报类型':
        return Icons.type_specimen;
      case '提交人':
        return Icons.person;
      case '汇报时间':
        return Icons.access_time;
      default:
        return Icons.info;
    }
  }

  // 用户标签构建方法
  Widget buildUserTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFE9F0FD),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        name,
        style: const TextStyle(color: Color(0xFF010101), fontSize: 12),
      ),
    );
  }
}
