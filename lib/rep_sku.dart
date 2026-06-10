import 'package:flutter/material.dart';
import 'package:flutter_application_1/input_num.dart';
import 'package:flutter_application_1/task_look_bottom.dart';
import 'package:flutter_application_1/toast_custom.dart';

class RepSku extends StatefulWidget {
  const RepSku({Key? key}) : super(key: key);

  @override
  _RepSkuState createState() => _RepSkuState();
}

class _RepSkuState extends State<RepSku> {
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
                  SizedBox(height: 12),
                  // 表格
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        // 表格标题
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
                              SizedBox(
                                width: 70,
                                child: Text(
                                  '颜色',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  '尺码',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  '订单数量',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  '汇报数量',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 表格行
                        buildTableRow('红色', 'S', '2000/1088', '123', '件'),
                        buildTableRow('黑色', 'M', '2000/1600', '', '件'),
                        buildTableRow('蓝色', 'L', '2000/1400', '', '件'),
                      ],
                    ),
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

  // 构建表格行
  Widget buildTableRow(
    String color,
    String size,
    String orderQty,
    String reportQty,
    String unit,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              color,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              size,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Text(
                  '${orderQty.split('/')[0]}/',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  orderQty.split('/')[1],
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
                  onTap: () {
                    // 点击事件处理
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (cotext) {
                        return InputNum();
                      },
                    );
                  },
                  child: Text(
                    reportQty.isNotEmpty ? reportQty : '请输入',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ),

                // SizedBox(
                //   width: 80,
                //   child: TextField(
                //     controller: TextEditingController(text: reportQty),
                //     style: TextStyle(fontSize: 14, color: Colors.black),
                //     decoration: InputDecoration(
                //       border: InputBorder.none,
                //       contentPadding: EdgeInsets.symmetric(
                //         horizontal: 8,
                //         vertical: 4,
                //       ),
                //       isDense: true,
                //       hintText: '请输入',
                //       hintStyle: TextStyle(
                //         fontSize: 14,
                //         color: Colors.grey[400],
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(width: 4),
                Text(
                  unit,
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
