import 'package:flutter/material.dart';
import 'package:flutter_application_1/rep_custom.dart';
import 'package:flutter_application_1/rep_sku.dart';
import 'package:flutter_application_1/rep_zt.dart';

class ReportProgress extends StatefulWidget {
  const ReportProgress({Key? key}) : super(key: key);

  @override
  _ReportProgressState createState() => _ReportProgressState();
}

class _ReportProgressState extends State<ReportProgress> {
  int reportType = 2;
  String selectedProgress = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        selectedProgress = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (cotext) {
            return reportType == 0
                ? RepZt(selectedProgress: selectedProgress)
                : reportType == 1
                ? RepSku()
                : RepCustom();
          },
        );
        if (selectedProgress.isNotEmpty) {
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.timeline, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            // 左侧标签
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF010101)),
                children: [
                  TextSpan(text: '汇报进度'),
                  TextSpan(
                    text: reportType == 0
                        ? '  整体'
                        : reportType == 1
                        ? '  SKU'
                        : '  自定义',
                    style: TextStyle(color: Color(0xFF1BA17D), fontSize: 12),
                  ),
                ],
              ),
            ),
            // 右侧值
            Expanded(
              child: Text(
                selectedProgress,
                style: TextStyle(
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
