import 'package:flutter/material.dart';
import 'package:flutter_application_1/filter_page.dart';
import 'package:flutter_application_1/report/report_form.dart';
import 'package:flutter_application_1/task/task_look.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // 搜索控制器
  final TextEditingController _searchController = TextEditingController(
    text: '',
  );

  int? _curIndex;
  // 模拟搜索结果数据
  int _resultCount = 8;
  int listNum = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          '搜索',
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 搜索输入框
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '款号、订单编号、客户名称',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  // if (_searchController.text.isNotEmpty)
                  //   IconButton(
                  //     onPressed: () {
                  //       setState(() {
                  //         _searchController.clear();
                  //       });
                  //     },
                  //     icon: Icon(Icons.clear, color: Colors.grey),
                  //   ),
                  ElevatedButton(
                    onPressed: () {
                      // 搜索逻辑
                      print('搜索: ${_searchController.text}');
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Color(0xFF0073FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '搜索',
                      style: TextStyle(color: Color(0xFF0073FF)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 搜索结果信息和操作按钮
          if (listNum > 0)
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '已显示全部 $_resultCount 个对象',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // 筛选逻辑
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.9,
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
                        icon: Icon(
                          Icons.filter_alt_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        label: Text(
                          '筛选',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () {
                          // 排序逻辑
                          print('排序');
                        },
                        icon: Icon(
                          Icons.sort,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        label: Text(
                          '排序',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          SizedBox(height: 12),
          // 搜索结果列表
          listNum == 0
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _resultCount,
                    itemBuilder: (context, index) {
                      // 在搜索结果0前面添加小标题
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                '小标题1',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text('搜索结果 $index'),
                              subtitle: Text('发布时间：2025/11/02'),
                              trailing: Text('3任务'),
                              onTap: () {
                                // 点击搜索结果
                                print('点击搜索结果 $index');
                              },
                            ),
                          ],
                        );
                      }
                      // 在搜索结果3前面添加小标题
                      else if (index == 3) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                '小标题2',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text('搜索结果 $index'),
                              subtitle: Text('发布时间：2025/11/02'),
                              trailing: Text('3任务'),
                              onTap: () {
                                // 点击搜索结果
                                print('点击搜索结果 $index');
                              },
                            ),
                          ],
                        );
                      }
                      // 其他搜索结果
                      else {
                        return ListTile(
                          title: Text('搜索结果 $index'),
                          subtitle: Text('发布时间：2025/11/02'),
                          trailing: Text('3任务'),
                          onTap: () {
                            // 点击搜索结果
                            listNum = 8;
                            setState(() {});
                          },
                        );
                      }
                    },
                  ),
                )
              : _buildTabView(),
        ],
      ),
      bottomNavigationBar: listNum > 0
          ? Container(
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
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (cotext) {
                          return ReportForm();
                        },
                      );
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
                  SizedBox(width: 12),
                ],
              ),
            )
          : null,
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
                  MaterialPageRoute(builder: (context) => TaskLook(taskId: 0)),
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
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _curIndex = index;
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
                                        '订单',
                                        style: TextStyle(
                                          color: Color(0xFF223A6D),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'XSDD077628898211',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
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
                                          fontSize: 12,
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
                                            fontSize: 12,
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
                                            fontSize: 12,
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
                                          '款号: TOP-104',
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
                                          '客户: 四川xx纺织机械有四川xx纺织机械有',
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
}
