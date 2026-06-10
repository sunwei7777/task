import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/common.dart';
import 'package:flutter_application_1/home/toast_custom.dart';

class SetCycle extends StatefulWidget {
  final String? initialValue;
  final Function(String)? onConfirm;
  const SetCycle({super.key, this.initialValue, this.onConfirm});

  @override
  State<SetCycle> createState() => _SetCycleState();
}

class _SetCycleState extends State<SetCycle> {
  static const List<String> _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  String selectedInterval = '每日';
  List<bool> weekSelection = List.filled(7, false);
  List<bool> monthSelection = List.filled(31, false);

  @override
  void initState() {
    super.initState();
    _parseInitialValue();
  }

  void _parseInitialValue() {
    final value = widget.initialValue;
    if (value == null || value.isEmpty) return;

    if (value == '每天') {
      selectedInterval = '每日';
    } else if (value.startsWith('每周')) {
      selectedInterval = '每周';
      final dayStr = value.replaceAll('每周', '');
      for (int i = 0; i < _weekdays.length; i++) {
        weekSelection[i] = dayStr.contains(_weekdays[i]);
      }
    } else if (value.startsWith('每月')) {
      selectedInterval = '每月';
      final dayStr = value.replaceAll('每月', '').replaceAll('号', '');
      final parts = dayStr.split('、');
      for (var part in parts) {
        final day = int.tryParse(part);
        if (day != null && day >= 1 && day <= 31) {
          monthSelection[day - 1] = true;
        }
      }
    }
  }

  String? _validate() {
    if (selectedInterval == '每周' && !weekSelection.contains(true)) {
      return '请至少选择一个工作日';
    }
    if (selectedInterval == '每月' && !monthSelection.contains(true)) {
      return '请至少选择一个日期';
    }
    return null;
  }

  String _buildResult() {
    if (selectedInterval == '每日') {
      return '每天';
    } else if (selectedInterval == '每周') {
      final days = <String>[];
      for (int i = 0; i < _weekdays.length; i++) {
        if (weekSelection[i]) days.add(_weekdays[i]);
      }
      return '每周${days.join('、')}';
    } else {
      final days = <String>[];
      for (int i = 0; i < 31; i++) {
        if (monthSelection[i]) days.add('${i + 1}号');
      }
      return '每月${days.join('、')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
          Common.topBar(context, '选择任务周期', showCloseButton: true),
          Container(height: 0.5, color: Colors.grey[300]!),

          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 16.0),
                    SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        '设定后系统会自动发布新任务（若时间重叠只发布一次）',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIntervalTab('每日'),
                  _buildIntervalTab('每周'),
                  _buildIntervalTab('每月'),
                ],
              ),
              SizedBox(height: 4.0),
            ],
          ),
          Expanded(
            child: selectedInterval == '每日'
                ? everyDay()
                : selectedInterval == '每周'
                ? everyWeek()
                : everyMonth(),
          ),
          Container(
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
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final error = _validate();
                    if (error != null) {
                      ToastCustom.showToast(context, '提示', error);
                      return;
                    }
                    final result = _buildResult();
                    widget.onConfirm?.call(result);
                    Navigator.pop(context);
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
                SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalTab(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedInterval = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedInterval == label ? Color(0XFF0A68DA) : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4.0),
          color: selectedInterval == label
              ? Color(0XFF0A68DA).withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selectedInterval == label ? Color(0XFF0A68DA) : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget everyDay() {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'lib/assets/bell.png',
            width: 128.0,
            height: 128.0,
          ),
        ),
        SizedBox(height: 16.0),
        Text(
          '"每日"默认为「每天」汇报一次',
          style: TextStyle(color: Colors.grey, fontSize: 14.0),
        ),
      ],
    );
  }

  Widget everyWeek() {
    return Container(
      padding: EdgeInsets.only(left: 16.0),
      child: ListView.builder(
        itemCount: _weekdays.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(_weekdays[index]),
            value: weekSelection[index],
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  weekSelection[index] = value;
                });
              }
            },
            activeColor: Color(0XFF0A68DA),
          );
        },
      ),
    );
  }

  Widget everyMonth() {
    return Container(
      padding: EdgeInsets.only(left: 16.0),
      child: ListView.builder(
        itemCount: 31,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text('${index + 1}号'),
            value: monthSelection[index],
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  monthSelection[index] = value;
                });
              }
            },
            activeColor: Color(0XFF0A68DA),
          );
        },
      ),
    );
  }
}
