import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:flutter_application_1/report/input_num.dart';
import 'package:flutter_application_1/services/task_service.dart';
import 'package:flutter_application_1/utils/common.dart';
import 'package:flutter_application_1/utils/task_info_card.dart';

class RepSku extends StatefulWidget {
  final String? reportMethod;
  final String? taskNo;
  final Task? task;

  const RepSku({Key? key, this.reportMethod, this.taskNo, this.task})
    : super(key: key);

  @override
  _RepSkuState createState() => _RepSkuState();
}

class _RepSkuState extends State<RepSku> {
  final TaskService _taskService = TaskService();
  List<SkuItem> items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.reportMethod != null && widget.taskNo != null) {
      _loadData();
    } else {
      setState(() => _isLoading = false);
    }
  }

  static const _methodCodes = {
    '整体汇报': 'slider',
    'SKU汇报': 'sku',
    '自定义汇报': 'style',
  };

  Future<void> _loadData() async {
    final result = await _taskService.fetchSkuList(
      reportMethod: _methodCodes[widget.reportMethod] ?? widget.reportMethod!,
      taskNo: widget.taskNo!,
    );
    if (mounted) {
      setState(() {
        items = result;
        _isLoading = false;
      });
    }
  }

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
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Common.topBar(context, '选择汇报进度', showCloseButton: true),
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
                              fontSize: 14,
                              color: Color(0xFF001111),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.0),
                      if (widget.task != null) TaskInfoCard(task: widget.task),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (_isLoading)
                    Center(child: CircularProgressIndicator())
                  else ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFF6F6F6),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildHeader('颜色', 140),
                                _buildHeader('尺码', 60),
                                _buildHeader('订单数量', 120),
                                _buildHeader('汇报数量', 100),
                              ],
                            ),
                          ),
                          ...items.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            return _buildRow(idx, item);
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: .5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            for (final item in items) {
                              final fillQty = item.qty - item.reportedQty;
                              item.reportQty = fillQty > 0 ? fillQty : 0;
                            }
                          });
                        },
                        icon: Icon(
                          Icons.edit,
                          size: 14,
                          color: Color(0xFF0073FF),
                        ),
                        label: Text(
                          '全部填入',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0073FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final dtoList = items
                        .map(
                          (item) => {
                            'size': item.size,
                            'color': item.color,
                            'reportNum': item.qty,
                            'completeNum': item.reportedQty,
                            'currentReportNum': item.reportQty
                                .toInt()
                                .toString(),
                            'mesSkuId': item.id,
                          },
                        )
                        .toList();
                    final totalQty = items.fold<double>(0, (s, i) => s + i.qty);
                    final totalDone = items.fold<double>(
                      0,
                      (s, i) => s + i.reportedQty + i.reportQty,
                    );
                    final progressValue = totalQty > 0
                        ? ((totalDone / totalQty) * 100).clamp(0, 100).toInt()
                        : 0;
                    final progress = '$progressValue%';
                    Navigator.pop(context, {
                      'items': dtoList,
                      'progress': progress,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0073FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
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

  Widget _buildHeader(String title, double width) {
    return SizedBox(
      width: width,
      child: Text(title, style: TextStyle(fontSize: 14, color: Colors.black54)),
    );
  }

  Widget _buildRow(int index, SkuItem item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(item.color ?? '', style: TextStyle(fontSize: 14)),
          ),
          SizedBox(
            width: 60,
            child: Text(item.size ?? '', style: TextStyle(fontSize: 14)),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Text(
                  '${item.reportedQty.toInt()}/',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  '${item.qty.toInt()}',
                  style: TextStyle(fontSize: 14, color: Color(0xFF1BA17D)),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => InputNum(
                        initialValue: item.reportQty,
                        title: '${item.color ?? ''} ${item.size ?? ''}',
                        unit: item.unit,
                      ),
                    );
                    if (result != null && result is num) {
                      setState(() {
                        item.reportQty = result.toDouble();
                      });
                    }
                  },
                  child: Container(
                    width: 64,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.reportQty > 0 ? '${item.reportQty}' : '请输入',
                      style: TextStyle(
                        fontSize: 14,
                        color: item.reportQty > 0
                            ? Colors.black
                            : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  item.unit ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
