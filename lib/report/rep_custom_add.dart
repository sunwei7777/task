import 'package:flutter/material.dart';
import 'package:flutter_application_1/assets/app_styles.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:flutter_application_1/report/select_unit.dart';
import 'package:flutter_application_1/utils/common.dart';
import 'package:flutter_application_1/utils/top_notification.dart';

class RepCustomAdd extends StatefulWidget {
  final ReportItem? initialItem;
  final int? editIndex;

  const RepCustomAdd({Key? key, this.initialItem, this.editIndex})
    : super(key: key);

  @override
  _RepCustomAddState createState() => _RepCustomAddState();
}

class _RepCustomAddState extends State<RepCustomAdd> {
  late final TextEditingController _materialNameController =
      TextEditingController(text: widget.initialItem?.materialName ?? '');
  late final TextEditingController _spec1Controller = TextEditingController(
    text: widget.initialItem?.spec1 ?? '',
  );
  late final TextEditingController _spec2Controller = TextEditingController(
    text: widget.initialItem?.spec2 ?? '',
  );
  late final TextEditingController _supplierController = TextEditingController(
    text: widget.initialItem?.supplier ?? '',
  );
  late final TextEditingController _noteController = TextEditingController(
    text: widget.initialItem?.remark ?? '',
  );
  late final TextEditingController _targetQuantityController =
      TextEditingController(
        text: widget.initialItem != null
            ? widget.initialItem!.qty.toString()
            : '',
      );
  late String _unit = widget.initialItem?.unit ?? '斤';

  void _submit() {
    if (_materialNameController.text.trim().isEmpty) {
      TopNotification.show(
        context,
        message: '请填写物料名称',
        backgroundColor: Colors.orange,
      );
      return;
    }
    if (_targetQuantityController.text.trim().isEmpty) {
      TopNotification.show(
        context,
        message: '请填写目标数量',
        backgroundColor: Colors.orange,
      );
      return;
    }
    Navigator.pop(context, {
      'editIndex': widget.editIndex,
      'materialName': _materialNameController.text.trim(),
      'spec1': _spec1Controller.text.trim(),
      'spec2': _spec2Controller.text.trim(),
      'supplier': _supplierController.text.trim(),
      'remark': _noteController.text.trim(),
      'qty': double.tryParse(_targetQuantityController.text.trim()) ?? 0,
      'unit': _unit,
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
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
              // 顶部标题
              Common.topBar(context, '添加目标', showCloseButton: true),
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
                          border: AppStyles.border,
                          enabledBorder: AppStyles.enabledBorder,
                          focusedBorder: AppStyles.focusedBorder,
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
                      // Text(
                      //   '图片',
                      //   style: TextStyle(fontSize: 14, color: Colors.black),
                      // ),
                      // SizedBox(height: 8),
                      // Container(
                      //   width: 100,
                      //   height: 100,
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.grey[300]!, width: 1),
                      //     borderRadius: BorderRadius.circular(4),
                      //   ),
                      //   child: Center(
                      //     child: Icon(Icons.add, size: 32, color: Colors.grey[400]),
                      //   ),
                      // ),
                      // SizedBox(height: 16),

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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
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
                            builder: (context) =>
                                SelectUnit(selectedUnit: _unit),
                          );
                          if (selectedUnit != null) {
                            setState(() {
                              _unit = selectedUnit;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF080808),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
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
        ),
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
            border: AppStyles.border,
            enabledBorder: AppStyles.enabledBorder,
            focusedBorder: AppStyles.focusedBorder,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            hintText: '请输入',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }
}
