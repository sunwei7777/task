import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/task_service.dart';

class CorrelationOrder extends StatefulWidget {
  final String companyId;
  const CorrelationOrder({Key? key, required this.companyId}) : super(key: key);

  @override
  _CorrelationOrderState createState() => _CorrelationOrderState();
}

class _CorrelationOrderState extends State<CorrelationOrder> {
  final TaskService _taskService = TaskService();
  int _currentTabIndex = 0;

  // ============ 订单列表状态 ============
  int? _selectedIndex;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  // 筛选参数
  final TextEditingController _styleCodeController = TextEditingController();
  final TextEditingController _custIdNameController = TextEditingController();
  final TextEditingController _salerIdNameController = TextEditingController();
  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _styleNameController = TextEditingController();
  String? _selectedOrderState;
  String? _selectedOrderStateLabel;
  bool _stateExpanded = true;

  final List<String> _orderStateOptions = ['未分配', '正常', '预计延期', '已延期', '草稿'];

  // ============ 项目集列表状态 ============
  List<Map<String, dynamic>> _projectGroups = [];
  bool _isLoadingGroups = false;
  int? _selectedGroupIndex;

  bool _isInStepTwo = false;
  String? _selectedGroupName;
  int? _selectedGroupId;
  List<Map<String, dynamic>> _groupItems = [];
  bool _isLoadingGroupItems = false;
  bool _hasMoreGroupItems = true;
  int _groupItemCurrentPage = 1;
  int? _selectedItemIndex;

  // 项目筛选参数
  final TextEditingController _projectNoController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _personInChargeController =
      TextEditingController();
  String? _projectOrderState;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _loadProjectGroups();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _styleCodeController.dispose();
    _custIdNameController.dispose();
    _salerIdNameController.dispose();
    _billNoController.dispose();
    _styleNameController.dispose();
    _projectNoController.dispose();
    _projectNameController.dispose();
    _personInChargeController.dispose();
    super.dispose();
  }

  // ============ 订单列表加载 ============

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadOrders(loadMore: true);
    }
  }

  int get _activeFilterCount {
    int count = 0;
    if (_billNoController.text.trim().isNotEmpty) count++;
    if (_styleCodeController.text.trim().isNotEmpty) count++;
    if (_styleNameController.text.trim().isNotEmpty) count++;
    if (_custIdNameController.text.trim().isNotEmpty) count++;
    if (_salerIdNameController.text.trim().isNotEmpty) count++;
    if (_selectedOrderState != null) count++;
    return count;
  }

  Future<void> _loadOrders({bool loadMore = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
    }

    final filterParams = {
      'styleCode': _styleCodeController.text.trim(),
      'custIdName': _custIdNameController.text.trim(),
      'salerIdName': _salerIdNameController.text.trim(),
      'billNo': _billNoController.text.trim(),
      'orderState': _selectedOrderState,
      'styleName': _styleNameController.text.trim(),
      'currentPage': _currentPage,
      'pageSize': _pageSize,
    };
    print('======= 订单列表筛选参数 =======');
    filterParams.forEach((k, v) => print('  $k: $v'));
    print('==============================');

    try {
      final result = await _taskService.fetchOrderList(
        styleCode: _styleCodeController.text.trim(),
        custIdName: _custIdNameController.text.trim(),
        salerIdName: _salerIdNameController.text.trim(),
        billNo: _billNoController.text.trim(),
        orderState: _selectedOrderState,
        styleName: _styleNameController.text.trim(),
        current: _currentPage,
        pageSize: _pageSize,
        operator: "等于",
      );
      final records = (result['records'] as List<dynamic>?) ?? [];
      final total = result['total'] as int? ?? 0;
      setState(() {
        if (loadMore) {
          _orders.addAll(records.cast<Map<String, dynamic>>());
        } else {
          _orders = records.cast<Map<String, dynamic>>();
        }
        _hasMore = _orders.length < total;
        if (_hasMore) _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载订单失败: $e')));
      }
    }
  }

  // ============ 项目集加载 ============

  Future<void> _loadProjectGroups() async {
    if (_isLoadingGroups) return;
    setState(() => _isLoadingGroups = true);
    try {
      final groups = await _taskService.fetchProjectGroups(
        companyId: widget.companyId,
      );
      print('======= 项目集列表返回 =======');
      print('  数量: ${groups.length}');
      if (groups.isNotEmpty) print('  第一条字段: ${groups.first.keys.toList()}');
      print('==============================');
      setState(() {
        _projectGroups = groups;
        _isLoadingGroups = false;
      });
    } catch (e) {
      setState(() => _isLoadingGroups = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载项目集失败: $e')));
      }
    }
  }

  // ============ 状态颜色 ============

  String _getStateLabel(String? state) => state ?? '--';

  Color _getStateColor(String? state) {
    switch (state) {
      case '未分配':
        return Color(0xFF8C8C8C);
      case '正常':
        return Color(0xFF52C41A);
      case '预计延期':
        return Color(0xFFFA8C16);
      case '已延期':
        return Color(0xFFF5222D);
      case '草稿':
        return Color(0xFF8C8C8C);
      default:
        return Color(0xFF8C8C8C);
    }
  }

  Color _getStateBgColor(String? state) {
    switch (state) {
      case '未分配':
        return Color(0xFFF5F5F5);
      case '正常':
        return Color(0xFFF6FFED);
      case '预计延期':
        return Color(0xFFFFF7E6);
      case '已延期':
        return Color(0xFFFFF1F0);
      case '草稿':
        return Color(0xFFF5F5F5);
      default:
        return Color(0xFFF5F5F5);
    }
  }

  // ============ 筛选面板 ============

  void _showFilterSheet() {
    var tempState = _selectedOrderState;
    var tempStateLabel = _selectedOrderStateLabel;
    var tempBillNo = _billNoController.text;
    var tempStyleCode = _styleCodeController.text;
    var tempStyleName = _styleNameController.text;
    var tempCustIdName = _custIdNameController.text;
    var tempSalerIdName = _salerIdNameController.text;
    var tempStateExpanded = _stateExpanded;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '筛选',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 22),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Flexible(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: [
                        _buildSheetSection(
                          title: '订单状态',
                          expanded: tempStateExpanded,
                          onToggle: () => setSheetState(
                            () => tempStateExpanded = !tempStateExpanded,
                          ),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _orderStateOptions.map((label) {
                              final selected = tempState == label;
                              return GestureDetector(
                                onTap: () => setSheetState(() {
                                  tempState = selected ? null : label;
                                  tempStateLabel = selected ? null : label;
                                }),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Color(0xFF0073FF)
                                        : Color(0xFFF5F6FA),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : Color(0xFF333333),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildSheetInput(
                          '订单编号',
                          tempBillNo,
                          (v) => tempBillNo = v,
                        ),
                        SizedBox(height: 12),
                        _buildSheetInput(
                          '款号',
                          tempStyleCode,
                          (v) => tempStyleCode = v,
                        ),
                        SizedBox(height: 12),
                        _buildSheetInput(
                          '产品名称',
                          tempStyleName,
                          (v) => tempStyleName = v,
                        ),
                        SizedBox(height: 12),
                        _buildSheetInput(
                          '客户',
                          tempCustIdName,
                          (v) => tempCustIdName = v,
                        ),
                        SizedBox(height: 12),
                        _buildSheetInput(
                          '业务员',
                          tempSalerIdName,
                          (v) => tempSalerIdName = v,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      MediaQuery.of(context).padding.bottom + 12,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              tempState = null;
                              tempStateLabel = null;
                              tempBillNo = '';
                              tempStyleCode = '';
                              tempStyleName = '';
                              tempCustIdName = '';
                              tempSalerIdName = '';
                            });
                          },
                          child: Container(
                            height: 44,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Text(
                              '重置',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _selectedOrderState = tempState;
                              _selectedOrderStateLabel = tempStateLabel;
                              _billNoController.text = tempBillNo;
                              _styleCodeController.text = tempStyleCode;
                              _styleNameController.text = tempStyleName;
                              _custIdNameController.text = tempCustIdName;
                              _salerIdNameController.text = tempSalerIdName;
                              _stateExpanded = tempStateExpanded;
                              Navigator.pop(context);
                              _loadOrders();
                            },
                            child: Container(
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFF0073FF),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Text(
                                '确定',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetSection({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
        if (expanded) ...[SizedBox(height: 10), child],
      ],
    );
  }

  Widget _buildSheetInput(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              ),
            ),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: '请输入',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0073FF)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              isDense: true,
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetDateItem(
    String label,
    String? value,
    Function(String?) onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                locale: Locale('zh'),
              );
              if (picked != null) {
                onChanged(
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? '请选择',
                      style: TextStyle(
                        color: value != null
                            ? Color(0xFF333333)
                            : Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============ 搜索 + 筛选栏 ============

  Widget _buildSearchAndFilterBar() {
    final filterCount = _activeFilterCount;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                controller: _styleCodeController,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '输入款号，按Enter搜索',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                  isDense: true,
                ),
                onSubmitted: (_) => _loadOrders(),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: _showFilterSheet,
            child: SizedBox(
              width: 44,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.filter_alt_outlined,
                        size: 18,
                        color: Color(0xFF333333),
                      ),
                      if (filterCount > 0)
                        Positioned(
                          right: -8,
                          top: -6,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF4D4F),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: BoxConstraints(minWidth: 14),
                            child: Text(
                              '$filterCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    '筛选',
                    style: TextStyle(fontSize: 11, color: Color(0xFF333333)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ 订单项卡片 ============

  Widget _buildProjectItem(int index) {
    final item = _groupItems[index];
    final isSelected = _selectedItemIndex == index;
    final stateColor = _getStateColor(item['orderState'] as String?);
    final stateBgColor = _getStateBgColor(item['orderState'] as String?);
    final stateLabel = _getStateLabel(item['orderState'] as String?);

    return GestureDetector(
      onTap: () => setState(() => _selectedItemIndex = index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Color(0xFF0073FF) : Colors.grey[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xFF2B64FF)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey, width: 1),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      SizedBox(width: 8),
                      Text(
                        item['projectNo']?.toString() ?? '--',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: stateBgColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      stateLabel,
                      style: TextStyle(color: stateColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            _buildDetailRow('项目名称', item['projectName']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('负责人', item['personInCharge']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('所属企业', item['company']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('计划完成', item['planDate']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('预计交货', item['predictPlanDate']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('创建人', item['createBy']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('创建时间', item['createdTime']?.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(
    int index, {
    List<Map<String, dynamic>>? items,
    int? selectedIdx,
    Function(int)? onselect,
  }) {
    final list = items ?? _orders;
    final selIdx = selectedIdx ?? _selectedIndex;
    final onTap = onselect ?? ((i) => setState(() => _selectedIndex = i));
    final order = list[index];
    final isSelected = selIdx == index;
    final stateColor = _getStateColor(order['orderState'] as String?);
    final stateBgColor = _getStateBgColor(order['orderState'] as String?);
    final stateLabel = _getStateLabel(order['orderState'] as String?);

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Color(0xFF0073FF) : Colors.grey[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xFF2B64FF)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey, width: 1),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      SizedBox(width: 8),
                      Text(
                        order['billNo']?.toString() ?? '--',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: stateBgColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      stateLabel,
                      style: TextStyle(color: stateColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            _buildDetailRow('款号', order['styleCode']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('产品名称', order['styleName']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('客户', order['custIdName']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('业务员', order['salerIdName']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('交货时间', order['planDate']?.toString()),
            SizedBox(height: 4),
            _buildDetailRow('预计交货', order['predictPlanDate']?.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value ?? '--',
            style: TextStyle(fontSize: 13, color: Colors.black87),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ============ 项目集Tab内容 ============

  Widget _buildProjectGroupTabBody() {
    if (_isInStepTwo) return _buildStepTwoItems();
    return _buildStepOneGroups();
  }

  // 第一步：选择项目集
  Widget _buildStepOneGroups() {
    if (_isLoadingGroups) {
      return Center(child: CircularProgressIndicator());
    }
    if (_projectGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              '暂无项目集数据',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      itemCount: _projectGroups.length,
      itemBuilder: (context, index) {
        final group = _projectGroups[index];
        final isSelected = _selectedGroupIndex == index;
        final groupName =
            group['projectGroupName']?.toString() ??
            group['groupName']?.toString() ??
            '--';
        final itemCount = group['projectCount'] ?? group['orderCount'] ?? 0;
        final createDate = group['createTime']?.toString() ?? '';

        return GestureDetector(
          onTap: () => setState(() => _selectedGroupIndex = index),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? Color(0xFF0073FF) : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.folder, color: Color(0xFF0073FF), size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // SizedBox(height: 4),
                      // Text('$itemCount 个项目  $createDate', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // 进入第二步
  void _enterStepTwo() {
    if (_selectedGroupIndex == null) return;
    final group = _projectGroups[_selectedGroupIndex!];
    final groupName =
        group['projectGroupName']?.toString() ??
        group['groupName']?.toString() ??
        '项目集';
    final groupId = group['id'];
    setState(() {
      _isInStepTwo = true;
      _selectedGroupName = groupName;
      _selectedGroupId = groupId is int
          ? groupId
          : int.tryParse(groupId?.toString() ?? '');
      _groupItems = [];
      _groupItemCurrentPage = 1;
      _hasMoreGroupItems = true;
      _selectedItemIndex = null;
    });
    _loadGroupItems();
  }

  Future<void> _loadGroupItems({bool loadMore = false}) async {
    if (_isLoadingGroupItems || _selectedGroupId == null) return;
    setState(() => _isLoadingGroupItems = true);
    if (!loadMore) {
      _groupItemCurrentPage = 1;
      _hasMoreGroupItems = true;
    }

    try {
      final result = await _taskService.fetchProjectTaskList(
        projectGroupId: _selectedGroupId!,
        projectNo: _projectNoController.text.trim(),
        projectName: _projectNameController.text.trim(),
        orderState: _projectOrderState,
        personInCharge: _personInChargeController.text.trim(),
        currentPage: _groupItemCurrentPage,
        pageSize: 20,
      );
      final records = (result['records'] as List<dynamic>?) ?? [];
      final total = result['total'] as int? ?? 0;
      setState(() {
        if (loadMore) {
          _groupItems.addAll(records.cast<Map<String, dynamic>>());
        } else {
          _groupItems = records.cast<Map<String, dynamic>>();
        }
        _hasMoreGroupItems = _groupItems.length < total;
        if (_hasMoreGroupItems) _groupItemCurrentPage++;
        _isLoadingGroupItems = false;
      });
    } catch (e) {
      setState(() => _isLoadingGroupItems = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载项目列表失败: $e')));
      }
    }
  }

  void _goBackToStepOne() {
    setState(() {
      _isInStepTwo = false;
      _selectedItemIndex = null;
      _groupItems = [];
      _projectNoController.clear();
      _projectNameController.clear();
      _personInChargeController.clear();
      _projectOrderState = null;
    });
  }

  // 项目筛选面板
  void _showProjectFilterSheet() {
    var tempProjectNo = _projectNoController.text;
    var tempProjectName = _projectNameController.text;
    var tempPersonInCharge = _personInChargeController.text;
    var tempOrderState = _projectOrderState;
    final stateOptions = ['未分配', '正常', '预计延期', '已延期', '草稿'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '筛选',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 22),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Flexible(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: stateOptions.map((label) {
                            final selected = tempOrderState == label;
                            return GestureDetector(
                              onTap: () => setSheetState(() {
                                tempOrderState = selected ? null : label;
                              }),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Color(0xFF0073FF)
                                      : Color(0xFFF5F6FA),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Color(0xFF333333),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),
                        _buildSheetInput(
                          '项目编号',
                          tempProjectNo,
                          (v) => tempProjectNo = v,
                        ),
                        SizedBox(height: 12),
                        _buildSheetInput(
                          '项目名称',
                          tempProjectName,
                          (v) => tempProjectName = v,
                        ),
                        SizedBox(height: 12),
                        _buildSheetInput(
                          '负责人',
                          tempPersonInCharge,
                          (v) => tempPersonInCharge = v,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      MediaQuery.of(context).padding.bottom + 12,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              tempProjectNo = '';
                              tempProjectName = '';
                              tempPersonInCharge = '';
                              tempOrderState = null;
                            });
                          },
                          child: Container(
                            height: 44,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Text(
                              '重置',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _projectNoController.text = tempProjectNo;
                              _projectNameController.text = tempProjectName;
                              _personInChargeController.text =
                                  tempPersonInCharge;
                              _projectOrderState = tempOrderState;
                              Navigator.pop(context);
                              _loadGroupItems();
                            },
                            child: Container(
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFF0073FF),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Text(
                                '确定',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 第二步：选择项目集内的项目
  Widget _buildStepTwoItems() {
    final projectFilterCount = [
      _projectNoController.text.trim(),
      _projectNameController.text.trim(),
      _personInChargeController.text.trim(),
      _projectOrderState,
    ].where((v) => v != null && v.isNotEmpty).length;

    return Column(
      children: [
        // 面包屑导航
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              GestureDetector(
                onTap: _goBackToStepOne,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 14,
                      color: Color(0xFF0073FF),
                    ),
                    Text(
                      '项目集列表',
                      style: TextStyle(color: Color(0xFF0073FF), fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 14, color: Colors.grey[400]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedGroupName ?? '项目列表',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // 搜索 + 筛选
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TextField(
                    controller: _projectNoController,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '输入项目编号，按Enter搜索',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 9),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _loadGroupItems(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: _showProjectFilterSheet,
                child: SizedBox(
                  width: 44,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.filter_alt_outlined,
                            size: 18,
                            color: Color(0xFF333333),
                          ),
                          if (projectFilterCount > 0)
                            Positioned(
                              right: -8,
                              top: -6,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF4D4F),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: BoxConstraints(minWidth: 14),
                                child: Text(
                                  '$projectFilterCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        '筛选',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 项目列表
        Expanded(
          child: _isLoadingGroupItems && _groupItems.isEmpty
              ? Center(child: CircularProgressIndicator())
              : _groupItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '该项目集下暂无数据',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(top: 8),
                  itemCount: _groupItems.length + (_hasMoreGroupItems ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _groupItems.length) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return _buildProjectItem(index);
                  },
                ),
        ),
      ],
    );
  }

  // ============ 确定按钮逻辑 ============

  bool get _canConfirm {
    if (_currentTabIndex == 0) return _selectedIndex != null;
    if (_isInStepTwo) return _selectedItemIndex != null;
    return _selectedGroupIndex != null;
  }

  String get _confirmText {
    if (_currentTabIndex == 0) return '确定';
    if (_isInStepTwo) return '确定';
    return '下一步';
  }

  void _onConfirm() {
    if (_currentTabIndex == 0) {
      // 订单列表 → 直接返回
      final selected = _orders[_selectedIndex!];
      Navigator.pop(context, selected);
    } else if (_isInStepTwo) {
      // 项目集第二步 → 返回选中的项目
      final selected = _groupItems[_selectedItemIndex!];
      Navigator.pop(context, selected);
    } else {
      // 项目集第一步 → 进入第二步
      _enterStepTwo();
    }
  }

  // ============ 页面构建 ============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEF0F2),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          '关联项目/订单',
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab栏
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(children: [_buildTab('订单列表', 0), _buildTab('项目集列表', 1)]),
          ),
          // 搜索+筛选栏（仅订单列表tab显示）
          if (_currentTabIndex == 0) _buildSearchAndFilterBar(),
          // 内容区域
          Expanded(
            child: _currentTabIndex == 0
                ? (_orders.isEmpty && !_isLoading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '暂无订单数据',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadOrders,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _orders.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _orders.length) {
                                return Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return _buildOrderItem(index);
                            },
                          ),
                        ))
                : _buildProjectGroupTabBody(),
          ),
          // 底部按钮
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      minimumSize: Size(0, 44),
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canConfirm ? _onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0073FF),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      minimumSize: Size(0, 44),
                    ),
                    child: Text(
                      _confirmText,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTabIndex = index;
            if (index == 0) {
              _isInStepTwo = false;
              _selectedGroupIndex = null;
              _selectedItemIndex = null;
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Color(0xFF0073FF) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: isActive ? Color(0xFF0073FF) : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
