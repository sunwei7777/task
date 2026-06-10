import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../utils/cors_image.dart';
import '../utils/video_preview.dart';
import '../utils/video_thumbnail.dart';

class ReportHistory extends StatefulWidget {
  final String taskNo;
  final ReportHistoryItem item;

  const ReportHistory({super.key, required this.taskNo, required this.item});

  @override
  State<ReportHistory> createState() => _ReportHistoryState();
}

class _ReportHistoryState extends State<ReportHistory> {
  final TaskService _taskService = TaskService();
  final Map<int, double> _downloadProgress = {};

  static const _reportMethodMap = {
    'slider': '整体汇报',
    'sku': 'SKU汇报',
    'style': '自定义汇报',
  };

  String get _reportMethodLabel =>
      _reportMethodMap[widget.item.reportMethod] ??
      widget.item.reportMethod ??
      '';

  String _formatProgress(num progress) {
    return '${progress.clamp(0, 100).toStringAsFixed(0)}%';
  }

  Future<void> _downloadFile(int fileId, String url, String fileName) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('需要存储权限才能下载文件'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }
    setState(() => _downloadProgress[fileId] = 0);
    try {
      final dir = await getExternalStorageDirectory();
      final downloadDir = Directory('${dir!.path}/Download');
      if (!await downloadDir.exists())
        await downloadDir.create(recursive: true);
      final file = await _taskService.downloadAttachment(
        url,
        '${downloadDir.path}/$fileName',
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress[fileId] = received / total);
          }
        },
      );
      if (mounted) {
        setState(() => _downloadProgress.remove(fileId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已下载: ${file.path}'),
            duration: Duration(seconds: 3),
          ),
        );
        await OpenFilex.open(file.path);
      }
    } catch (_) {
      if (mounted) setState(() => _downloadProgress.remove(fileId));
    }
  }

  List<_MediaItem> get _allMedia {
    final items = <_MediaItem>[];
    for (final img in widget.item.imageList) {
      final url = img is Map
          ? img['filePath']?.toString() ?? ''
          : img.toString();
      if (url.isNotEmpty) items.add(_MediaItem(url: url, isVideo: false));
    }
    for (final v in widget.item.videoList) {
      final url = v is Map ? v['filePath']?.toString() ?? '' : v.toString();
      if (url.isNotEmpty) items.add(_MediaItem(url: url, isVideo: true));
    }
    return items;
  }

  void _preview(BuildContext context, int index) {
    final media = _allMedia;
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: index),
              itemCount: media.length,
              itemBuilder: (ctx, i) {
                final m = media[i];
                return Center(
                  child: m.isVideo
                      ? VideoPreview(url: m.url)
                      : CorsImage(url: m.url, fit: BoxFit.contain),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.grey, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          // 日期时间
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  color: Color(0xFF0073FF),
                  margin: EdgeInsets.only(right: 8),
                ),
                Text(
                  widget.item.createTime ?? '--',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          // 汇报内容卡片
          Container(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 提交人及进度
                Text(
                  '${widget.item.createUser ?? '--'} - $_reportMethodLabel - 提交进度${_formatProgress(widget.item.progress)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),

                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      // 图片上传
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 72,
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '图片上传',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: widget.item.imageList.isNotEmpty
                                ? Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.end,
                                    children: widget.item.imageList
                                        .asMap()
                                        .entries
                                        .map<Widget>((entry) {
                                          final img = entry.value;
                                          final url = img is Map
                                              ? img['filePath']?.toString() ??
                                                    ''
                                              : img.toString();
                                          final idx = entry.key;
                                          return GestureDetector(
                                            onTap: () => _preview(context, idx),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: CorsImage(
                                                  url: url,
                                                  fit: BoxFit.cover,
                                                  errorWidget: Icon(
                                                    Icons.broken_image,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  )
                                : Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '--',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 0.5,
                        width: double.infinity,
                        color: Colors.grey[300]!,
                      ),
                      SizedBox(height: 8),
                      // 视频上传
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 72,
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '视频上传',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: widget.item.videoList.isNotEmpty
                                ? Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.end,
                                    children: widget.item.videoList
                                        .asMap()
                                        .entries
                                        .map<Widget>((entry) {
                                          final v = entry.value;
                                          final url = v is Map
                                              ? v['filePath']?.toString() ?? ''
                                              : v.toString();
                                          final idx =
                                              widget.item.imageList.length +
                                              entry.key;
                                          return VideoThumbnail(
                                            url: url,
                                            onTap: () => _preview(context, idx),
                                          );
                                        })
                                        .toList(),
                                  )
                                : Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '--',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 0.5,
                        width: double.infinity,
                        color: Colors.grey[300]!,
                      ),
                      SizedBox(height: 8),
                      // 文件上传
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '文件上传',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              if (widget.item.attachmentList.isNotEmpty)
                                Text(
                                  ' (${widget.item.attachmentList.length})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black38,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ...widget.item.attachmentList.isNotEmpty
                              ? widget.item.attachmentList.map<Widget>((f) {
                                  final name = f is Map
                                      ? f['fileNameOriginal']?.toString() ??
                                            f['fileName']?.toString() ??
                                            ''
                                      : f.toString();
                                  final url = f is Map
                                      ? f['filePath']?.toString() ?? ''
                                      : '';
                                  final fid = f is Map
                                      ? (f['id'] as int?) ?? name.hashCode
                                      : name.hashCode;
                                  final isDownloading = _downloadProgress
                                      .containsKey(fid);
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: isDownloading
                                              ? null
                                              : () => _downloadFile(
                                                  fid,
                                                  url,
                                                  name,
                                                ),
                                          child: isDownloading
                                              ? SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    value:
                                                        _downloadProgress[fid],
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.cloud_download,
                                                  size: 16,
                                                  color: Color(0xFF0073FF),
                                                ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()
                              : [
                                  Text(
                                    '--',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 0.5,
                        width: double.infinity,
                        color: Colors.grey[300]!,
                      ),
                      SizedBox(height: 8),

                      // 备注
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              '备注',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.item.remark ?? widget.item.applyReason,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: 8),

                      // 语音消息样式
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Container(
                      //       width: 120,
                      //       padding: EdgeInsets.symmetric(
                      //         horizontal: 12,
                      //         vertical: 4,
                      //       ),
                      //       decoration: BoxDecoration(
                      //         gradient: LinearGradient(
                      //           begin: Alignment.topCenter,
                      //           end: Alignment.bottomCenter,
                      //           colors: [Color(0xFFF9F9F9), Color(0xFFBCBCBC)],
                      //         ),
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.end,
                      //         children: [
                      //           Text(
                      //             '18\'',
                      //             style: TextStyle(
                      //               fontSize: 12,
                      //               color: Colors.black54,
                      //             ),
                      //           ),
                      //           SizedBox(width: 4),
                      //           Transform.rotate(
                      //             angle: -90 * 3.1415926535 / 180, // 向左旋转90度
                      //             child: Icon(
                      //               Icons.wifi,
                      //               size: 10,
                      //               color: Colors.black54,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 表格
          if (widget.item.reportMethod == 'style' &&
              widget.item.styleDetailList.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildHeaderCell('物料名称', 80),
                        _buildHeaderCell('规格1', 60),
                        _buildHeaderCell('规格2', 60),
                        _buildHeaderCell('供应商', 60),
                        _buildHeaderCell('备注', 60),
                        _buildHeaderCell('订单数量', 80),
                        _buildHeaderCell('汇报数量', 80),
                        _buildHeaderCell('本次汇报', 80),
                      ],
                    ),
                  ),
                  ...widget.item.styleDetailList.map((detail) {
                    final d = detail as Map<String, dynamic>;
                    return _buildDetailRow(d);
                  }),
                ],
              ),
            ),
          if (widget.item.reportMethod == 'sku' &&
              widget.item.skuDetailList.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildHeaderCell('颜色', 140),
                        _buildHeaderCell('尺码', 60),
                        _buildHeaderCell('订单数量', 80),
                        _buildHeaderCell('已报数量', 80),
                        _buildHeaderCell('本次汇报', 80),
                      ],
                    ),
                  ),
                  ...widget.item.skuDetailList.map((detail) {
                    final d = detail as Map<String, dynamic>;
                    return _buildSkuRow(d);
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, double width) {
    return SizedBox(
      width: width,
      child: Text(title, style: TextStyle(fontSize: 14, color: Colors.black54)),
    );
  }

  Widget _buildDetailRow(Map<String, dynamic> d) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              d['materialName']?.toString() ?? '',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              d['spec1']?.toString() ?? '',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              d['spec2']?.toString() ?? '',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              d['supplier']?.toString() ?? '',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              d['remark']?.toString() ?? '',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${d['qty'] ?? ''}',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${d['completeNum'] ?? ''}${d['unit'] ?? ''}',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${d['currentReportNum'] ?? ''}${d['unit'] ?? ''}',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkuRow(Map<String, dynamic> d) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              d['color']?.toString() ?? '',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              d['size']?.toString() ?? '',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${d['reportNum'] ?? ''}',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${d['completeNum'] ?? ''}',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${d['currentReportNum'] ?? ''}',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaItem {
  final String url;
  final bool isVideo;
  const _MediaItem({required this.url, this.isVideo = false});
}
