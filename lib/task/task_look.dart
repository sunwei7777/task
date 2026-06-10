import 'package:flutter/material.dart';
import 'package:flutter_application_1/task/create_task_page.dart';
import 'package:flutter_application_1/utils/dialog_custom.dart';
import 'package:flutter_application_1/report/report_form.dart';
import 'package:flutter_application_1/task/task_look_bottom.dart';
import 'package:flutter_application_1/utils/task_info_card.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/task_service.dart';
import '../store/task_controller.dart';

class TaskLook extends StatefulWidget {
  final bool? isHasDetail;
  final int? taskId;
  final String? taskNo;
  const TaskLook({
    super.key,
    this.isHasDetail = false,
    this.taskId,
    this.taskNo,
  }) : assert(taskId != null || taskNo != null, 'taskId 或 taskNo 至少传一个');

  @override
  State<TaskLook> createState() => _TaskLookState();
}

class _TaskLookState extends State<TaskLook> {
  final TaskService _taskService = TaskService();
  final _bottomKey = GlobalKey<TaskLookBottomState>();
  Task? _task;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      widget.taskId != null
          ? _taskService.fetchTaskDetail(widget.taskId!)
          : _taskService.fetchTaskDetailByTaskNo(widget.taskNo!),
      StorageService.getUserInfo(),
    ]);
    if (mounted) {
      setState(() {
        _task = results[0] as Task?;
        final userInfo = results[1] as Map<String, dynamic>?;
        _currentUserId = userInfo?['userId']?.toString();
      });
    }
  }

  bool get _canEdit {
    if (_task == null || _currentUserId == null) return false;
    final status = _task!.statusDesc;
    return _task!.creator == _currentUserId &&
        widget.isHasDetail == true &&
        (status == '待处理' || status == '已超时');
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;
    final taskId = task?.id ?? widget.taskId;

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
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.all(12),
              clipBehavior: Clip.antiAlias,
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
              child: TaskInfoCard(task: task),
            ),
          ),
          // 内容区域
          Expanded(
            child: task != null && taskId != null
                ? TaskLookBottom(
                    key: _bottomKey,
                    isEmbedded: true,
                    isHasDetail: widget.isHasDetail,
                    taskId: taskId,
                    task: task,
                  )
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_canEdit)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => DialogCustom(
                      title: '确定作废任务吗？',
                      description: '作废后任务将失效，无法恢复。如需修改内容您可「编辑任务」',
                      icon: Icons.warning_amber,
                      iconColor: Color(0xFFFF7B00),
                      leftButtonText: '确定作废',
                      rightButtonText: '编辑任务',
                      onLeftButtonPressed: () async {
                        final outer = context;
                        Navigator.pop(outer);
                        final targetTaskId = task?.id ?? widget.taskId;
                        if (targetTaskId == null) return;
                        final success = await _taskService.cancelTask(
                          targetTaskId,
                        );
                        if (success) {
                          Get.find<TaskController>().refreshTaskList();
                        }
                        if (!mounted) return;
                        showDialog(
                          // ignore: use_build_context_synchronously
                          context: outer,
                          builder: (_) => DialogCustom(
                            title: success ? '任务作废成功' : '作废失败',
                            description: success
                                ? '您可以在任务列表-已取消，查看已作废任务'
                                : '请稍后重试',
                            iconColor: success
                                ? Color(0xFF04C15F)
                                : Color(0xFFFF4D4F),
                            rightButtonText: '我知道了',
                          ),
                        );
                      },
                      onRightButtonPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateTaskPage(isEdit: true, task: task ?? _task),
                        ),
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: 50,
                  height: 40,
                  child: Column(
                    children: [
                      Icon(
                        Icons.highlight_off,
                        size: 16,
                        color: Color(0xffFF7B00),
                      ),
                      Text(
                        '作废任务',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF080808),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(width: 50),

            Row(
              children: [
                if (_canEdit)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateTaskPage(isEdit: true, task: task ?? _task),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      '编辑',
                      style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
                    ),
                  ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final targetTaskId = task?.id ?? widget.taskId;
                    if (targetTaskId == null) return;
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) =>
                          ReportForm(taskId: targetTaskId, task: task ?? _task),
                    );
                    _bottomKey.currentState?.refreshHistory();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0073FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
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
