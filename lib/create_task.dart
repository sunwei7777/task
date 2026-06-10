import 'package:flutter/material.dart';
import 'package:flutter_application_1/cycle_task_explain.dart';
import 'package:flutter_application_1/select_principal.dart';
import 'package:flutter_application_1/select_task_bottom.dart';
import 'package:flutter_application_1/set_cycle.dart';
import 'package:flutter_application_1/task_type.dart';
import 'package:flutter_application_1/utils/form_widgets.dart';

class CreateTask extends StatefulWidget {
  final String? wherePage;

  const CreateTask({super.key, this.wherePage});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  // 表单输入控制器
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskContentController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  // 日期选择器状态
  DateTime? startDate;
  DateTime? endDate;
  // 选择状态
  String taskType = '临时任务';
  String setCycle = '每天';
  List<String> collaborators = [];
  List<String> ccList = [];
  String? selectedCompany;
  String? selectedProject;
  String? selectedContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(color: Color(0xFFEEF0F2), height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // 任务名称
                Stack(
                  children: [
                    FormWidgets.buildInputItem(
                      '任务名称',
                      true,
                      taskNameController,
                      Icons.title,
                    ),
                    // 蓝色选择按钮
                    if (widget.wherePage == 'report')
                      Positioned(
                        right: 0,
                        top: 0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            minimumSize: const Size(0, 28),
                          ),
                          onPressed: () => {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
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
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                // 任务内容
                FormWidgets.buildInputItem(
                  '任务内容',
                  false,
                  taskContentController,
                  Icons.description,
                ),
                // 单据编号
                FormWidgets.buildReadOnlyItem(
                  '单据编号',
                  false,
                  '自动生成',
                  Icons.request_quote,
                  onTap: _showDialog,
                ),
                // 任务类型
                FormWidgets.buildReadOnlyItem(
                  '任务类型',
                  true,
                  taskType,
                  Icons.category,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (cotext) {
                      return TaskType();
                    },
                  ),
                ),
                FormWidgets.buildReadOnlyItem(
                  '设置周期',
                  true,
                  setCycle,
                  Icons.alarm,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (cotext) {
                      return SetCycle();
                    },
                  ),
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
                // 负责人
                FormWidgets.buildReadOnlyItem(
                  '负责人',
                  true,
                  '',
                  Icons.person,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (cotext) {
                      return SelectPrincipal('负责人');
                    },
                  ),
                ),
                // 协作人
                // FormWidgets.buildReadOnlyItem(
                //   '协作人',
                //   false,
                //   collaborators.join(', '),
                //   Icons.people,
                //   onTap: () => showModalBottomSheet(
                //     context: context,
                //     isScrollControlled: true,
                //     backgroundColor: Colors.transparent,
                //     builder: (cotext) {
                //       return SelectPrincipal('协作人');
                //     },
                //   ),
                // ),
                // 抄送
                FormWidgets.buildReadOnlyItem(
                  '抄送',
                  false,
                  ccList.join(', '),
                  Icons.mail,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (cotext) {
                      return SelectPrincipal('抄送');
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(color: Color(0xFFEEF0F2), height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                FormWidgets.buildReadOnlyItem(
                  '关联企业',
                  false,
                  selectedCompany ?? '',
                  Icons.business,
                ),
                // 关联项目/订单
                FormWidgets.buildReadOnlyItem(
                  '关联项目/订单',
                  false,
                  selectedProject ?? '',
                  Icons.assignment,
                ),
                // 联络人
                FormWidgets.buildReadOnlyItem(
                  '联络人',
                  false,
                  selectedContact ?? '',
                  Icons.contact_page,
                ),
                // 联络电话
                FormWidgets.buildInputItem(
                  '联络电话',
                  false,
                  contactPhoneController,
                  Icons.phone,
                ),
                // 添加地址
                FormWidgets.buildInputItem(
                  '添加地址',
                  false,
                  addressController,
                  Icons.location_on,
                ),
                // 添加图片/视频
                FormWidgets.buildReadOnlyItem(
                  '添加图片/视频',
                  false,
                  '',
                  Icons.add_photo_alternate,
                ),
                // 添加附件
                FormWidgets.buildReadOnlyItem(
                  '添加附件',
                  false,
                  '',
                  Icons.attachment,
                ),
              ],
            ),
          ), // 关联企业
          Container(color: Color(0xFFEEF0F2), height: 10),
        ],
      ),
    );
  }

  Future<dynamic> _showDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CycleTaskExplain();
      },
    );
  }
}
