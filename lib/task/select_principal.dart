import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/common.dart';

class SelectPrincipal extends StatefulWidget {
  final String label;
  final Function(List<String>)? onConfirm;
  const SelectPrincipal(this.label, {super.key, this.onConfirm});

  @override
  State<SelectPrincipal> createState() => _SelectPrincipalState();
}

class _SelectPrincipalState extends State<SelectPrincipal> {
  List<String> personList = ['张三', '旺瑞君', '郗瑶', '尤艺锦', '武诚', '常贵', '先芳邦'];
  List<String> selectedPersons = [];
  String searchQuery = '';
  String departmentPath = '企业名称 > 销售部 > 请选择';

  void _toggleSelection(String person) {
    if (selectedPersons.contains(person)) {
      setState(() {
        selectedPersons.remove(person);
      });
    } else {
      setState(() {
        selectedPersons.add(person);
      });
    }
  }

  List<String> get _filteredPersonList {
    if (searchQuery.isEmpty) {
      return personList;
    }
    return personList
        .where(
          (person) => person.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
          // 标题和关闭按钮
          Common.topBar(context, '选择${widget.label}', showCloseButton: true),
          Container(height: 0.5, color: Colors.grey[300]!),

          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索',
                suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            child: Text(
              departmentPath,
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPersonList.length,
              itemBuilder: (context, index) {
                String person = _filteredPersonList[index];
                bool isSelected = selectedPersons.contains(person);
                String role = person == '张三' || person == '旺瑞君' ? '部门主管' : '';
                return CheckboxListTile(
                  activeColor: Color(0xFF208BDE),
                  title: Text(person),
                  subtitle: role.isNotEmpty ? Text(role) : null,
                  value: isSelected,
                  onChanged: (bool? value) {
                    if (value != null) {
                      _toggleSelection(person);
                    }
                  },
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // 这里可以添加确定后的逻辑，比如将选中的人员传递出去
                  // print('选中的人员: $selectedPersons');
                  widget.onConfirm?.call(selectedPersons);
                  Navigator.pop(context);
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
            ),
          ),
        ],
      ),
    );
  }
}
