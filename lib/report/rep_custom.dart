import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:flutter_application_1/report/input_num.dart';
import 'package:flutter_application_1/report/rep_custom_add.dart';
import 'package:flutter_application_1/services/task_service.dart';
import 'package:flutter_application_1/task/task_look_bottom.dart';
import 'package:flutter_application_1/utils/common.dart';
import 'package:flutter_application_1/utils/task_info_card.dart';
import 'package:flutter_application_1/utils/top_notification.dart';

class RepCustom extends StatefulWidget {
  final String? reportMethod;
  final String? taskNo;
  final Task? task;

  const RepCustom({Key? key, this.reportMethod, this.taskNo, this.task})
    : super(key: key);

  @override
  _RepCustomState createState() => _RepCustomState();
}

class _RepCustomState extends State<RepCustom> {
  final TaskService _taskService = TaskService();
  List<ReportItem> items = [];
  bool _isLoading = true;

  // 根据任务名判断显示哪些自定义字段
  bool get _showColor => _taskNamesWithColor.contains(widget.task?.taskName);
  bool get _showMf => _taskNamesWithMf.contains(widget.task?.taskName);
  bool get _showKz => _taskNamesWithKz.contains(widget.task?.taskName);
  bool get _showPic => _taskNamesWithPic.contains(widget.task?.taskName);
  bool get _showZs => _taskNamesWithZs.contains(widget.task?.taskName);
  bool get _showRs => _taskNamesWithRs.contains(widget.task?.taskName);
  bool get _showSize => _taskNamesWithSize.contains(widget.task?.taskName);

  static const _taskNamesWithColor = {
    '算料',
    '大货缝制辅料入库',
    '缝制辅料计划下达',
    '大货面料入库',
    '织造跟单汇报',
    '染色跟单汇报',
  };
  static const _taskNamesWithMf = {'算料', '大货面料入库', '织造跟单汇报', '染色跟单汇报'};
  static const _taskNamesWithKz = {'算料', '大货面料入库', '织造跟单汇报', '染色跟单汇报'};
  static const _taskNamesWithPic = {
    '算料',
    '大货缝制辅料入库',
    '缝制辅料计划下达',
    '大货面料入库',
    '织造跟单汇报',
    '染色跟单汇报',
  };
  static const _taskNamesWithZs = {'织造跟单汇报'};
  static const _taskNamesWithRs = {'染色跟单汇报'};
  static const _taskNamesWithSize = {'大货缝制辅料入库', '缝制辅料计划下达'};

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
    final result = await _taskService.fetchStyleInfo(
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
                          // ElevatedButton(
                          //   onPressed: () => showModalBottomSheet(
                          //     context: context,
                          //     isScrollControlled: true,
                          //     backgroundColor: Colors.transparent,
                          //     builder: (cotext) {
                          //       return TaskLookBottom(
                          //         taskId: widget.task?.id ?? 0,
                          //         task: widget.task,
                          //       );
                          //     },
                          //   ),
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Color(0xFFFFFFFF),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(4),
                          //     ),
                          //     minimumSize: Size(0, 32),
                          //   ),
                          //   child: Text(
                          //     '任务详情',
                          //     style: TextStyle(
                          //       fontSize: 12,
                          //       color: Color(0xFF080808),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 0.0),
                      TaskInfoCard(task: widget.task),
                    ],
                  ),
                  SizedBox(height: 2),
                  //添加目标
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (cotext) {
                              return RepCustomAdd();
                            },
                          );
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            setState(() {
                              items.add(
                                ReportItem(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  materialName:
                                      result['materialName'] as String?,
                                  spec1: result['spec1'] as String?,
                                  spec2: result['spec2'] as String?,
                                  supplier: result['supplier'] as String?,
                                  remark: result['remark'] as String?,
                                  qty: (result['qty'] as num?)?.toDouble() ?? 0,
                                  unit: result['unit'] as String?,
                                  completeNum: 0,
                                  currentReportNum: 0,
                                  materialColor:
                                      result['materialColor'] as String?,
                                  mf: result['mf'] as String?,
                                  kz: result['kz'] as String?,
                                  pic: result['pic'] as String?,
                                  zs: result['zs'] as String?,
                                  rs: result['rs'] as String?,
                                  size: result['size'] as String?,
                                ),
                              );
                            });
                          }
                        },
                        icon: Icon(
                          Icons.settings,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          '添加目标',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF67C1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          minimumSize: Size(80, 32),
                        ),
                      ),
                    ],
                  ),
                  Container(height: 0.5, color: Colors.grey[300]!),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // 左侧导航栏
                        Container(
                          width: 70,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildNavItem('物料\n名称'),
                              _buildNavItem('规格1'),
                              _buildNavItem('规格2'),
                              _buildNavItem('供应商'),
                              _buildNavItem('备注'),
                              if (_showColor) _buildNavItem('颜色'),
                              if (_showMf) _buildNavItem('门幅'),
                              if (_showKz) _buildNavItem('克重'),
                              if (_showPic) _buildNavItem('图片'),
                              if (_showZs) _buildNavItem('织损'),
                              if (_showRs) _buildNavItem('染损'),
                              if (_showSize) _buildNavItem('尺码'),
                              _buildNavItem('订单\n数量'),
                              _buildNavItem('汇报\n数量', isActive: true),
                            ],
                          ),
                        ),

                        // 右侧内容区域
                        _isLoading
                            ? Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : items.isEmpty
                            ? Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'lib/assets/nodata.png',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        '暂无内容，请先「设置目标」',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                child: SizedBox(
                                  height:
                                      60.0 *
                                      (7 +
                                          (_showColor ? 1 : 0) +
                                          (_showMf ? 1 : 0) +
                                          (_showKz ? 1 : 0) +
                                          (_showPic ? 1 : 0) +
                                          (_showZs ? 1 : 0) +
                                          (_showRs ? 1 : 0) +
                                          (_showSize ? 1 : 0)),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      return SizedBox(
                                        width: 150,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildContentItem(
                                              item.materialName ?? '',
                                              isActive: true,
                                              onEdit: () async {
                                                final result =
                                                    await showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      builder: (_) =>
                                                          RepCustomAdd(
                                                            initialItem: item,
                                                            editIndex: index,
                                                          ),
                                                    );
                                                if (result != null &&
                                                    result
                                                        is Map<
                                                          String,
                                                          dynamic
                                                        >) {
                                                  setState(() {
                                                    items[index] = ReportItem(
                                                      id: item.id,
                                                      materialName:
                                                          result['materialName']
                                                              as String?,
                                                      spec1:
                                                          result['spec1']
                                                              as String?,
                                                      spec2:
                                                          result['spec2']
                                                              as String?,
                                                      supplier:
                                                          result['supplier']
                                                              as String?,
                                                      remark:
                                                          result['remark']
                                                              as String?,
                                                      qty:
                                                          (result['qty']
                                                                  as num?)
                                                              ?.toDouble() ??
                                                          0,
                                                      unit:
                                                          result['unit']
                                                              as String?,
                                                      completeNum:
                                                          item.completeNum,
                                                      currentReportNum:
                                                          item.currentReportNum,
                                                      materialColor:
                                                          result['materialColor']
                                                              as String?,
                                                      mf:
                                                          result['mf']
                                                              as String?,
                                                      kz:
                                                          result['kz']
                                                              as String?,
                                                      pic:
                                                          result['pic']
                                                              as String?,
                                                      zs:
                                                          result['zs']
                                                              as String?,
                                                      rs:
                                                          result['rs']
                                                              as String?,
                                                      size:
                                                          result['size']
                                                              as String?,
                                                    );
                                                  });
                                                }
                                              },
                                            ),
                                            _buildContentItem(item.spec1 ?? ''),
                                            _buildContentItem(item.spec2 ?? ''),
                                            _buildContentItem(
                                              item.supplier ?? '',
                                            ),
                                            _buildContentItem(
                                              item.remark ?? '',
                                            ),
                                            if (_showColor)
                                              _buildContentItem(
                                                item.materialColor ?? '',
                                              ),
                                            if (_showMf)
                                              _buildContentItem(item.mf ?? ''),
                                            if (_showKz)
                                              _buildContentItem(item.kz ?? ''),
                                            if (_showPic)
                                              _buildPicCell(item.pic),
                                            if (_showZs)
                                              _buildContentItem(item.zs ?? ''),
                                            if (_showRs)
                                              _buildContentItem(item.rs ?? ''),
                                            if (_showSize)
                                              _buildContentItem(
                                                item.size ?? '',
                                              ),
                                            _buildContentItem(
                                              '${item.completeNum.toString()}/${item.qty.toString()}',
                                            ),
                                            _buildContentItem(
                                              '${item.currentReportNum}${item.unit ?? ''}',
                                              isinput: true,
                                              onInputTap: () async {
                                                final result =
                                                    await showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      builder: (_) => InputNum(
                                                        initialValue: item
                                                            .currentReportNum,
                                                        title:
                                                            item.materialName ??
                                                            '',
                                                        unit: item.unit,
                                                      ),
                                                    );
                                                if (result != null &&
                                                    result is num) {
                                                  setState(() {
                                                    item.currentReportNum =
                                                        result.toDouble();
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
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
                              final fillQty = item.qty - item.completeNum;
                              item.currentReportNum = fillQty > 0 ? fillQty : 0;
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
                            'id': item.id,
                            'materialName': item.materialName,
                            'spec1': item.spec1,
                            'spec2': item.spec2,
                            'supplier': item.supplier,
                            'remark': item.remark,
                            'qty': item.qty,
                            'unit': item.unit,
                            'currentReportNum': item.currentReportNum,
                            if (_showColor) 'materialColor': item.materialColor,
                            if (_showMf) 'mf': item.mf,
                            if (_showKz) 'kz': item.kz,
                            if (_showPic) 'pic': item.pic,
                            if (_showZs) 'zs': item.zs,
                            if (_showRs) 'rs': item.rs,
                            if (_showSize) 'size': item.size,
                          },
                        )
                        .toList();
                    final totalQty = items.fold<double>(0, (s, i) => s + i.qty);
                    final totalDone = items.fold<double>(
                      0,
                      (s, i) => s + i.completeNum + i.currentReportNum,
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

  Widget _buildNavItem(String title, {bool isActive = false}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFFD6F7EE) : Color(0xFFEFEFEF),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: .5),
          left: isActive
              ? BorderSide(color: Color(0xFF0073FF), width: 3)
              : BorderSide(color: Colors.grey[300]!, width: .5),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Color(0xFF0073FF) : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPicCell(String? pic) {
    final urls = pic?.split(';').where((u) => u.isNotEmpty).toList() ?? [];
    if (urls.isEmpty) {
      return _buildContentItem('');
    }
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFFF6F6F6),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: .5),
          right: BorderSide(color: Colors.grey[300]!, width: .5),
        ),
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        children: urls.take(3).map((url) {
          return Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.only(right: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: 16, color: Colors.grey),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentItem(
    String title, {
    bool isActive = false,
    bool isinput = false,
    VoidCallback? onEdit,
    VoidCallback? onInputTap,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onInputTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 60,
            padding: isinput ? EdgeInsets.all(4) : EdgeInsets.zero,
            decoration: isinput
                ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: .5),
                      right: BorderSide(color: Colors.grey[300]!, width: .5),
                    ),
                  )
                : BoxDecoration(
                    color: Color(0xFFF6F6F6),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: .5),
                      right: BorderSide(color: Colors.grey[300]!, width: .5),
                    ),
                  ),
            child: isinput
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 12, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ),
        if (isActive && onEdit != null)
          Positioned(
            top: -8,
            right: -5,
            child: IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.border_color, size: 14, color: Colors.black),
            ),
          ),
      ],
    );
  }
}
