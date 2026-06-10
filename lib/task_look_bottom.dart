import 'package:flutter/material.dart';
import 'package:flutter_application_1/task_details.dart';
import 'package:flutter_application_1/report_history.dart';

class TaskLookBottom extends StatefulWidget {
  final bool? isEmbedded;
  final bool? isHasDetail;
  const TaskLookBottom({super.key, this.isEmbedded, this.isHasDetail});

  @override
  State<TaskLookBottom> createState() => _TaskLookBottomState();
}

class _TaskLookBottomState extends State<TaskLookBottom> {
  // 当前选中的标签页索引 0: 任务详情, 1: 汇报历史
  int _currentTabIndex = 1;

  @override
  initState() {
    super.initState();
    if (widget.isHasDetail == true) {
      _currentTabIndex = 0;
    }
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
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('任务详情'),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
            ),
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
              ? Expanded(child: SingleChildScrollView(child: TaskDetails()))
              : Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => ReportHistory(),
                  ),
                ),
        ],
      ),
    );
  }
}
