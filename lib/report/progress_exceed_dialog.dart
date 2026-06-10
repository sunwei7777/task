import 'package:flutter/material.dart';

/// 超出前道工序进度提示弹窗
class ProgressExceedDialog extends StatelessWidget {
  final List<ProcessProgress> processes;
  final VoidCallback? onConfirm;

  const ProgressExceedDialog({
    super.key,
    required this.processes,
    this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required List<ProcessProgress> processes,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) =>
          ProgressExceedDialog(processes: processes, onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.only(
          top: 32,
          left: 20,
          right: 20,
          bottom: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFA9314),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 标题
            const Text(
              '超出前道工序进度',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            // 说明文字
            const Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  letterSpacing: 0.5,
                  color: Color(0xFF222222),
                ),
                children: [
                  TextSpan(
                    text: '任务进度不可超过前道工序最低进度',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: '。如继续汇报数据'),
                  TextSpan(
                    text: '暂时无法生效',
                    style: TextStyle(color: Color(0xFF010101)),
                  ),
                  TextSpan(
                    text: '（需等待前道工序提交后更新同步）',
                    style: TextStyle(color: Color(0xFFE46723)),
                  ),
                  TextSpan(text: '。且汇报记录将抄送上级。'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 工序进度列表
            ...processes.map(
              (p) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF3FF),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${p.progress}%',
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '取消',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm?.call();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0A68DA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: const Text(
                    '我知道了',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProcessProgress {
  final String name;
  final int progress;

  const ProcessProgress({required this.name, required this.progress});
}
