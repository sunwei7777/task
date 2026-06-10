import 'package:flutter/material.dart';

class ReportHistory extends StatelessWidget {
  const ReportHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          // 日期时间
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  color: Color(0xFF0073FF),
                  margin: EdgeInsets.only(right: 8),
                ),
                Text(
                  '2024/11/07 12:30:00',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          // 汇报内容卡片
          Container(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 提交人及进度
                Text(
                  '张三 - 提交进度10%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),

                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      // 供应商信息
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '供应商',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '供应商XXX',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 0.5,
                        width: double.infinity,
                        color: Colors.grey[300]!,
                      ),
                      SizedBox(height: 8),
                      // 图片上传
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '图片上传',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                margin: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(child: Text('图')),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                margin: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(child: Text('图')),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 0.5,
                        width: double.infinity,
                        color: Colors.grey[300]!,
                      ),
                      SizedBox(height: 8),

                      // 文件上传
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '文件上传',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '--',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 0.5,
                        width: double.infinity,
                        color: Colors.grey[300]!,
                      ),
                      SizedBox(height: 8),

                      // 备注
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              '备注',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '内容内容内容，我说我说我说这个',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      // 语音消息样式
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 120,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFF9F9F9), Color(0xFFBCBCBC)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '18\'',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Transform.rotate(
                                  angle: -90 * 3.1415926535 / 180, // 向左旋转90度
                                  child: Icon(
                                    Icons.wifi,
                                    size: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
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

          // 表格
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                // 表格标题
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF6F6F6),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          '颜色',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          '尺码',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          '订单数量',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          '汇报数',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          '备注',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                // 表格行
                buildTableRow('红色', 'S', '2000/1088', '600', '件', '户'),
                buildTableRow('黑色', 'M', '2000/1600', '600', '件', '-'),
                buildTableRow('蓝色', 'L', '2000/1400', '700', '件', ''),
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
    String note,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              color,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              size,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              orderQty,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Text(
                  reportQty,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              note,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
