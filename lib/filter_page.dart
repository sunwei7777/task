import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/form_widgets.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  // 筛选类别列表
  final List<String> filterCategories = [
    '任务类型',
    '工序类型',
    '交期',
    '任务周期',
    '汇报类型',
    '任务情况',
    '客户名称',
  ];

  // 当前选中的类别索引
  int _selectedCategoryIndex = 0;

  // 右侧内容滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 每个类别的滚动位置
  final List<double> _categoryOffsets = [];

  // 筛选选项的选中状态
  Map<String, bool> _selectedFilters = {};

  // 日期选择状态
  DateTime? _deliveryStartDate;
  DateTime? _deliveryEndDate;
  DateTime? _cycleStartDate;
  DateTime? _cycleEndDate;

  // 初始化筛选选项的选中状态
  void _initSelectedFilters() {
    // 初始选中的选项
    _selectedFilters['订单'] = true;
    _selectedFilters['裁剪'] = true;
  }

  // 计算每个类别的滚动位置
  void _calculateOffsets() {
    _categoryOffsets.clear();
    double offset = 0;
    _categoryOffsets.add(offset);

    // 每个类别大约占用的高度（标题+内容+间距）
    final double categoryHeight = 100; // 估算值，可根据实际调整

    for (int i = 1; i < filterCategories.length; i++) {
      offset += categoryHeight;
      _categoryOffsets.add(offset);
    }
  }

  @override
  void initState() {
    super.initState();
    // 初始化筛选选项的选中状态
    _initSelectedFilters();
    // 初始化时计算滚动位置
    _calculateOffsets();

    // 添加滚动监听器
    _scrollController.addListener(() {
      _updateSelectedCategory();
    });
  }

  // 切换筛选选项的选中状态
  void _toggleFilter(String label) {
    setState(() {
      _selectedFilters[label] = !(_selectedFilters[label] ?? false);
    });
  }

  // 根据滚动位置更新选中的类别
  void _updateSelectedCategory() {
    double currentOffset = _scrollController.offset;

    // 找到当前滚动位置对应的类别
    for (int i = _categoryOffsets.length - 1; i >= 0; i--) {
      if (currentOffset >= _categoryOffsets[i]) {
        if (_selectedCategoryIndex != i) {
          setState(() {
            _selectedCategoryIndex = i;
          });
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          icon: Icon(
            Icons.close, // 图标类型
            size: 20, // 图标大小
          ),
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
          SizedBox(
            width: 90,
            child: ListView.builder(
              itemCount: filterCategories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                    // 点击左侧类别后，右侧内容滚动到对应位置
                    if (_categoryOffsets.length > index) {
                      _scrollController.jumpTo(_categoryOffsets[index]);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _selectedCategoryIndex == index
                          ? Colors.white
                          : Color(0xFFF6F7FA),
                      border: Border(
                        left: _selectedCategoryIndex == index
                            ? BorderSide(color: Color(0xFF0073FF), width: 3)
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      filterCategories[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedCategoryIndex == index
                            ? Color(0xFF0073FF)
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 右侧筛选选项
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
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
                  // 清空全部逻辑
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  minimumSize: Size(0, 38),
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
                  // 确定逻辑
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0073FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  minimumSize: Size(0, 38),
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
        Text(
          '任务类型',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 8, children: [_buildFilterChip('订单')]),
        SizedBox(height: 24),

        // 工序类型
        Text(
          '工序类型',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildFilterChip('裁剪'),
            _buildFilterChip('缝制'),
            _buildFilterChip('后道'),
          ],
        ),
        SizedBox(height: 24),

        // 交期
        Text('交期', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    _deliveryStartDate != null
                        ? _deliveryStartDate!.toString()
                        : '开始时间',
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text('—'),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    _deliveryEndDate != null
                        ? _deliveryEndDate!.toString()
                        : '结束时间',
                  ),
                ),
              ),
            ),
            // Icon(Icons.calendar_today, color: Colors.grey[500]),
          ],
        ),
        SizedBox(height: 24),

        // 任务周期
        Text(
          '任务周期',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => {},
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      _cycleStartDate != null
                          ? _cycleStartDate!.toString()
                          : '开始时间',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text('—'),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    _cycleEndDate != null ? _cycleEndDate!.toString() : '结束时间',
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),

        // 汇报类型
        Text(
          '汇报类型',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildFilterChip('整体汇报'),
            _buildFilterChip('SKU汇报'),
            _buildFilterChip('自定义汇报'),
          ],
        ),
        SizedBox(height: 24),

        // 任务情况
        Text(
          '任务情况',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildFilterChip('可开始'),
            _buildFilterChip('有阻碍'),
            _buildFilterChip('我阻碍'),
          ],
        ),
        SizedBox(height: 24),

        // 客户名称
        Text(
          '客户名称',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildFilterChip('四川xxxx纺织机1四川xxxx纺织机1四川xxxx纺织机1'),
            _buildFilterChip('四川xxxx纺织机2'),
            _buildFilterChip('四川xxxx纺织机3'),
            GestureDetector(
              onTap: () {
                // 查看全部逻辑
              },
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
        ),
        SizedBox(height: 24),
      ],
    );
  }

  // 构建筛选芯片
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
}
