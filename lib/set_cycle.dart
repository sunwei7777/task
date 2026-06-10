import 'package:flutter/material.dart';

class SetCycle extends StatefulWidget {
  const SetCycle({super.key});

  @override
  State<SetCycle> createState() => _SetCycleState();
}

class _SetCycleState extends State<SetCycle> {
  String selectedInterval = '每日';
  List<bool> weekSelection = [false, true, false, false, false, false, false];
  List<bool> monthSelection = List.generate(31, (index) => index == 0);

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
      child: Column(
        children: [
          // 拖拽指示器
          // Container(
          //   width: 40,
          //   height: 4,
          //   margin: EdgeInsets.symmetric(vertical: 12),
          //   decoration: BoxDecoration(
          //     color: Colors.grey[300],
          //     borderRadius: BorderRadius.circular(2),
          //   ),
          // ),

          // 标题和关闭按钮
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('选择任务周期'),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedInterval = '每日';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 24.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedInterval == '每日'
                              ? Color(0XFF0A68DA)
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                        color: selectedInterval == '每日'
                            ? Color(0XFF0A68DA).withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: Text(
                        '每日',
                        style: TextStyle(
                          color: selectedInterval == '每日'
                              ? Color(0XFF0A68DA)
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedInterval = '每周';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 24.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedInterval == '每周'
                              ? Color(0XFF0A68DA)
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                        color: selectedInterval == '每周'
                            ? Color(0XFF0A68DA).withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: Text(
                        '每周',
                        style: TextStyle(
                          color: selectedInterval == '每周'
                              ? Color(0XFF0A68DA)
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedInterval = '每月';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 24.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedInterval == '每月'
                              ? Color(0XFF0A68DA)
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                        color: selectedInterval == '每月'
                            ? Color(0XFF0A68DA).withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: Text(
                        '每月',
                        style: TextStyle(
                          color: selectedInterval == '每月'
                              ? Color(0XFF0A68DA)
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
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
                  onPressed: () {},
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

  Widget everyDay() {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'lib/assets/bell.png', // 请确保在项目的assets文件夹下有对应的铃铛图片bell.png
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
    final List<String> weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    void toggleSelection(int index) {
      setState(() {
        weekSelection[index] = !weekSelection[index];
      });
    }

    return Container(
      padding: EdgeInsets.only(left: 16.0),
      child: ListView.builder(
        itemCount: weekdays.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(weekdays[index]),
            value: weekSelection[index],
            onChanged: (bool? value) {
              if (value != null) {
                toggleSelection(index);
              }
            },
            activeColor: Color(0XFF0A68DA),
          );
        },
      ),
    );
  }

  Widget everyMonth() {
    void toggleSelection(int index) {
      setState(() {
        monthSelection[index] = !monthSelection[index];
      });
    }

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
                toggleSelection(index);
              }
            },
            activeColor: Color(0XFF0A68DA),
          );
        },
      ),
    );
  }
}
