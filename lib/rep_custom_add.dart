import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/select_unit.dart';
import 'package:flutter_application_1/toast_custom.dart';

class RepCustomAdd extends StatefulWidget {
  const RepCustomAdd({Key? key}) : super(key: key);

  @override
  _RepCustomAddState createState() => _RepCustomAddState();
}

class _RepCustomAddState extends State<RepCustomAdd> {
  final TextEditingController _materialNameController = TextEditingController(
    text: '毛圈布-白色',
  );
  final TextEditingController _spec1Controller = TextEditingController();
  final TextEditingController _spec2Controller = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _noteController = TextEditingController(
    text: '布面无瑕疵污渍，无折痕很多字很多字',
  );
  final TextEditingController _targetQuantityController = TextEditingController(
    text: '200',
  );
  String _unit = '斤';

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
          // 顶部标题
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '取消',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '添加目标',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(width: 60),
            ],
          ),
          Container(height: 0.5, color: Colors.grey[300]!),

          // 表单内容
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 物料名称
                  _buildFormItem(
                    '物料名称*',
                    _materialNameController,
                    isRequired: true,
                  ),
                  SizedBox(height: 16),

                  // 规格1
                  _buildFormItem('规格1', _spec1Controller),
                  SizedBox(height: 16),

                  // 规格2
                  _buildFormItem('规格2', _spec2Controller),
                  SizedBox(height: 16),

                  // 供应商
                  _buildFormItem('供应商', _supplierController),
                  SizedBox(height: 16),

                  // 备注
                  Text(
                    '备注',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFB4B4B4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0073FF)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      hintText: '请输入',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  // 图片
                  Text(
                    '图片',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Icon(Icons.add, size: 32, color: Colors.grey[400]),
                    ),
                  ),
                  SizedBox(height: 16),

                  // 目标数量
                  _buildFormItem(
                    '目标数量*',
                    _targetQuantityController,
                    isRequired: true,
                  ),
                  SizedBox(height: 16),

                  // 单位
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '单位',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        TextSpan(
                          text: '*',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final selectedUnit = await showModalBottomSheet(
                        context: context,
                        builder: (context) => SelectUnit(selectedUnit: _unit),
                      );
                      if (selectedUnit != null) {
                        setState(() {
                          _unit = selectedUnit;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFB4B4B4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _unit,
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // 底部按钮
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
                  onPressed: () {
                    Navigator.pop(context);
                    ToastCustom.showToast(context, '添加成功');
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

  Widget _buildFormItem(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label.replaceAll('*', ''),
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              if (isRequired)
                TextSpan(
                  text: '*',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFB4B4B4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0073FF)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            hintText: '请输入',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }
}
