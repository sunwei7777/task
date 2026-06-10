import 'package:flutter/material.dart';
import 'package:flutter_application_1/input_num.dart';
import 'package:flutter_application_1/rep_custom_add.dart';
import 'package:flutter_application_1/task_look_bottom.dart';
import 'package:flutter_application_1/toast_custom.dart';

class RepCustom extends StatefulWidget {
  const RepCustom({Key? key}) : super(key: key);

  @override
  _RepCustomState createState() => _RepCustomState();
}

class _RepCustomState extends State<RepCustom> {
  List<String> items = ['11', '22', '33'];
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
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('选择汇报进度')],
            ),
          ),
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
                              fontSize: 12,
                              color: Color(0xFF001111),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (cotext) {
                                return TaskLookBottom();
                              },
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              minimumSize: Size(0, 28),
                            ),
                            child: Text(
                              '任务详情',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF080808),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.0),
                      Container(
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFAFAFA),
                          border: Border.all(
                            color: Color(0xFFD4D4D4),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.work, color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(text: '清理半成品仓库'),
                                      TextSpan(
                                        text: ' 80%',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '关联订单/款号：TOP-104',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '要求完成时间：11-09 18:00前',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(color: Colors.transparent),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFE0F2F1), // 浅绿色背景色，可根据实际需求调整
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                '待开始',
                                style: TextStyle(
                                  color: Color(0xFF1BA17D),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  //添加目标
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // 添加目标功能
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (cotext) {
                              return RepCustomAdd();
                            },
                          );
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
                      // TextButton.icon(
                      //   onPressed: () {},
                      //   icon: Icon(
                      //     Icons.edit,
                      //     size: 16,
                      //     color: Color(0xFF0073FF),
                      //   ),
                      //   label: Text(
                      //     '全部填入',
                      //     style: TextStyle(
                      //       fontSize: 14,
                      //       color: Color(0xFF0073FF),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  Container(height: 0.5, color: Colors.grey[300]!),
                  Row(
                    children: [
                      // 左侧导航栏
                      Container(
                        width: 70,
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
                            _buildNavItem('图片'),
                            _buildNavItem('订单\n数量'),
                            _buildNavItem('汇报\n数量', isActive: true),
                          ],
                        ),
                      ),

                      // 右侧内容区域
                      items.isEmpty
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
                                height: 480,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    String item = items[index];
                                    return SizedBox(
                                      width: 150,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildContentItem(
                                            item,
                                            isActive: true,
                                          ),
                                          _buildContentItem(item),
                                          _buildContentItem(item),
                                          _buildContentItem(item),
                                          _buildContentItem(item),
                                          _buildContentItem(item),
                                          _buildContentItem(item),
                                          _buildContentItem(
                                            item,
                                            isinput: true,
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
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 48,
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
                          // 全部填入功能实现
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
                    minimumSize: Size(0, 32),
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    //提交成功toast提示
                    Navigator.pop(context);
                    ToastCustom.showToast(context, '提交成功');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0073FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    minimumSize: Size(0, 32),
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

  Widget _buildContentItem(
    String title, {
    bool isActive = false,
    bool isinput = false,
  }) {
    return Stack(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: .5),
              right: BorderSide(color: Colors.grey[300]!, width: .5),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              if (isinput) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (cotext) {
                    return InputNum();
                  },
                );
              }
            },
            child: Center(
              child: Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        isActive
            ? Positioned(
                top: -8,
                right: -5,
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (cotext) {
                        return RepCustomAdd();
                      },
                    );
                  },
                  icon: Icon(Icons.border_color, size: 14, color: Colors.black),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
