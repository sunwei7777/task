import 'package:flutter/material.dart';
import 'package:flutter_application_1/filter_page.dart';
import 'package:flutter_application_1/services/task_service.dart';
import 'package:flutter_application_1/store/task_controller.dart';
import 'package:flutter_application_1/task/task_look.dart';
import 'package:flutter_application_1/utils/common.dart';
import 'package:get/get.dart';

class TaskList extends StatefulWidget {
  final String title;
  final bool isSearch;
  final Function(int) onTaskSelected;
  final String? searchTaskNo;

  const TaskList({
    super.key,
    required this.title,
    this.isSearch = true,
    this.searchTaskNo,
    required this.onTaskSelected,
  });

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  int? _curIndex;
  String? _currentTab = '订单任务';
  String? _selectedSubType = '周期';
  String? _selectedStatus = 'all';
  final TaskController taskController = Get.find<TaskController>();
  final ScrollController _scrollController = ScrollController();

  // 筛选条件
  String? _filterTaskName;
  String? _filterStartTime;
  String? _filterEndTime;
  String? _filterOperator;
  String? _filterOperator1;
  Map<String, bool> _filterSelections = {};
  final TextEditingController _searchController = TextEditingController();
  final TaskService _taskService = TaskService();
  List<String> _suggestions = [];
  List<String> _suggestionTypes = []; // 'styleCode' or 'billNo'
  bool _showSuggestions = false;
  String? _searchType; // 'styleCode', 'billNo', or 'taskNo'
  bool _skipSuggestionFetch = false;
  String? _sortField;
  String? _sortOrder;

  bool get _isSearchMode =>
      widget.searchTaskNo != null && widget.searchTaskNo!.isNotEmpty;

  void _fetchWithFilters() {
    final text = _searchController.text.isNotEmpty
        ? _searchController.text
        : null;
    String? styleCode, billNo, taskNo;
    if (text != null) {
      if (_currentTab == '其他任务') {
        taskNo = text;
      } else if (_searchType == 'styleCode') {
        styleCode = text;
      } else if (_searchType == 'billNo') {
        billNo = text;
      } else if (_searchType == 'taskNo') {
        taskNo = text;
      }
    }
    taskController.fetchTasks(
      statusTab: _selectedStatus,
      taskType:
          _taskTypeConfig[_currentTab == '其他任务'
              ? _selectedSubType
              : _currentTab],
      styleCode: styleCode,
      billNo: billNo,
      taskNo: taskNo,
      taskName: _filterTaskName,
      startTime: _filterStartTime,
      endTime: _filterEndTime,
      operator: _filterOperator,
      operator1: _filterOperator1,
      sortField: _sortField,
      sortOrder: _sortOrder,
    );
  }

  int get _filterCount {
    int count = _filterSelections.values.where((v) => v).length;
    if (_filterTaskName != null && _filterTaskName!.isNotEmpty) count++;
    if (_filterStartTime != null && _filterStartTime!.isNotEmpty) count++;
    if (_filterEndTime != null && _filterEndTime!.isNotEmpty) count++;
    return count;
  }

  static const Map<String, int> _taskTypeConfig = {
    '项目任务': 1,
    '全部任务': 2,
    '订单任务': 2,
    '打样任务': 9,
    '周期': 4,
    '其他任务': 4,
    '临时': 3,
    '会议': 7,
    '外派': 8,
  };

  static const List<Map<String, String>> _statusConfig = [
    {'label': '全部', 'value': 'all'},
    {'label': '待处理', 'value': '1'},
    {'label': '已超时', 'value': '4'},
    {'label': '已完成', 'value': '2'},
    {'label': '已取消', 'value': '3'},
  ];
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {});
      if (!_skipSuggestionFetch) _fetchSuggestions();
    });
    _currentTab = widget.title == '全部任务' ? '订单任务' : widget.title;
    if (_currentTab == '其他任务') {
      taskController.fetchOtherTaskCounts(startTime: '', endTime: '');
    }
    if (widget.searchTaskNo != null && widget.searchTaskNo!.isNotEmpty) {
      _searchController.text = widget.searchTaskNo!;
      _searchType = 'taskNo';
      _currentTab = '';
      _skipSuggestionFetch = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWithFilters();
    });
  }

  Future<void> _fetchSuggestions() async {
    if (_currentTab == '其他任务' || _searchController.text.isEmpty) {
      _suggestions = [];
      _suggestionTypes = [];
      _showSuggestions = false;
      _searchType = null;
      return;
    }
    final result = await _taskService.queryBillNoAndStyleCode(
      taskType: _taskTypeConfig[_currentTab] ?? 2,
      queryContent: _searchController.text,
    );
    if (mounted) {
      final styleCodes = result['styleCode'] ?? [];
      final billNos = result['billNo'] ?? [];
      final items = <String>[];
      final types = <String>[];
      if (styleCodes.isNotEmpty) {
        items.add('__header_款号__');
        types.add('');
        items.addAll(styleCodes);
        types.addAll(styleCodes.map((_) => 'styleCode'));
      }
      if (billNos.isNotEmpty) {
        items.add('__header_订单编号__');
        types.add('');
        items.addAll(billNos);
        types.addAll(billNos.map((_) => 'billNo'));
      }
      setState(() {
        _suggestions = items;
        _suggestionTypes = types;
        _showSuggestions = items.isNotEmpty;
        _searchType = null;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !taskController.isLoadingMore.value &&
        taskController.hasMore.value) {
      taskController.loadMore();
    }
  }

  Widget _buildSortSheet() {
    final fields = ['createTime', 'startTime', 'endTime'];
    final fieldLabels = ['创建时间', '开始时间', '结束时间'];
    return StatefulBuilder(
      builder: (ctx, setInner) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '排序方式',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...List.generate(fields.length, (i) {
              final active = _sortField == fields[i];
              final asc = _sortOrder == 'asc';
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? Color(0xFFEDF3FF) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setInner(() {
                            _sortField = fields[i];
                            _sortOrder = active && asc ? 'desc' : 'asc';
                          });
                          Navigator.pop(ctx);
                          _fetchWithFilters();
                        },
                        child: Text(fieldLabels[i]),
                      ),
                    ),
                    if (active)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setInner(() => _sortOrder = 'asc');
                              Navigator.pop(ctx);
                              _fetchWithFilters();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: asc
                                    ? Color(0xFF0073FF)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '正序',
                                style: TextStyle(
                                  color: asc ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setInner(() => _sortOrder = 'desc');
                              Navigator.pop(ctx);
                              _fetchWithFilters();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: !asc
                                    ? Color(0xFF0073FF)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '倒序',
                                style: TextStyle(
                                  color: !asc ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  setInner(() {
                    _sortField = null;
                    _sortOrder = null;
                  });
                  Navigator.pop(ctx);
                  _fetchWithFilters();
                },
                child: Text('清除排序'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索栏
        if (widget.isSearch)
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              readOnly: _isSearchMode,
              style: TextStyle(fontSize: 14, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                hintText: _currentTab == '其他任务' ? '任务编号' : '款号、订单编号',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.grey[400],
                ),
                suffixIcon: _searchController.text.isNotEmpty && !_isSearchMode
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _fetchWithFilters();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) {
                _showSuggestions = false;
                _fetchWithFilters();
              },
            ),
          ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            color: Colors.white,
            constraints: BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (ctx, i) {
                final text = _suggestions[i];
                if (text.startsWith('__header_')) {
                  return Padding(
                    padding: EdgeInsets.only(top: i > 0 ? 8 : 0, bottom: 4),
                    child: Text(
                      text.replaceAll('__header_', '').replaceAll('__', ''),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  );
                }
                return ListTile(
                  dense: true,
                  title: Text(text, style: TextStyle(fontSize: 14)),
                  onTap: () {
                    _skipSuggestionFetch = true;
                    _searchController.text = text;
                    _searchType = _suggestionTypes[i];
                    _showSuggestions = false;
                    _skipSuggestionFetch = false;
                    _fetchWithFilters();
                  },
                );
              },
            ),
          ),

        // 任务类型标签
        !_isSearchMode && widget.title == '全部任务'
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(143, 143, 143, 0.14),
                      spreadRadius: 0,
                      blurRadius: 6,
                      offset: Offset(0, 3), // 阴影向下偏移3px
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildTab('订单任务'),
                    SizedBox(width: 12),
                    _buildTab('项目任务'),
                    SizedBox(width: 12),
                    _buildTab('打样任务'),
                    SizedBox(width: 12),
                    _buildTab('其他任务'),
                  ],
                ),
              )
            : Container(height: 8, color: Colors.white),

        // 子类型标签
        if (_currentTab == '其他任务')
          Container(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
              ),
            ),
            child: Obx(() {
              final c = taskController.otherTaskCounts.value;
              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildSubTypeTag('周期', c.periodic),
                  SizedBox(width: 12),
                  _buildSubTypeTag('临时', c.temporary),
                  SizedBox(width: 12),
                  _buildSubTypeTag('会议', c.meeting),
                  SizedBox(width: 12),
                  _buildSubTypeTag('外派', c.dispatch),
                ],
              );
            }),
          ),

        SizedBox(height: 12),

        // 状态标签
        if (!_isSearchMode)
          Container(
            height: 32,
            padding: EdgeInsets.only(left: 12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Obx(() {
                  final counts = <String, int>{
                    'all': taskController.totalCount.value,
                    '1': taskController.pendingCount.value,
                    '4': taskController.overtimeCount.value,
                    '2': taskController.completedCount.value,
                    '3': taskController.cancelledCount.value,
                  };
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._statusConfig.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: _buildStatusTag(
                            item['label']!,
                            counts[item['value']] ?? 0,
                            value: item['value'],
                          ),
                        ),
                      ),
                      SizedBox(width: 90),
                    ],
                  );
                }),
                // 悬浮排序按钮
                Positioned(
                  right: 56,
                  top: -10,
                  child: GestureDetector(
                    onTap: () async {
                      await showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (ctx) => _buildSortSheet(),
                      );
                      setState(() {});
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 52,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Colors.white,
                                Color.fromRGBO(255, 255, 255, 0),
                              ],
                              stops: [0.8, 1.0],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sort,
                                size: 16,
                                color: _sortField != null
                                    ? Color(0xFF0073FF)
                                    : null,
                              ),
                              Text(
                                '排序',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _sortField != null
                                      ? Color(0xFF0073FF)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_sortField != null)
                          Positioned(
                            top: 2,
                            right: 3,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // 悬浮筛查按钮
                Positioned(
                  right: 0,
                  top: -10,
                  child: GestureDetector(
                    onTap: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: FilterPage(
                              taskType: _taskTypeConfig[_currentTab] ?? 2,
                              initialTaskName: _filterTaskName,
                              initialStartTime: _filterStartTime,
                              initialEndTime: _filterEndTime,
                              initialFilters: _filterSelections,
                            ),
                          );
                        },
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _filterTaskName = result['taskName'] as String?;
                          _filterStartTime = result['startTime'] as String?;
                          _filterEndTime = result['endTime1'] as String?;
                          _filterOperator = result['operator'] as String?;
                          _filterOperator1 = result['operator1'] as String?;
                          _filterSelections =
                              (result['filters'] as Map<String, dynamic>?)?.map(
                                (k, v) => MapEntry(k, v as bool),
                              ) ??
                              {};
                        });
                        _fetchWithFilters();
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 52,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: Colors.white),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.filter_alt_outlined, size: 16),
                              Text('筛选', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        //红色个数角标
                        if (_filterCount > 0)
                          Positioned(
                            top: 2,
                            right: 3,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '$_filterCount',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 12),

        // 任务列表
        _buildTabView(),
      ],
    );
  }

  Widget _buildTab(String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTab = title;
            _selectedStatus = 'all';
            _selectedSubType = '周期';
            _filterTaskName = null;
            _filterStartTime = null;
            _filterEndTime = null;
            _filterOperator = null;
            _filterOperator1 = null;
            _filterSelections.clear();
            _fetchWithFilters();
            if (_currentTab == '其他任务') {
              taskController.fetchOtherTaskCounts(startTime: '', endTime: '');
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: _currentTab == title
                ? Border(bottom: BorderSide(color: Color(0xFF0073FF), width: 2))
                : Border(
                    bottom: BorderSide(color: Colors.transparent, width: 2),
                  ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: _currentTab == title ? Color(0xFF0073FF) : Colors.black,
              fontWeight: _currentTab == title
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTypeTag(String title, int count, {bool showBadge = false}) {
    bool isSelected = _selectedSubType == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubType = title;
          _selectedStatus = 'all';
          _filterTaskName = null;
          _filterStartTime = null;
          _filterEndTime = null;
          _filterOperator = null;
          _filterOperator1 = null;
          _filterSelections.clear();
          _fetchWithFilters();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Text(
              '$title($count)',
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Color(0xFF208BDE) : Colors.black,
              ),
            ),
            if (showBadge)
              Container(
                margin: EdgeInsets.only(left: 4),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '超时',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String title, int count, {String? value}) {
    bool isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = value;
          _fetchWithFilters();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Color(0xFF208BDE) : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
        child: Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Color(0xFF208BDE) : Colors.black,
          ),
        ),
      ),
    );
  }

  String _formatMd(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.length < 10) return '-';
    return dateTimeStr.substring(5, 10); // "yyyy-MM-dd" → "MM-dd"
  }

  Widget _buildTabView() {
    return Expanded(
      child: Obx(() {
        final tasks = taskController.allTasks;
        if (taskController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF0073FF)),
          );
        }
        return Container(
          color: Color(0xFFF9F9F9),
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(left: 12, right: 12),
            itemCount: tasks.length + 1,
            itemBuilder: (context, index) {
              if (index == tasks.length) {
                if (taskController.hasMore.value) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0073FF),
                      ),
                    ),
                  );
                }
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Text(
                    '— 加载完成 —',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                );
              }
              final task = tasks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskLook(
                        isHasDetail: _currentTab == '其他任务' ? true : false,
                        taskId: task.id,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // 圆角
                  ),
                  // ignore: deprecated_member_use
                  shadowColor: Colors.grey,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _curIndex = index;
                              if (_curIndex != null) {
                                widget.onTaskSelected(_curIndex!);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(bottom: 10, top: 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFF0F0F0),
                                  width: .5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: _curIndex == index
                                            ? Color(0xFF2B64FF)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: _curIndex != index
                                            ? Border.all(
                                                color: Colors.grey,
                                                width: 1,
                                              )
                                            : null,
                                      ),
                                      child: _curIndex == index
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      color: Color(0xFFEEF3FB),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          task.taskTypeDesc,
                                          style: TextStyle(
                                            color: Color(0xFF223A6D),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (task.taskName.endsWith('(外)'))
                                      Container(
                                        margin: EdgeInsets.only(right: 6),
                                        color: Color(0xFFFC9E02),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          child: Text(
                                            '外',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Text(
                                      task.taskNo,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Container(
                                    //   color: Color(0xFFFEE9E9),
                                    //   child: Padding(
                                    //     padding: EdgeInsets.symmetric(
                                    //       horizontal: 4,
                                    //       vertical: 2,
                                    //     ),
                                    //     child: Text(
                                    //       '预计延误',
                                    //       style: TextStyle(
                                    //         color: Colors.red,
                                    //         fontSize: 12,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    // SizedBox(width: 6),
                                    Container(
                                      color:
                                          (Common.statusBgColor[task
                                                      .statusDesc] ??
                                                  Colors.grey)
                                              .withValues(alpha: 0.15),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          task.statusDesc,
                                          style: TextStyle(
                                            color: Common
                                                .statusBgColor[task.statusDesc],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              // 进度与状态
                              Row(
                                children: [
                                  Text(
                                    task.taskName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${(task.progress).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1BA17D),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Container(
                                  //   color: Color(0xFFFEE9E9),
                                  //   child: Padding(
                                  //     padding: EdgeInsets.symmetric(
                                  //       horizontal: 4,
                                  //       vertical: 2,
                                  //     ),
                                  //     child: Row(
                                  //       children: [
                                  //         Icon(
                                  //           Icons.remove_circle_outline,
                                  //           color: Color(0xFFE46723),
                                  //           size: 12,
                                  //         ),
                                  //         Text(
                                  //           '3',
                                  //           style: TextStyle(
                                  //             color: Color(0xFFE35100),
                                  //             fontSize: 12,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  // const SizedBox(width: 6),
                                  // Container(
                                  //   color: Color(0xFFFEE9E9),
                                  //   child: Padding(
                                  //     padding: EdgeInsets.symmetric(
                                  //       horizontal: 4,
                                  //       vertical: 2,
                                  //     ),
                                  //     child: Row(
                                  //       children: [
                                  //         Icon(
                                  //           Icons.not_interested,
                                  //           color: Colors.red,
                                  //           size: 12,
                                  //         ),
                                  //         Text(
                                  //           '3',
                                  //           style: TextStyle(
                                  //             color: Color(0xFFE35100),
                                  //             fontSize: 12,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF4F5F8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    if (task.billNo?.isNotEmpty == true)
                                      Row(
                                        children: [
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: Text(
                                          //     _currentTab == 0
                                          //         ? '款号: -'
                                          //         : '内容：${task.taskContent ?? '-'}',
                                          //     style: const TextStyle(
                                          //       color: Colors.black54,
                                          //       fontSize: 14,
                                          //     ),
                                          //     overflow: TextOverflow
                                          //         .ellipsis, // 超出显示省略号
                                          //     maxLines: 1,
                                          //   ),
                                          // ),
                                          // const SizedBox(width: 6),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${_currentTab == '项目任务' ? '项目编号' : '订单编号'}: ${task.billNo}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // 超出显示省略号
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (task.billNo?.isNotEmpty == true)
                                      const SizedBox(height: 8),
                                    if (_currentTab != '项目任务' &&
                                        task.styleCode?.isNotEmpty == true)
                                      Row(
                                        children: [
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: Text(
                                          //     _currentTab == 0
                                          //         ? '款号: -'
                                          //         : '内容：${task.taskContent ?? '-'}',
                                          //     style: const TextStyle(
                                          //       color: Colors.black54,
                                          //       fontSize: 14,
                                          //     ),
                                          //     overflow: TextOverflow
                                          //         .ellipsis, // 超出显示省略号
                                          //     maxLines: 1,
                                          //   ),
                                          // ),
                                          // const SizedBox(width: 6),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '款号: ${task.styleCode}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // 超出显示省略号
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (_currentTab != '项目任务' &&
                                        task.styleCode?.isNotEmpty == true)
                                      const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Expanded(
                                        //   flex: 1,
                                        //   child: Text(
                                        //     _currentTab == 0
                                        //         ? '款号: -'
                                        //         : '内容：${task.taskContent ?? '-'}',
                                        //     style: const TextStyle(
                                        //       color: Colors.black54,
                                        //       fontSize: 14,
                                        //     ),
                                        //     overflow: TextOverflow
                                        //         .ellipsis, // 超出显示省略号
                                        //     maxLines: 1,
                                        //   ),
                                        // ),
                                        // const SizedBox(width: 6),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            _currentTab == '项目任务'
                                                ? '来源：${task.taskSource ?? '-'}'
                                                : '负责人: ${task.principals}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // 超出显示省略号
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Expanded(
                                        //   flex: 1,
                                        //   child: Text(
                                        //     '交货倒计时: -天',
                                        //     style: const TextStyle(
                                        //       color: Colors.black54,
                                        //       fontSize: 14,
                                        //     ),
                                        //     overflow: TextOverflow
                                        //         .ellipsis, // 超出显示省略号
                                        //     maxLines: 1,
                                        //   ),
                                        // ),
                                        // const SizedBox(width: 6),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '计划区间: ${_formatMd(task.startTime)} 至 ${_formatMd(task.endTime)}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // 超出显示省略号
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_currentTab == '其他任务')
                                      const SizedBox(height: 8),
                                    if (_currentTab == '其他任务')
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '任务内容： ${task.taskContent ?? '-'}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // 超出显示省略号
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Text(
                                          '创建时间',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF999999),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          task.createTime ?? '-',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Positioned(
                                  //   right: -14,
                                  //   bottom: -6,
                                  //   child: Container(
                                  //     padding: EdgeInsets.symmetric(
                                  //       horizontal: 8,
                                  //       vertical: 2,
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //       color: Color(0xFF208BDE),
                                  //       borderRadius: BorderRadius.only(
                                  //         topLeft: Radius.circular(4),
                                  //         bottomRight: Radius.circular(4),
                                  //       ),
                                  //     ),
                                  //     child: Row(
                                  //       children: [
                                  //         Icon(
                                  //           Icons.access_time,
                                  //           color: Colors.white,
                                  //           size: 12,
                                  //         ),
                                  //         SizedBox(width: 4),
                                  //         Text(
                                  //           '-天',
                                  //           style: TextStyle(
                                  //             color: Colors.white,
                                  //             fontSize: 12,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
