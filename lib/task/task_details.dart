import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../store/task_controller.dart';
import '../utils/cors_image.dart';
import '../utils/video_preview.dart';
import '../utils/video_thumbnail.dart';

class TaskDetails extends StatefulWidget {
  final int taskId;
  final Task? initialTask;
  const TaskDetails({super.key, required this.taskId, this.initialTask});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final TaskService _taskService = TaskService();
  Task? _task;
  bool _isLoading = true;
  final Map<int, double> _downloadProgress = {};

  double _syncedProgress(Task task) {
    final ctrl = Get.find<TaskController>();
    final fromList = ctrl.allTasks.firstWhereOrNull((t) => t.id == task.id);
    if (fromList != null) return fromList.progress;
    if (ctrl.currentTask.value?.id == task.id) {
      return ctrl.currentTask.value!.progress;
    }
    return task.progress;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialTask != null) {
      _task = widget.initialTask;
      _isLoading = false;
    } else {
      _loadTaskDetail();
    }
  }

  Future<void> downloadAndOpen(int fileId, String url, String fileName) async {
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
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      final file = await _taskService.downloadAttachment(
        url,
        '${downloadDir.path}/$fileName',
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress[fileId] = received / total);
          }
        },
      );

      print('************${file.path}*********');
      if (mounted) {
        setState(() => _downloadProgress.remove(fileId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已下载到: ${file.path}'),
            duration: Duration(seconds: 3),
          ),
        );
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      print('下载异常: $e');
      if (mounted) {
        setState(() => _downloadProgress.remove(fileId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败: $e'), duration: Duration(seconds: 4)),
        );
      }
    }
  }

  Future<void> _loadTaskDetail() async {
    final task = await _taskService.fetchTaskDetail(widget.taskId);
    if (mounted) {
      setState(() {
        _task = task;
        _isLoading = false;
      });
    }
  }

  Widget buildTaskInfoItem(
    String label,
    String value, {
    bool isProgress = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: isProgress ? Color(0xFF0073FF) : Color(0xFF444444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final task = _task;
    if (task == null) {
      return Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: Text('加载失败')),
      );
    }

    final endTime = task.endTime ?? '';
    final startTime = task.startTime ?? '';
    final attachments = task.attachments ?? [];
    final images = attachments.where((a) => a.isImage).toList();
    final videos = attachments.where((a) => a.isVideo).toList();
    final files = attachments.where((a) => !a.isImage && !a.isVideo).toList();
    final allMedia = <_MediaItem>[
      ...images.map((a) => _MediaItem(url: a.filePath)),
      ...videos.map((a) => _MediaItem(url: a.filePath, isVideo: true)),
    ];

    void preview(int index) {
      showDialog(
        context: context,
        builder: (_) => Dialog.fullscreen(
          child: Stack(
            children: [
              PageView.builder(
                controller: PageController(initialPage: index),
                itemCount: allMedia.length,
                itemBuilder: (ctx, i) {
                  final m = allMedia[i];
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

    return Column(
      children: [
        buildTaskInfoItem('任务名称', task.taskName),
        buildTaskInfoItem('任务类型', task.taskTypeDesc),
        buildTaskInfoItem('任务内容', task.taskContent ?? '--'),
        buildTaskInfoItem('单据编号', task.taskNo),
        buildTaskInfoItem('计划开始时间', startTime.isNotEmpty ? startTime : '--'),
        buildTaskInfoItem('计划结束时间', endTime.isNotEmpty ? endTime : '--'),
        buildTaskInfoItem('负责人', task.principals ?? '--'),
        buildTaskInfoItem(
          '任务进度',
          '${(_syncedProgress(task)).toStringAsFixed(0)}%',
          isProgress: true,
        ),
        buildTaskInfoItem('协作人', task.collaborators ?? '--'),
        buildTaskInfoItem('抄送', task.ccPersons ?? '--'),
        buildTaskInfoItem('关联企业', task.relatedCompaniesList?.join('、') ?? '--'),
        buildTaskInfoItem('关联订单/项目', task.relatedProjectOrder ?? '--'),
        buildTaskInfoItem('联络人', task.contactPerson ?? '--'),
        buildTaskInfoItem('联络电话', task.contactPhones ?? '--'),
        buildTaskInfoItem('添加地址', task.contactAddresses ?? '--'),

        if (images.isNotEmpty) ...[
          Container(
            height: 10,
            color: Color(0xFFE3E3E3),
            margin: EdgeInsets.symmetric(vertical: 10),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '图片',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 12),
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: images.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final img = images[index];
                    return GestureDetector(
                      onTap: () => preview(index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CorsImage(
                          url: img.filePath,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],

        if (videos.isNotEmpty) ...[
          Container(
            height: 10,
            color: Color(0xFFE3E3E3),
            margin: EdgeInsets.symmetric(vertical: 10),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '视频',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 12),
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: videos.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return VideoThumbnail(
                      url: videos[index].filePath,
                      onTap: () => preview(images.length + index),
                    );
                  },
                ),
              ],
            ),
          ),
        ],

        if (files.isNotEmpty) ...[
          Container(
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '附件',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 12),
                ...files.map(
                  (file) => Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                size: 20,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  file.fileNameOriginal,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _downloadProgress.containsKey(file.id)
                              ? null
                              : () => downloadAndOpen(
                                  file.id,
                                  file.filePath,
                                  file.fileNameOriginal,
                                ),
                          child: _downloadProgress.containsKey(file.id)
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: _downloadProgress[file.id],
                                  ),
                                )
                              : Icon(
                                  Icons.cloud_download,
                                  size: 20,
                                  color: Color(0xFF0073FF),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (images.isNotEmpty || files.isNotEmpty)
          Container(
            height: 10,
            color: Color(0xFFE3E3E3),
            margin: EdgeInsets.symmetric(vertical: 10),
          ),

        Container(
          margin: EdgeInsets.only(top: 20),
          child: Column(
            children: [
              buildTaskInfoItem('创建人', task.creatorName ?? '--'),
              buildTaskInfoItem('发布时间', task.createTime ?? '--'),
              buildTaskInfoItem('最新更新', task.updateTime ?? '--'),
              buildTaskInfoItem('更新人', task.updaterName ?? '--'),
              buildTaskInfoItem('实际完成时间', task.actualCompletionTime ?? '--'),
            ],
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}

class _MediaItem {
  final String url;
  final bool isVideo;
  const _MediaItem({required this.url, this.isVideo = false});
}
