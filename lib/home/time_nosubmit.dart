import 'package:flutter/material.dart';
import 'package:flutter_application_1/report/report_details.dart';

class TimeNosubmit extends StatefulWidget {
  final Map<String, dynamic>? timerStatus;

  const TimeNosubmit({Key? key, this.timerStatus}) : super(key: key);

  @override
  _TimeNosubmitState createState() => _TimeNosubmitState();
}

class _TimeNosubmitState extends State<TimeNosubmit> {
  @override
  Widget build(BuildContext context) {
    final status = widget.timerStatus;
    final String durationText = _buildDurationText(status);
    final String hintText = _buildHintText(status);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Color(0xFFFA9314), size: 56),
            SizedBox(height: 24),
            Text(
              '你还有计时还未提交',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFE6F2FF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                durationText,
                style: TextStyle(fontSize: 14, color: Color(0xFF0073FF)),
              ),
            ),
            SizedBox(height: 24),
            Text(
              hintText,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => ReportDetails('dynamic'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0073FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  '去汇报',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildDurationText(Map<String, dynamic>? status) {
    if (status == null) return '持续时间 --';

    final startTime = _roundDateTime(status['startTime'], roundDown: true);
    final endTimeHour = _roundHour(status['endTime'], roundDown: false);
    final duration = _formatAccumulated(status['accumulatedSeconds']);

    return '持续时间 $startTime~$endTimeHour ($duration)';
  }

  String _buildHintText(Map<String, dynamic>? status) {
    if (status == null) return '您有计时还未汇报，汇报后才能开展其他任务。请点击「去汇报」提交';

    final dateRange = _formatDateRange(status['startTime'], status['endTime']);
    return '您在$dateRange有计时还未汇报，汇报后才能开展其他任务。请点击「去汇报」提交';
  }

  /// 2026-05-23 14:15:26 → 05-23 14:00 (roundDown) / 05-23 15:00 (!roundDown)
  String _roundDateTime(dynamic dateTimeStr, {bool roundDown = true}) {
    if (dateTimeStr == null) return '--';
    try {
      final str = dateTimeStr.toString();
      if (str.length < 16) return str;
      final month = str.substring(5, 7);
      final day = str.substring(8, 10);
      int hour = int.parse(str.substring(11, 13));
      if (!roundDown) {
        hour += 1;
        if (hour >= 24) hour = 23;
      }
      return '$month-$day ${hour.toString().padLeft(2, '0')}:00';
    } catch (e) {
      return '--';
    }
  }

  /// 2026-05-23 14:17:26 → 15:00
  String _roundHour(dynamic dateTimeStr, {bool roundDown = true}) {
    if (dateTimeStr == null) return '--';
    try {
      final str = dateTimeStr.toString();
      if (str.length < 13) return '--';
      int hour = int.parse(str.substring(11, 13));
      if (!roundDown) {
        hour += 1;
        if (hour >= 24) hour = 23;
      }
      return '${hour.toString().padLeft(2, '0')}:00';
    } catch (e) {
      return '--';
    }
  }

  /// 120 → 0小时02分
  String _formatAccumulated(dynamic seconds) {
    if (seconds == null) return '--';
    final totalSeconds = seconds is int
        ? seconds
        : int.tryParse(seconds.toString()) ?? 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours}小时${minutes.toString().padLeft(2, '0')}分';
  }

  /// 提取 MM-dd 用于提示文字
  String _formatDateRange(dynamic startStr, dynamic endStr) {
    String formatDate(dynamic s) {
      if (s == null) return '--';
      try {
        final str = s.toString();
        if (str.length >= 10) return str.substring(5, 10);
        return str;
      } catch (e) {
        return '--';
      }
    }

    final start = formatDate(startStr);
    final end = formatDate(endStr);
    if (start == end) return start;
    return '$start~$end';
  }
}
