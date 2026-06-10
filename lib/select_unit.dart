import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SelectUnit extends StatefulWidget {
  final String selectedUnit;
  const SelectUnit({Key? key, this.selectedUnit = ''}) : super(key: key);

  @override
  _SelectUnitState createState() => _SelectUnitState();
}

class _SelectUnitState extends State<SelectUnit> {
  String _selectedUnit = '斤';
  final List<String> _unit = ['斤', '个', '件', '米', '千克'];

  @override
  void initState() {
    super.initState();
    // 从widget.selectedUnit获取初始值，如果为空则使用默认值'斤'
    if (widget.selectedUnit.isNotEmpty) {
      _selectedUnit = widget.selectedUnit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 标题和关闭按钮
          Padding(
            padding: EdgeInsets.only(left: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '选择单位',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 滚动选择器
          Expanded(
            child: CupertinoPicker(
              magnification: 1.2,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 50,
              scrollController: FixedExtentScrollController(
                initialItem: _unit.indexOf(_selectedUnit),
              ),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedUnit = _unit[index];
                });
              },
              children: _unit.map((progress) {
                return Center(
                  child: Text(
                    progress,
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedUnit == progress
                          ? Color(0xFF1890FF)
                          : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 底部操作按钮
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 确定按钮点击事件
                      Navigator.pop(context, _selectedUnit);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0073FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      minimumSize: Size(0, 36),
                    ),
                    child: Text('确定', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
