import 'package:flutter/material.dart';
import 'package:flutter_application_1/task/task_details.dart';
import 'package:flutter_application_1/report/report_history.dart';
import 'package:flutter_application_1/utils/common.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskLookBottom extends StatefulWidget {
  final bool? isEmbedded;
  final bool? isHasDetail;
  final int taskId;
  final Task? task;
  const TaskLookBottom({
    super.key,
    this.isEmbedded,
    this.isHasDetail,
    required this.taskId,
    this.task,
  });

  @override
  State<TaskLookBottom> createState() => TaskLookBottomState();
}

class TaskLookBottomState extends State<TaskLookBottom> {
  final TaskService _taskService = TaskService();
  List<ReportHistoryItem> _items = [];
  bool _isLoading = true;
  // 当前选中的标签页索引 0: 任务详情, 1: 汇报历史
  int _currentTabIndex = 1;

  @override
  initState() {
    super.initState();
    if (widget.isHasDetail == true) {
      _currentTabIndex = 0;
    }
    _loadHistory();
  }

  Future<void> refreshHistory() => _loadHistory();

  Future<void> _loadHistory() async {
    final items = await _taskService.fetchReportHistory(
      widget.task?.taskNo ?? '',
    );
    if (mounted)
      setState(() {
        _items = items;
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.isEmbedded == true
          ? double.infinity
          : MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // 标题和关闭按钮
          if (widget.isEmbedded != true)
            Common.topBar(context, '任务详情', showCloseButton: true),
          if (widget.isEmbedded != true)
            Container(height: 0.5, color: Colors.grey[300]!),
          // 标签页
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                if (widget.isHasDetail == true)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentTabIndex = 0;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _currentTabIndex == 0
                                ? Color(0xFF0073FF)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '任务详情',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _currentTabIndex == 0
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: _currentTabIndex == 0
                              ? Color(0xFF0073FF)
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentTabIndex = 1;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _currentTabIndex == 1
                              ? Color(0xFF0073FF)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      '汇报历史',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _currentTabIndex == 1
                            ? FontWeight.w500
                            : FontWeight.normal,
                        color: _currentTabIndex == 1
                            ? Color(0xFF0073FF)
                            : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 内容区域
          _currentTabIndex == 0
              ? Expanded(
                  child: SingleChildScrollView(
                    child: TaskDetails(
                      taskId: widget.taskId,
                      initialTask: widget.task,
                    ),
                  ),
                )
              : Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _items.isEmpty
                      ? Center(
                          child: Text(
                            '暂无汇报记录',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) => ReportHistory(
                            taskNo: widget.task?.taskNo ?? '',
                            item: _items[index],
                          ),
                        ),
                ),
        ],
      ),
    );
  }
}
