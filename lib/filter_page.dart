import 'package:flutter/material.dart';
import 'package:flutter_application_1/assets/app_styles.dart';
import 'package:flutter_application_1/services/task_service.dart';
import 'package:flutter_application_1/utils/form_widgets.dart';

class FilterPage extends StatefulWidget {
  final int taskType;
  final String? initialTaskName;
  final String? initialStartTime;
  final String? initialEndTime;
  final Map<String, bool>? initialFilters;

  const FilterPage({
    super.key,
    this.taskType = 2,
    this.initialTaskName,
    this.initialStartTime,
    this.initialEndTime,
    this.initialFilters,
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final TaskService _taskService = TaskService();
  List<String> _workTypes = [];
  List<String> _customerNames = [];

  // 筛选类别列表
  final List<String> filterCategories = [
    '任务名称',
    '工序类型',
    '交期',
    '任务周期',
    '汇报类型',
    '任务情况',
    '客户名称',
  ];

  // 当前选中的类别索引
  int _selectedCategoryIndex = 0;

  late final List<GlobalKey> _sectionKeys = List.generate(
    filterCategories.length,
    (_) => GlobalKey(),
  );

  // 筛选选项的选中状态
  Map<String, bool> _selectedFilters = {};

  // 日期选择状态
  DateTime? _deliveryStartDate;
  DateTime? _deliveryEndDate;
  DateTime? _cycleStartDate;
  DateTime? _cycleEndDate;

  // 任务名称输入
  final TextEditingController _taskNameController = TextEditingController();

  // 展开状态
  final Map<String, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    // _fetchData();
    if (widget.initialTaskName != null) {
      _taskNameController.text = widget.initialTaskName!;
    }
    if (widget.initialStartTime != null) {
      _cycleStartDate = DateTime.tryParse(widget.initialStartTime!);
    }
    if (widget.initialEndTime != null) {
      _cycleEndDate = DateTime.tryParse(widget.initialEndTime!);
    }
    if (widget.initialFilters != null) {
      _selectedFilters = Map<String, bool>.from(widget.initialFilters!);
    }
  }

  Future<void> _fetchData() async {
    final results = await Future.wait([
      _taskService.fetchWorkTypes(widget.taskType),
      _taskService.fetchCustomerInfo(widget.taskType),
    ]);
    setState(() {
      _workTypes = results[0];
      _customerNames = results[1];
    });
  }

  void _toggleSection(String key) {
    setState(() {
      _expandedSections[key] = !(_expandedSections[key] ?? false);
    });
  }

  // 切换筛选选项的选中状态
  void _toggleFilter(String label) {
    setState(() {
      _selectedFilters[label] = !(_selectedFilters[label] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '筛选内容',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Container(color: Colors.grey[300], height: 0.5),
        ),
      ),
      body: Row(
        children: [
          // 左侧筛选类别列表
          // SizedBox(
          //   width: 90,
          //   child: ListView.builder(
          //     itemCount: filterCategories.length,
          //     itemBuilder: (context, index) {
          //       return GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             _selectedCategoryIndex = index;
          //           });
          //           if (_sectionKeys.length > index) {
          //             Scrollable.ensureVisible(
          //               _sectionKeys[index].currentContext!,
          //               alignment: 0,
          //               duration: Duration(milliseconds: 300),
          //             );
          //           }
          //         },
          //         child: Container(
          //           padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          //           decoration: BoxDecoration(
          //             color: _selectedCategoryIndex == index
          //                 ? Colors.white
          //                 : Color(0xFFF6F7FA),
          //             border: Border(
          //               left: _selectedCategoryIndex == index
          //                   ? BorderSide(color: Color(0xFF0073FF), width: 3)
          //                   : BorderSide.none,
          //             ),
          //           ),
          //           child: Text(
          //             filterCategories[index],
          //             style: TextStyle(
          //               fontSize: 14,
          //               color: _selectedCategoryIndex == index
          //                   ? Color(0xFF0073FF)
          //                   : Colors.black,
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),

          // 右侧筛选选项
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: _buildFilterContent(_selectedCategoryIndex),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _taskNameController.clear();
                    _cycleStartDate = null;
                    _cycleEndDate = null;
                    _deliveryStartDate = null;
                    _deliveryEndDate = null;
                    _selectedFilters.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  '清空全部',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final result = <String, dynamic>{
                    'taskName': _taskNameController.text,
                    'filters': Map<String, bool>.from(_selectedFilters),
                  };
                  if (_cycleStartDate != null) {
                    result['startTime'] = _cycleStartDate!.toString();
                    result['operator'] = '>=';
                  }
                  if (_cycleEndDate != null) {
                    result['endTime1'] = _cycleEndDate!.toString();
                    result['operator1'] = '<=';
                  }
                  if (_deliveryStartDate != null) {
                    result['deliveryStartDate'] = _deliveryStartDate!
                        .toString();
                  }
                  if (_deliveryEndDate != null) {
                    result['deliveryEndDate'] = _deliveryEndDate!.toString();
                  }
                  Navigator.pop(context, result);
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
            ),
          ],
        ),
      ),
    );
  }

  // 构建所有筛选内容
  Widget _buildFilterContent(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 任务类型
        Container(
          key: _sectionKeys[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '任务名称',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  hintText: '请输入任务名称',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: AppStyles.border,
                  enabledBorder: AppStyles.enabledBorder,
                  focusedBorder: AppStyles.focusedBorder,
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),

        // 工序类型
        // Container(
        //   key: _sectionKeys[1],
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         '工序类型',
        //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //       ),
        //       SizedBox(height: 16),
        //       _buildExpandableChips('workTypes', _workTypes),
        //       SizedBox(height: 24),
        //     ],
        //   ),
        // ),

        // 交期
        // Container(
        //   key: _sectionKeys[2],
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         '交期',
        //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //       ),
        //       SizedBox(height: 16),
        //       Row(
        //         children: [
        //           Expanded(
        //             child: FormWidgets.showDateTime(
        //               context,
        //               '开始时间',
        //               _deliveryStartDate,
        //               onPressed: (selectedDateTime) {
        //                 setState(() => _deliveryStartDate = selectedDateTime);
        //                 Navigator.pop(context);
        //                 return null;
        //               },
        //             ),
        //           ),
        //           SizedBox(width: 12),
        //           Text('—'),
        //           SizedBox(width: 12),
        //           Expanded(
        //             child: FormWidgets.showDateTime(
        //               context,
        //               '结束时间',
        //               _deliveryEndDate,
        //               onPressed: (selectedDateTime) {
        //                 setState(() => _deliveryEndDate = selectedDateTime);
        //                 Navigator.pop(context);
        //                 return null;
        //               },
        //             ),
        //           ),
        //         ],
        //       ),
        //       SizedBox(height: 24),
        //     ],
        //   ),
        // ),

        // 任务周期
        Container(
          key: _sectionKeys[3],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '任务周期',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormWidgets.showDateTime(
                      context,
                      '开始时间',
                      _cycleStartDate,
                      onPressed: (selectedDateTime) {
                        setState(() => _cycleStartDate = selectedDateTime);
                        Navigator.pop(context);
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('—'),
                  SizedBox(width: 12),
                  Expanded(
                    child: FormWidgets.showDateTime(
                      context,
                      '结束时间',
                      _cycleEndDate,
                      onPressed: (selectedDateTime) {
                        setState(() => _cycleEndDate = selectedDateTime);
                        Navigator.pop(context);
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
            ],
          ),
        ),

        // 汇报类型
        // Container(
        //   key: _sectionKeys[4],
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         '汇报类型',
        //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //       ),
        //       SizedBox(height: 16),
        //       Wrap(
        //         spacing: 12,
        //         runSpacing: 8,
        //         children: [
        //           _buildFilterChip('整体汇报'),
        //           _buildFilterChip('SKU汇报'),
        //           _buildFilterChip('自定义汇报'),
        //         ],
        //       ),
        //       SizedBox(height: 24),
        //     ],
        //   ),
        // ),

        // 任务情况
        // Container(
        //   key: _sectionKeys[5],
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         '任务情况',
        //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //       ),
        //       SizedBox(height: 16),
        //       Wrap(
        //         spacing: 12,
        //         runSpacing: 8,
        //         children: [
        //           _buildFilterChip('可开始'),
        //           _buildFilterChip('有阻碍'),
        //           _buildFilterChip('我阻碍'),
        //         ],
        //       ),
        //       SizedBox(height: 24),
        //     ],
        //   ),
        // ),

        // 客户名称
        // Container(
        //   key: _sectionKeys[6],
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         '客户名称',
        //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //       ),
        //       SizedBox(height: 16),
        //       _buildExpandableChips('customerNames', _customerNames),
        //       SizedBox(height: 24),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilters[label] ?? false;
    return GestureDetector(
      onTap: () {
        _toggleFilter(label);
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFE6F2FF) : Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Color(0xFF0073FF) : Colors.black,
              ),
            ),
          ),
          Positioned(
            child: isSelected
                ? Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(0xFF208BDE),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Icon(Icons.check, size: 12, color: Colors.white),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableChips(String sectionKey, List<String> items) {
    if (items.isEmpty) return SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width - 32 - 90;
    const avgChipWidth = 80.0;
    const chipSpacing = 12.0;
    final chipsPerRow =
        ((screenWidth + chipSpacing) / (avgChipWidth + chipSpacing))
            .floor()
            .clamp(2, 8);
    final maxVisible = chipsPerRow * 3;

    final isExpanded = _expandedSections[sectionKey] ?? false;
    final showExpand = items.length > maxVisible + 2;

    if (!isExpanded && showExpand) {
      final visible = items.take(maxVisible).toList();
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          ...visible.map((type) => _buildFilterChip(type)),
          GestureDetector(
            onTap: () => _toggleSection(sectionKey),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '查看全部',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        ...items.map((type) => _buildFilterChip(type)),
        if (showExpand)
          GestureDetector(
            onTap: () => _toggleSection(sectionKey),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '收起',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_up, size: 14, color: Colors.black),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
