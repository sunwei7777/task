import 'package:flutter/material.dart';
import 'package:flutter_application_1/filter_page.dart';
import 'package:flutter_application_1/search_page.dart';
import 'package:flutter_application_1/task_look.dart';

class TaskList extends StatefulWidget {
  final String title;
  const TaskList({Key? key, required this.title}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  int? _curIndex;
  int _currentTab = 0;
  String? _selectedSubType = '周期';
  String? _selectedStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.title == '订单任务') {
      _currentTab = 0;
    } else if (widget.title == '项目任务') {
      _currentTab = 1;
    } else if (widget.title == '其他任务') {
      _currentTab = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索栏
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          ),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 20, color: Colors.grey[400]),
                        SizedBox(width: 8),
                        Text(
                          '款号、订单编号、客户名称',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // SizedBox(width: 12),
                // Row(
                //   children: [
                //     Icon(
                //       Icons.filter_alt_outlined,
                //       size: 16,
                //       color: Colors.grey[600],
                //     ),
                //     SizedBox(width: 4),
                //     Text(
                //       '筛选',
                //       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),

        // 任务类型标签
        widget.title == '全部任务'
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
                    _buildTab('订单任务', 0),
                    SizedBox(width: 12),
                    _buildTab('项目任务', 1),
                    SizedBox(width: 12),
                    _buildTab('其他任务', 2),
                  ],
                ),
              )
            : Container(height: 8, color: Colors.white),

        // 子类型标签
        if (_currentTab == 2)
          Container(
            height: 38,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
              ),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSubTypeTag('周期', 2),
                SizedBox(width: 12),
                _buildSubTypeTag('日常', 1),
                SizedBox(width: 12),
                _buildSubTypeTag('临时', 3),
                SizedBox(width: 12),
                _buildSubTypeTag('外派', 0),
                SizedBox(width: 12),
                _buildSubTypeTag('其他', 5),
                SizedBox(width: 12),
                _buildSubTypeTag('测试', 1),
              ],
            ),
          ),

        SizedBox(height: 12),

        // 状态标签
        Container(
          height: 32,
          padding: EdgeInsets.only(left: 12),
          child: Stack(
            children: [
              ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStatusTag('待处理', 2),
                  SizedBox(width: 12),
                  _buildStatusTag('今日可开始', 1),
                  SizedBox(width: 12),
                  _buildStatusTag('已延期', 0),
                  SizedBox(width: 12),
                  _buildStatusTag('即将延期', 0),
                  SizedBox(width: 12),
                  _buildStatusTag('进行中', 3),
                  SizedBox(width: 12),
                  _buildStatusTag('已完成', 5),
                  SizedBox(width: 60), // 为悬浮按钮留出空间
                ],
              ),
              // 悬浮筛查按钮
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
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
                          child: FilterPage(),
                        );
                      },
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 32,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                        child: Row(
                          children: [
                            Icon(Icons.filter_alt_outlined, size: 14),
                            SizedBox(width: 4),
                            Text('筛选', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      // 红色个数角标
                      // Positioned(
                      //   top: 2,
                      //   right: 3,
                      //   child: Container(
                      //     width: 14,
                      //     height: 14,
                      //     // padding: EdgeInsets.symmetric(
                      //     //   horizontal: 6,
                      //     //   vertical: 2,
                      //     // ),
                      //     decoration: BoxDecoration(
                      //       color: Colors.red,
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: Center(
                      //       child: Text(
                      //         '3',
                      //         style: TextStyle(
                      //           fontSize: 10,
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12),

        // 任务列表
        _currentTab == 2 ? _buildOtherTabView() : _buildTabView(),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: _currentTab == index
                ? Border(bottom: BorderSide(color: Color(0xFF0073FF), width: 2))
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: _currentTab == index ? Color(0xFF0073FF) : Colors.black,
              fontWeight: _currentTab == index
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
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Text(
              '$title ($count)',
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

  Widget _buildStatusTag(String title, int count) {
    bool isSelected = _selectedStatus == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = title;
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

  Widget _buildTabView() {
    return Expanded(
      child: Container(
        color: Color(0xFFF9F9F9),
        child: ListView.builder(
          padding: EdgeInsets.only(left: 12, right: 12),
          itemCount: 8,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskLook()),
                );
              },
              child: Card(
                margin: EdgeInsets.only(bottom: 12),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // 圆角
                ),
                // ignore: deprecated_member_use
                shadowColor: Colors.grey.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 6),
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
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _curIndex = index;
                                    });
                                  },
                                  child: Container(
                                    width: 18,
                                    height: 18,
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
                                            size: 12,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  color: Color(0xFFEEF3FB),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      _currentTab == 0 ? '订单' : '项目',
                                      style: TextStyle(
                                        color: Color(0xFF223A6D),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'XSDD077628898211',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  color: Color(0xFFFEE9E9),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      '预计延误',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Container(
                                  color: Color(0xFFDDF6F8),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      '待开始',
                                      style: TextStyle(
                                        color: Color(0xFF1BA17D),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                                  '采购-面料染色',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '0%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1BA17D),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  color: Color(0xFFFEE9E9),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.remove_circle_outline,
                                          color: Color(0xFFE46723),
                                          size: 12,
                                        ),
                                        Text(
                                          '3',
                                          style: TextStyle(
                                            color: Color(0xFFE35100),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  color: Color(0xFFFEE9E9),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.not_interested,
                                          color: Colors.red,
                                          size: 12,
                                        ),
                                        Text(
                                          '3',
                                          style: TextStyle(
                                            color: Color(0xFFE35100),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                                  // 客户与时间信息
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          _currentTab == 0
                                              ? '款号: TOP-104'
                                              : '内容：第5届进口博览会',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis, // 超出显示省略号
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          _currentTab == 0
                                              ? '客户: 四川xx纺织机械有四川xx纺织机械有'
                                              : '来源：展会项目集',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis, // 超出显示省略号
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '交货倒计时: 23天',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis, // 超出显示省略号
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '计划区间: 4/01至4/06',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis, // 超出显示省略号
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '剩余缓冲：23天',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis, // 超出显示省略号
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        flex: 1,
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '任务时间：',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '0天',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '/8天',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                                        '我',
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
                                          color: Color(0xFFE46723),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '消耗缓冲 5 天',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFE46723),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Positioned(
                                  right: -14,
                                  bottom: -6,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF208BDE),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '5天',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
      ),
    );
  }

  Widget _buildOtherTabView() {
    return Expanded(
      child: Container(
        color: Color(0xFFF9F9F9),
        child: ListView.builder(
          padding: EdgeInsets.only(left: 12, right: 12),
          itemCount: 8,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskLook(isHasDetail: true),
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
                shadowColor: Colors.grey.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 6),
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
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _curIndex = index;
                                    });
                                  },
                                  child: Container(
                                    width: 18,
                                    height: 18,
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
                                            size: 12,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  color: Color(0xFFEEF3FB),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      '周期',
                                      style: TextStyle(
                                        color: Color(0xFF223A6D),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'XSDD077628898211',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  color: Color(0xFFFEE9E9),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      '预计延误',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Container(
                                  color: Color(0xFFDDF6F8),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      '待开始',
                                      style: TextStyle(
                                        color: Color(0xFF1BA17D),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                                  '采购-面料染色',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '0%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1BA17D),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  color: Color(0xFFFEE9E9),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.remove_circle_outline,
                                          color: Color(0xFFE46723),
                                          size: 12,
                                        ),
                                        Text(
                                          '3',
                                          style: TextStyle(
                                            color: Color(0xFFE35100),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  color: Color(0xFFFEE9E9),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.not_interested,
                                          color: Colors.red,
                                          size: 12,
                                        ),
                                        Text(
                                          '3',
                                          style: TextStyle(
                                            color: Color(0xFFE35100),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                                  // 客户与时间信息
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '负责人：张三、李四',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis, // 超出显示省略号
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '计划开始时间： 11-19 09：00',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis, // 超出显示省略号
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '计划结束时间： 11-19 09：00',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis, // 超出显示省略号
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '任务内容： 每日8点半前完成巡视缝制每日8点半前完成巡视缝制车间1号产线，确…',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis, // 超出显示省略号
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}
