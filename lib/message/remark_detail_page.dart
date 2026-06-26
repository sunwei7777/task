import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/message.dart';
import '../store/remark_controller.dart';
import '../report/report_form.dart';
import '../assets/app_styles.dart';

class RemarkDetailPage extends StatefulWidget {
  final RemarkReviewItem detail;

  const RemarkDetailPage({super.key, required this.detail});

  @override
  State<RemarkDetailPage> createState() => _RemarkDetailPageState();
}

class _RemarkDetailPageState extends State<RemarkDetailPage> {
  late RemarkReviewItem _detail;

  @override
  void initState() {
    super.initState();
    _detail = widget.detail;
  }

  Widget _buildInfoRow(
    String label,
    String content, {
    bool contentRight = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              content,
              textAlign: contentRight ? TextAlign.right : TextAlign.left,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3895F2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "查看备注详情",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部标题 + 状态
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _detail.processName.isNotEmpty
                            ? _detail.processName
                            : "备注详情",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _detail.readStatus == 0 ? "未读" : "已读",
                      style: TextStyle(
                        color: _detail.readStatus == 0
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFF4CD964),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _detail.submitTime,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 20),

                // 基础信息
                _buildInfoRow("工序:", _detail.processName),
                _buildInfoRow(
                  "任务周期:",
                  "${_detail.taskStartTime}~${_detail.taskEndTime}",
                ),
                const Divider(height: 20, color: Color(0xffeeee)),
                _buildInfoRow("预计完成时间:", _detail.expectFinishDate),
                _buildInfoRow(
                  "备注:",
                  _detail.remark.isNotEmpty ? _detail.remark : "无",
                  contentRight: false,
                ),

                // 图片
                if (_detail.images.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            "图片:",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _detail.images.map((img) {
                              return GestureDetector(
                                onTap: () {
                                  // TODO: 预览大图
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: Image.network(
                                      img.filePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildInfoRow(
                  "款号:",
                  _detail.styleCode.isNotEmpty ? _detail.styleCode : "无",
                ),
                _buildInfoRow(
                  "订单号:",
                  _detail.billNo.isNotEmpty ? _detail.billNo : "无",
                ),
                _buildInfoRow("提交时间:", _detail.submitTime),
                _buildInfoRow("提交人:", _detail.reporterName),
                const Divider(height: 20, color: Color(0xffeeee)),

                // 处理人列表
                ..._detail.reviewers.where((r) => r.comments.isNotEmpty).map((
                  reviewer,
                ) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 处理人头部
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  "处理人:",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      reviewer.reviewerName,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 处理人意见列表
                        if (reviewer.comments.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 251, 232),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: reviewer.comments.map((c) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            c.commenterName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            c.createTime,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF999999),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.content,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 80),
              ],
            ),
          ),
          // 右下角按钮：reviewer 显示发送意见，否则快捷提交
          Positioned(
            bottom: 20,
            right: 16,
            child: _detail.viewRole == 'reviewer'
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B64FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      _showSendOpinionDialog(_detail.reviewId);
                    },
                    child: const Text("发送意见", style: TextStyle(fontSize: 14)),
                  )
                : ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: const WidgetStatePropertyAll<Color>(
                        Color(0xFFB3E5FC),
                      ),
                      foregroundColor: const WidgetStatePropertyAll<Color>(
                        Colors.blue,
                      ),
                      padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      shape:
                          const WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                          ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ReportForm(taskId: _detail.taskId),
                      );
                    },
                    child: const Text("快捷提交", style: TextStyle(fontSize: 14)),
                  ),
          ),
        ],
      ),
    );
  }

  void _showSendOpinionDialog(int reviewId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("发送意见"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLength: 60,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "请输入意见",
                  border: AppStyles.border,
                  enabledBorder: AppStyles.enabledBorder,
                  focusedBorder: AppStyles.focusedBorder,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                buildCounter:
                    (
                      context, {
                      required int currentLength,
                      required bool isFocused,
                      required int? maxLength,
                    }) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "$currentLength/$maxLength",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("取消"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B64FF),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.of(ctx).pop();
                _submitOpinion(reviewId, text);
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitOpinion(int reviewId, String comment) async {
    final controller = Get.find<RemarkController>();
    final success = await controller.submitComment(reviewId, comment);
    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }
}
