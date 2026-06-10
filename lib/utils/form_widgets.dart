import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 表单工具类，提供通用的表单组件构建方法
class FormWidgets {
  // 选择状态
  static DateTime? selectedDateTime;

  /// 构建只读项
  ///
  /// [label] 标签文本
  /// [required] 是否必填
  /// [value] 显示值
  /// [icon] 图标
  /// [onTap] 点击回调
  static Widget buildReadOnlyItem(
    String label,
    bool required,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF010101)),
                  children: [
                    TextSpan(text: label),
                    if (required)
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Colors.red),
                      ),
                    if (label == '汇报进度')
                      TextSpan(
                        text: '  整体',
                        style: TextStyle(
                          color: Color(0xFF1BA17D),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            label == '关联项目/订单'
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 12.0,
                    ),
                    color: Color(0xFFF1F6FF),
                    child: Text(
                      value.isNotEmpty ? value : '请选择',
                      style: TextStyle(
                        color: value.isNotEmpty
                            ? Colors.black87
                            : Colors.black38,
                        fontSize: 13,
                      ),
                    ),
                  )
                : Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
            if (label != '单据编号' && label != '申请类型' && label != '汇报人')
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  /// 构建输入项
  ///
  /// [label] 标签文本
  /// [required] 是否必填
  /// [controller] 文本控制器
  /// [icon] 图标
  /// [keyboardType] 键盘类型
  /// [obscureText] 是否隐藏文本
  static Widget buildInputItem(
    String label,
    bool required,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF010101)),
                    children: [
                      TextSpan(text: label),
                      if (required)
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 14, // 字体大小
              ),
              keyboardType: keyboardType,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: '请输入$label',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                contentPadding: EdgeInsets.only(left: 24, bottom: 12),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //选择日期范围
  static Widget showDateTime(
    BuildContext context,
    String label,
    DateTime? value, {
    required VoidCallback? Function(DateTime selectedDateTime) onPressed,
  }) {
    return GestureDetector(
      onTap: () => _showCupertinoDateTimePicker(
        context,
        value,
        isStartDate: label == '开始时间',
        onPressed: (selectedDateTime) {
          onPressed(selectedDateTime);
          return null;
        },
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(value != null ? _formatChineseDateTime(value) : label),
        ),
      ),
    );
  }

  // 日期选择项构建
  static Widget buildDateItem(
    BuildContext context,
    String label,
    bool required,
    DateTime? value,
    IconData icon, {
    bool timeOnly = false,
    required VoidCallback? Function(DateTime selectedDateTime) onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF010101)),
                children: [
                  TextSpan(text: label),
                  if (required)
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _showCupertinoDateTimePicker(
                      context,
                      value,
                      isStartDate: label == '计划开始时间',
                      timeOnly: timeOnly,
                      onPressed: (selectedDateTime) {
                        onPressed(selectedDateTime);
                        return null;
                      },
                    );
                  },
                  child: Text(
                    value != null
                        ? (timeOnly
                              ? _formatTimeOnly(value)
                              : _formatChineseDateTime(value))
                        : '请设置',
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.date_range, color: Colors.grey, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showCupertinoDateTimePicker(
    BuildContext context,
    DateTime? value, {
    bool isStartDate = true,
    bool timeOnly = false,
    required VoidCallback? Function(DateTime selectedDateTime) onPressed,
  }) async {
    DateTime now = DateTime.now();
    selectedDateTime = value ?? now;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 标题栏
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        '取消',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      isStartDate
                          ? (timeOnly ? '选择开始时间' : '选择开始时间')
                          : (timeOnly ? '选择结束时间' : '选择结束时间'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => onPressed(selectedDateTime!),
                      child: Text(
                        '确定',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              // 日期时间选择器
              Expanded(
                child: _buildChineseDateTimePicker(
                  selectedDateTime!,
                  isStartDate: isStartDate,
                  timeOnly: timeOnly,
                ),
              ),
              // 中文格式显示当前选择
              // Container(
              //   padding: EdgeInsets.all(16),
              //   child: Text(
              //     _formatChineseDateTime(selectedDateTime),
              //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  // 中文格式化日期时间
  static String _formatChineseDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (selectedDate.isAtSameMomentAs(today)) {
      dateStr = '今天';
    } else {
      final tomorrow = today.add(Duration(days: 1));
      if (selectedDate.isAtSameMomentAs(tomorrow)) {
        dateStr = '明天';
      } else {
        final yesterday = today.subtract(Duration(days: 1));
        if (selectedDate.isAtSameMomentAs(yesterday)) {
          dateStr = '昨天';
        } else {
          // 使用中文格式：2024年2月27日 星期二
          // final weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
          dateStr = '${dateTime.year}-${dateTime.month}-${dateTime.day}';
        }
      }
    }

    // 时间格式：下午3:30
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    // String period = '';
    int displayHour = hour;

    // if (hour < 6) {
    //   period = '凌晨';
    //   displayHour = hour;
    // } else if (hour < 12) {
    //   period = '上午';
    //   displayHour = hour;
    // } else if (hour == 12) {
    //   period = '中午';
    //   displayHour = hour;
    // } else if (hour < 18) {
    //   period = '下午';
    //   displayHour = hour - 12;
    // } else {
    //   period = '晚上';
    //   displayHour = hour - 12;
    // }

    return '$dateStr $displayHour:${minute.toString().padLeft(2, '0')}'; //:${dateTime.second.toString().padLeft(2, '0')}
  }

  // 仅时间格式化
  static String _formatTimeOnly(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  // 自定义中文日期时间选择器
  static Widget _buildChineseDateTimePicker(
    DateTime initialDateTime, {
    bool isStartDate = true,
    bool timeOnly = false,
  }) {
    DateTime tempDateTime = initialDateTime;

    if (timeOnly) {
      return Row(
        children: [
          // 小时选择器
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: tempDateTime.hour,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                tempDateTime = DateTime(
                  tempDateTime.year,
                  tempDateTime.month,
                  tempDateTime.day,
                  index,
                  tempDateTime.minute,
                  tempDateTime.second,
                );
                selectedDateTime = tempDateTime;
              },
              children: List.generate(24, (index) {
                return Center(
                  child: Text('$index时', style: TextStyle(fontSize: 20)),
                );
              }),
            ),
          ),
          // 分钟选择器
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: tempDateTime.minute,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                tempDateTime = DateTime(
                  tempDateTime.year,
                  tempDateTime.month,
                  tempDateTime.day,
                  tempDateTime.hour,
                  index,
                  tempDateTime.second,
                );
                selectedDateTime = tempDateTime;
              },
              children: List.generate(60, (index) {
                return Center(
                  child: Text(
                    '${index.toString().padLeft(2, '0')}分',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }),
            ),
          ),
          // 秒选择器
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: tempDateTime.second,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                tempDateTime = DateTime(
                  tempDateTime.year,
                  tempDateTime.month,
                  tempDateTime.day,
                  tempDateTime.hour,
                  tempDateTime.minute,
                  index,
                );
                selectedDateTime = tempDateTime;
              },
              children: List.generate(60, (index) {
                return Center(
                  child: Text(
                    '${index.toString().padLeft(2, '0')}秒',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 年份选择器
          Expanded(
            flex: 1,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: tempDateTime.year - 2020,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                tempDateTime = DateTime(
                  2020 + index,
                  tempDateTime.month,
                  tempDateTime.day,
                  tempDateTime.hour,
                  tempDateTime.minute,
                  tempDateTime.second,
                );
                selectedDateTime = tempDateTime;
              },
              children: List.generate(30, (index) {
                return Center(
                  child: Text(
                    '${2020 + index}年',
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }),
            ),
          ),

          // 月份选择器
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: tempDateTime.month - 1,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                tempDateTime = DateTime(
                  tempDateTime.year,
                  index + 1,
                  tempDateTime.day,
                  tempDateTime.hour,
                  tempDateTime.minute,
                  tempDateTime.second,
                );
                selectedDateTime = tempDateTime;
              },
              children: List.generate(12, (index) {
                return Center(
                  child: Text('${index + 1}月', style: TextStyle(fontSize: 14)),
                );
              }),
            ),
          ),

          // 日期选择器
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: tempDateTime.day - 1,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                tempDateTime = DateTime(
                  tempDateTime.year,
                  tempDateTime.month,
                  index + 1,
                  tempDateTime.hour,
                  tempDateTime.minute,
                  tempDateTime.second,
                );
                selectedDateTime = tempDateTime;
              },
              children: List.generate(
                _getDaysInMonth(tempDateTime.year, tempDateTime.month),
                (index) {
                  return Center(
                    child: Text(
                      '${index + 1}日',
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ),

          // 小时选择器
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: tempDateTime.hour,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                tempDateTime = DateTime(
                  tempDateTime.year,
                  tempDateTime.month,
                  tempDateTime.day,
                  index,
                  tempDateTime.minute,
                  tempDateTime.second,
                );
                selectedDateTime = tempDateTime;
              },
              children: List.generate(24, (index) {
                return Center(
                  child: Text('$index时', style: TextStyle(fontSize: 14)),
                );
              }),
            ),
          ),

          // 分钟选择器
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: tempDateTime.minute,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                tempDateTime = DateTime(
                  tempDateTime.year,
                  tempDateTime.month,
                  tempDateTime.day,
                  tempDateTime.hour,
                  index,
                  tempDateTime.second,
                );
                selectedDateTime = tempDateTime;
              },
              children: List.generate(60, (index) {
                return Center(
                  child: Text(
                    '${index.toString().padLeft(2, '0')}分',
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }),
            ),
          ),

          // 秒选择器
          // Expanded(
          //   child: CupertinoPicker(
          //     scrollController: FixedExtentScrollController(
          //       initialItem: tempDateTime.second,
          //     ),
          //     itemExtent: 40,
          //     onSelectedItemChanged: (int index) {
          //       tempDateTime = DateTime(
          //         tempDateTime.year,
          //         tempDateTime.month,
          //         tempDateTime.day,
          //         tempDateTime.hour,
          //         tempDateTime.minute,
          //         index,
          //       );
          //       selectedDateTime = tempDateTime;
          //     },
          //     children: List.generate(60, (index) {
          //       return Center(
          //         child: Text(
          //           '${index.toString().padLeft(2, '0')}秒',
          //           style: TextStyle(fontSize: 14),
          //         ),
          //       );
          //     }),
          //   ),
          // ),
        ],
      ),
    );
  }

  // 获取某个月的天数
  static int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      return ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0))
          ? 29
          : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }

  /// 构建选择项
  ///
  /// [label] 标签文本
  /// [required] 是否必填
  /// [value] 当前值
  /// [icon] 图标
  /// [items] 选项列表
  /// [onChanged] 选择变化回调
  static Widget buildSelectItem(
    String label,
    bool required,
    String value,
    IconData icon,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value.isNotEmpty ? value : null,
            decoration: InputDecoration(
              label: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(text: label),
                    if (required)
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 0.5),
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  /// 构建图片上传项
  ///
  /// [label] 标签文本
  static Widget buildImageUploadItem(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Color(0xFF010101))),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // 这里可以实现图片选择逻辑
              print('选择图片');
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.grey, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建附件上传项
  ///
  /// [label] 标签文本
  static Widget buildFileUploadItem(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Color(0xFF010101))),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // 这里可以实现文件选择逻辑
              print('选择文件');
            },
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.grey, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '选择文件',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
