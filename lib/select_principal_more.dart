import 'package:flutter/material.dart';

class SelectPrincipalMore extends StatefulWidget {
  final String label;
  const SelectPrincipalMore(this.label, {super.key});

  @override
  State<SelectPrincipalMore> createState() => _SelectPrincipalMoreState();
}

class _SelectPrincipalMoreState extends State<SelectPrincipalMore> {
  List<String> personList = ['张三', '旺瑞君', '郗瑶', '尤艺锦', '武诚', '常贵', '先芳邦'];
  List<String> selectedPersons = [];
  String searchQuery = '';
  String departmentPath = '全部参与人';

  // 检查是否是部门主管
  bool _isDepartmentHead(String person) {
    return person == '张三' || person == '旺瑞君';
  }

  void _toggleSelection(String person) {
    // 部门主管不能被取消选择
    if (_isDepartmentHead(person)) {
      return;
    }

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

  void _toggleSelectAll() {
    setState(() {
      if (selectedPersons.length == _filteredPersonList.length) {
        // 取消全选时，保留部门主管
        selectedPersons = _filteredPersonList.where(_isDepartmentHead).toList();
      } else {
        selectedPersons = List.from(_filteredPersonList);
      }
    });
  }

  bool get _isAllSelected {
    // 检查非部门主管是否都被选中
    List<String> nonDepartmentHeads = _filteredPersonList
        .where((p) => !_isDepartmentHead(p))
        .toList();
    List<String> selectedNonDepartmentHeads = selectedPersons
        .where((p) => !_isDepartmentHead(p))
        .toList();
    return selectedNonDepartmentHeads.length == nonDepartmentHeads.length &&
        _filteredPersonList.isNotEmpty;
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
      child: Column(
        children: [
          // 标题和关闭按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              Text(widget.label),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('确定', style: TextStyle(color: Colors.transparent)),
              ),
            ],
          ),
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
              style: TextStyle(color: Color(0xFF808080), fontSize: 12),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPersonList.length,
              itemBuilder: (context, index) {
                String person = _filteredPersonList[index];
                bool isDepartmentHead = _isDepartmentHead(person);
                bool isSelected =
                    selectedPersons.contains(person) || isDepartmentHead;
                String role = isDepartmentHead ? '部门主管' : '';

                // 确保部门主管始终在选中列表中
                if (isDepartmentHead && !selectedPersons.contains(person)) {
                  selectedPersons.add(person);
                }

                return CheckboxListTile(
                  activeColor: Color(0xFF208BDE),
                  title: Text(
                    person,
                    style: isDepartmentHead
                        ? TextStyle(color: Colors.grey)
                        : null,
                  ),
                  subtitle: role.isNotEmpty
                      ? Text(
                          role,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      : null,
                  value: isSelected,
                  onChanged: isDepartmentHead
                      ? null
                      : (bool? value) {
                          if (value != null) {
                            _toggleSelection(person);
                          }
                        },
                  enabled: !isDepartmentHead,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.0, top: 12.0, bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _toggleSelectAll,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isAllSelected,
                        onChanged: (value) {
                          _toggleSelectAll();
                        },
                        activeColor: Color(0xFF208BDE),
                      ),
                      Text(
                        '全选',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 这里可以添加确定后的逻辑，比如将选中的人员传递出去
                    print('选中的人员: $selectedPersons');
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
