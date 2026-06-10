import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:flutter_application_1/report/rep_custom.dart';
import 'package:flutter_application_1/report/rep_sku.dart';
import 'package:flutter_application_1/report/rep_zt.dart';

class ReportProgress extends StatefulWidget {
  final String reportMethod;
  final ValueChanged<String>? onProgressChanged;
  final ValueChanged<List<Map<String, dynamic>>>? onCustomDataChanged;
  final String? taskNo;
  final Task? task;
  const ReportProgress({
    super.key,
    required this.reportMethod,
    this.onProgressChanged,
    this.onCustomDataChanged,
    this.taskNo,
    this.task,
  });

  @override
  State<ReportProgress> createState() => _ReportProgressState();
}

class _ReportProgressState extends State<ReportProgress> {
  int reportType = 0;
  late String selectedProgress;
  Map<String, int> reMethods = {
    '整体汇报': 0,
    'slider': 0,
    'SKU汇报': 1,
    'sku': 1,
    '自定义汇报': 2,
    'style': 2,
  };

  void _updateReportType() {
    reportType = reMethods[widget.reportMethod] ?? 0;
  }

  String _normalizeProgress(dynamic value) {
    final raw = value?.toString().replaceAll('%', '') ?? '';
    final parsed = double.tryParse(raw) ?? 0;
    return '${parsed.clamp(0, 100).toInt()}%';
  }

  @override
  void initState() {
    super.initState();
    _updateReportType();
    final p = widget.task?.progress ?? 0;
    selectedProgress = _normalizeProgress(p);
  }

  @override
  void didUpdateWidget(ReportProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reportMethod != oldWidget.reportMethod) {
      _updateReportType();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (cotext) {
            return reportType == 0
                ? RepZt(selectedProgress: selectedProgress)
                : reportType == 1
                ? RepSku(
                    reportMethod: widget.reportMethod,
                    taskNo: widget.taskNo,
                    task: widget.task,
                  )
                : RepCustom(
                    reportMethod: widget.reportMethod,
                    taskNo: widget.taskNo,
                    task: widget.task,
                  );
          },
        );
        if (result != null) {
          if (result is Map) {
            widget.onCustomDataChanged?.call(
              (result['items'] as List).cast<Map<String, dynamic>>(),
            );
            selectedProgress = _normalizeProgress(result['progress']);
            widget.onProgressChanged?.call(selectedProgress);
          } else if (result is List) {
            widget.onCustomDataChanged?.call(
              result.cast<Map<String, dynamic>>(),
            );
          } else {
            selectedProgress = _normalizeProgress(result);
            widget.onProgressChanged?.call(selectedProgress);
          }
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
