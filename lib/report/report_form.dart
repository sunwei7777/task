import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/assets/app_styles.dart';
import 'package:flutter_application_1/report/report_progress.dart';
import 'package:flutter_application_1/services/storage_service.dart';
// import 'package:flutter_application_1/task/select_principal.dart';
import 'package:flutter_application_1/task/task_look_bottom.dart';
import 'package:flutter_application_1/utils/common.dart';
import 'package:flutter_application_1/utils/form_widgets.dart';
import 'package:flutter_application_1/utils/task_info_card.dart';
import 'package:flutter_application_1/utils/video_thumbnail.dart';
import 'package:flutter_application_1/report/report_form_shared.dart';
import 'package:flutter_application_1/report/progress_exceed_dialog.dart';
import 'package:flutter_application_1/utils/permission_helper.dart';
import 'package:flutter_application_1/utils/top_notification.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../store/task_controller.dart';

class ReportForm extends StatefulWidget {
  final int? taskId;
  final Task? task;

  const ReportForm({super.key, this.taskId, this.task});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final TaskService _taskService = TaskService();
  final TaskController taskController = Get.find<TaskController>();
  final TextEditingController taskContentController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  Task? _task;
  String? _applicant;
  String _selectedProgress = '';
  List<Map<String, dynamic>> _customReportItems = [];
  String? _expectedCompletionDate;
  Map<String, String> strMethods = {
    '整体汇报': 'slider',
    'SKU汇报': 'sku',
    '自定义汇报': 'style',
  };
  // 图片/视频上传
  List<File> _mediaFiles = [];
  List<String> _uploadedUrls = [];
  List<String> _mediaFileTypes = []; // 'image' or 'video'
  // 每个文件的上传进度：null=未开始, 0.0~1.0=上传中, 1.0=成功, -1=失败
  Map<int, double> _mediaProgress = {};
  // 附件上传
  List<File> _attachmentFiles = [];
  List<String> _uploadedAttachmentUrls = [];
  List<int> _attachmentFileTypes = [];
  Map<int, double> _attachmentProgress = {};

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _task = widget.task;
    } else if (widget.taskId != null) {
      _loadTask();
    }
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await StorageService.getUserInfo();
    if (mounted) {
      setState(() {
        _applicant =
            '${userInfo?['realName']?.toString() ?? userInfo?['userName']?.toString()}(我)';
      });
    }
  }

  Future<void> _loadTask() async {
    final task = await _taskService.fetchTaskDetail(widget.taskId!);
    if (mounted) setState(() => _task = task);
  }

  int _normalizedProgressValue() {
    final raw = _selectedProgress.replaceAll('%', '');
    final parsed = double.tryParse(raw) ?? 0;
    return parsed.clamp(0, 100).toInt();
  }

  Future<void> _submit() async {
    if (_task == null) {
      if (mounted) {
        TopNotification.show(
          context,
          message: '任务数据未加载',
          backgroundColor: Colors.orange,
        );
      }
      return;
    }
    if (taskContentController.text.trim().isEmpty) {
      if (mounted) {
        TopNotification.show(
          context,
          message: '请填写申请原因',
          backgroundColor: Colors.orange,
        );
      }
      return;
    }
    if (startDate == null) {
      if (mounted) {
        TopNotification.show(
          context,
          message: '请选择计划开始时间',
          backgroundColor: Colors.orange,
        );
      }
      return;
    }
    if (endDate == null) {
      if (mounted) {
        TopNotification.show(
          context,
          message: '请选择计划结束时间',
          backgroundColor: Colors.orange,
        );
      }
      return;
    }

    final reportCode = strMethods[_task!.reportMethod] ?? 'slider';
    if ((reportCode == 'sku' || reportCode == 'style') &&
        _customReportItems.isEmpty) {
      if (mounted) {
        TopNotification.show(
          context,
          message: '汇报明细不能为空',
          backgroundColor: Colors.orange,
        );
      }
      return;
    }
    if (_selectedProgress.isEmpty) {
      TopNotification.show(
        context,
        message: '请选择汇报进度',
        backgroundColor: Colors.orange,
      );
      return;
    }

    final remark = _remarkController.text.trim();
    final hasRemark = remark.isNotEmpty;
    final hasExpectedDate =
        _expectedCompletionDate != null && _expectedCompletionDate!.isNotEmpty;
    if (hasRemark != hasExpectedDate) {
      TopNotification.show(
        context,
        message: '备注和预计完成时间必须同时填写或同时不填',
        backgroundColor: Colors.orange,
      );
      return;
    }

    String fmt(DateTime dt) {
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    }

    final imageIds = _uploadedUrls
        .map((url) => int.tryParse(url))
        .whereType<int>()
        .toList();
    // 附件ID
    final attachmentIds = _uploadedAttachmentUrls
        .map((url) => int.tryParse(url))
        .whereType<int>()
        .toList();
    final data = <String, dynamic>{
      'taskId': widget.taskId ?? _task!.id,
      'taskNo': _task!.taskNo,
      'applyType': 0,
      'applyReason': taskContentController.text.trim(),
      'remark': _remarkController.text.trim(),
      'reportMethod': reportCode,
      'progress': _normalizedProgressValue(),
      'startTime': fmt(startDate!),
      'endTime': fmt(endDate!),
      'imageList': imageIds,
      'attachmentList': attachmentIds,
      'mayFinishDate': _expectedCompletionDate,
      reportCode == 'sku'
              ? 'taskReportSkuDetailDTOList'
              : 'taskReportStyleDetailDTOList':
          _customReportItems,
    };

    const validTaskTypes = {1, 2, 9}; // 项目、订单、打样
    if (validTaskTypes.contains(_task?.taskType) &&
        _task?.billNo != null &&
        _task!.billNo!.isNotEmpty &&
        _task?.originTaskId != null) {
      final checkResult = await _taskService.checkPreTaskReport(
        billNo: _task!.billNo!,
        progress: int.tryParse(data['progress'].toString()) ?? 0,
        taskId: _task!.originTaskId!,
      );
      if (!mounted) return;
      if (checkResult.checkStatus != 'pass') {
        ProgressExceedDialog.show(
          context,
          processes: checkResult.preTaskDetails
              .map(
                (d) => ProcessProgress(name: d.taskName, progress: d.progress),
              )
              .toList(),
          onConfirm: () async {
            try {
              final msg = await _taskService.savePendingReport(data);
              if (!mounted) return;
              final nav = Navigator.of(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('暂存提交'),
                  content: Text(msg),
                  titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
                  actions: [
                    TextButton(
                      onPressed: () {
                        nav.pop(); // 关闭弹窗
                        nav.pop(); // 关闭汇报页面
                      },
                      child: Text('确定'),
                    ),
                  ],
                ),
              );
            } catch (_) {}
          },
        );
        return;
      }
    }

    final progress = await _taskService.submitReport(data);
    if (!mounted) return;
    if (_task != null) {
      taskController.updateTaskProgress(_task!.id, progress ?? 0);
    }
    TopNotification.success(context, '提交成功');
    Navigator.pop(context);
  }

  Future<void> _pickMedia() async {
    // 显示选择对话框
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍摄照片'),
                onTap: () {
                  Navigator.pop(context);
                  _capturePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('拍摄录像'),
                onTap: () {
                  Navigator.pop(context);
                  _captureVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('取消'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 从相册选择媒体
  Future<void> _pickFromGallery() async {
    final hasPermission = await PermissionHelper.ensurePhotoPermission(context);
    if (!hasPermission || !mounted) return;
    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 9 - _mediaFiles.length,
        requestType: RequestType.common,
      ),
    );
    if (assets == null || assets.isEmpty) return;

    for (final asset in assets) {
      final file = await asset.file;
      if (!mounted) return;
      if (file == null) continue;
      final isVideo = asset.type == AssetType.video;
      setState(() {
        _mediaFiles.add(file);
        _mediaFileTypes.add(isVideo ? 'video' : 'image');
      });
      _uploadMedia(file, isVideo ? 'video' : 'image');
    }
  }

  /// 拍摄照片
  Future<void> _capturePhoto() async {
    final hasPermission = await PermissionHelper.ensureCameraPermission(context);
    if (!hasPermission || !mounted) return;
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (!mounted) return;
    if (photo == null) return;

    final File file = File(photo.path);
    setState(() {
      _mediaFiles.add(file);
      _mediaFileTypes.add('image');
    });
    _uploadMedia(file, 'image');
  }

  /// 拍摄录像
  Future<void> _captureVideo() async {
    final hasCamera = await PermissionHelper.ensureCameraPermission(context);
    if (!hasCamera || !mounted) return;
    final hasMic = await PermissionHelper.ensureMicrophonePermission(context);
    if (!hasMic || !mounted) return;
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    if (!mounted) return;
    if (video == null) return;

    final File file = File(video.path);
    setState(() {
      _mediaFiles.add(file);
      _mediaFileTypes.add('video');
    });
    _uploadMedia(file, 'video');
  }

  Future<void> _uploadMedia(File file, String fileType) async {
    final index = _mediaFiles.indexOf(file);
    if (index == -1) return;
    if (!mounted) return;
    setState(() {
      _mediaProgress[index] = 0.0;
    });
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final url = await _taskService.uploadReportFile(
        file: file,
        fileName: fileName,
        type: fileType == 'image' ? 1 : 3,
        onSendProgress: (sent, total) {
          if (total > 0 && mounted) {
            setState(() {
              _mediaProgress[index] = sent / total;
            });
          }
        },
      );
      if (!mounted) return;
      setState(() {
        _uploadedUrls.add(url);
        _mediaProgress[index] = 1.0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mediaProgress[index] = -1;
      });
    }
  }

  Widget _buildMediaSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              const Text('图片/视频', style: TextStyle(color: Color(0xFF010101))),
              const Spacer(),
              GestureDetector(
                onTap: _mediaFiles.length < 9 ? _pickMedia : null,
                child: Text(
                  '添加',
                  style: TextStyle(
                    color: _mediaFiles.length < 9
                        ? Color(0xFF0073FF)
                        : Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (_mediaFiles.isEmpty)
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                margin: EdgeInsets.only(top: 12),
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Color(0xFFDDDDDD),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey[400],
                      size: 28,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '选择图片或视频',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...List.generate(_mediaFiles.length, (index) {
                    return _buildMediaItem(_mediaFiles[index], index);
                  }),
                  if (_mediaFiles.length < 9) _buildAddMediaButtons(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddMediaButtons() {
    if (_mediaFiles.length >= 9) return const SizedBox.shrink();
    return GestureDetector(
      onTap: _pickMedia,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Color(0xFFDDDDDD)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.grey[500], size: 24),
            SizedBox(height: 4),
            Text(
              '${_mediaFiles.length}/9',
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaItem(File file, int index) {
    final isVideo =
        file.path.endsWith('.mp4') ||
        file.path.endsWith('.mov') ||
        file.path.endsWith('.m4v');
    final progress = _mediaProgress[index];
    final isFailed = progress == -1;
    final isUploading = progress != null && progress >= 0 && progress < 1.0;
    final isDone = progress == 1.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isFailed ? Colors.red[300]! : Colors.grey[300]!,
              width: isFailed ? 1.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: isVideo
                ? VideoThumbnail.fromFile(file: file, width: 80, height: 80)
                : Image.file(file, fit: BoxFit.cover, width: 80, height: 80),
          ),
        ),
        // 上传中进度遮罩
        if (isUploading)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        // 上传成功勾号
        if (isDone)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 10, color: Colors.white),
            ),
          ),
        // 上传失败重试
        if (isFailed)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: GestureDetector(
                onTap: () => _uploadMedia(file, isVideo ? 'video' : 'image'),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 20),
                    SizedBox(height: 2),
                    Text(
                      '重试',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // 删除按钮（上传中不显示）
        if (!isUploading)
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: () => _removeMedia(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
      if (index < _mediaFileTypes.length) {
        _mediaFileTypes.removeAt(index);
      }
      if (index < _uploadedUrls.length) {
        _uploadedUrls.removeAt(index);
      }
      _mediaProgress.remove(index);
      final newProgress = <int, double>{};
      for (var entry in _mediaProgress.entries) {
        final key = entry.key < index ? entry.key : entry.key - 1;
        newProgress[key] = entry.value;
      }
      _mediaProgress = newProgress;
    });
  }

  Widget _buildAttachmentItem(int index) {
    final fileName = _attachmentFiles[index].path
        .split(Platform.pathSeparator)
        .last;
    final progress = _attachmentProgress[index];
    final isFailed = progress == -1;
    final isUploading = progress != null && progress >= 0 && progress < 1.0;
    final isDone = progress == 1.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isFailed ? Colors.red[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isFailed ? Colors.red[300]! : Colors.grey[300]!,
              width: isFailed ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFailed ? Icons.error_outline : Icons.insert_drive_file,
                    size: 18,
                    color: isFailed ? Colors.red[400] : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      fileName,
                      style: TextStyle(
                        fontSize: 13,
                        color: isFailed ? Colors.red[700] : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isDone)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              if (isUploading)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF208BDE),
                        ),
                        minHeight: 3,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              if (isFailed)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    onTap: () => _uploadAttachmentFile(
                      _attachmentFiles[index],
                      _attachmentFileTypes[index],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 14, color: Colors.red[400]),
                        const SizedBox(width: 2),
                        Text(
                          '点击重试',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!isUploading)
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: () => _removeAttachment(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (!mounted) return;
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final ext = result.files.single.extension?.toLowerCase();

      const imgExts = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic'];
      const videoExts = ['mp4', 'mov', 'm4v', 'avi', 'mkv'];
      int type;
      if (imgExts.contains(ext)) {
        type = 1; // 图片
      } else if (videoExts.contains(ext)) {
        type = 3; // 视频
      } else {
        type = 2; // 附件
      }

      setState(() {
        _attachmentFiles.add(file);
        _attachmentFileTypes.add(type);
      });

      _uploadAttachmentFile(file, type);
    }
  }

  Future<void> _uploadAttachmentFile(File file, int type) async {
    final index = _attachmentFiles.indexOf(file);
    if (index == -1) return;
    if (!mounted) return;
    setState(() {
      _attachmentProgress[index] = 0.0;
    });
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final url = await _taskService.uploadReportFile(
        file: file,
        fileName: fileName,
        type: type,
        onSendProgress: (sent, total) {
          if (total > 0 && mounted) {
            setState(() {
              _attachmentProgress[index] = sent / total;
            });
          }
        },
      );
      if (!mounted) return;
      setState(() {
        _uploadedAttachmentUrls.add(url);
        _attachmentProgress[index] = 1.0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _attachmentProgress[index] = -1;
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachmentFiles.removeAt(index);
      if (index < _uploadedAttachmentUrls.length) {
        _uploadedAttachmentUrls.removeAt(index);
      }
      _attachmentProgress.remove(index);
      final newProgress = <int, double>{};
      for (var entry in _attachmentProgress.entries) {
        final key = entry.key < index ? entry.key : entry.key - 1;
        newProgress[key] = entry.value;
      }
      _attachmentProgress = newProgress;
    });
  }

  Widget _buildAttachmentSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              const Text('附件', style: TextStyle(color: Color(0xFF010101))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...List.generate(_attachmentFiles.length, (index) {
                return _buildAttachmentItem(index);
              }),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.grey, size: 18),
                      SizedBox(width: 8),
                      Text(
                        '选择文件',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;

    return Container(
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
          Common.topBar(context, '补汇报'),
          Container(height: 0.5, color: Colors.grey[300]!),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '任务基本信息',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF001111),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final id = widget.taskId ?? _task?.id ?? 0;
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => TaskLookBottom(
                                  taskId: id,
                                  task: task,
                                  isHasDetail: !const ['项目', '订单', '打样'].any(
                                    (t) =>
                                        task?.taskTypeDesc.startsWith(t) ==
                                        true,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              minimumSize: Size(0, 32),
                            ),
                            child: Text(
                              '任务详情',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF080808),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.0),
                      TaskInfoCard(task: task),
                    ],
                  ),

                  FormWidgets.buildReadOnlyItem(
                    '申请类型',
                    true,
                    '补汇报',
                    Icons.category,
                  ),
                  FormWidgets.buildInputItem(
                    '申请原因',
                    true,
                    taskContentController,
                    Icons.description,
                  ),
                  FormWidgets.buildDateItem(
                    context,
                    '计划开始时间',
                    true,
                    startDate,
                    Icons.access_time,
                    onPressed: (selectedDateTime) {
                      setState(() => startDate = selectedDateTime);
                      Navigator.pop(context);
                      return null;
                    },
                  ),
                  FormWidgets.buildDateItem(
                    context,
                    '计划结束时间',
                    true,
                    endDate,
                    Icons.event,
                    onPressed: (selectedDateTime) {
                      setState(() => endDate = selectedDateTime);
                      Navigator.pop(context);
                      return null;
                    },
                  ),

                  if (task?.reportMethod?.isNotEmpty == true)
                    ReportProgress(
                      reportMethod: task!.reportMethod!,
                      onProgressChanged: (v) => _selectedProgress = v,
                      onCustomDataChanged: (v) => _customReportItems = v,
                      taskNo: task.taskNo,
                      task: task,
                    ),
                  FormWidgets.buildReadOnlyItem(
                    '汇报人',
                    true,
                    _applicant ?? '',
                    Icons.person,
                    onTap: () {
                      // showModalBottomSheet(
                      //   context: context,
                      //   isScrollControlled: true,
                      //   backgroundColor: Colors.transparent,
                      //   builder: (_) => SelectPrincipal('申请人'),
                      // );
                    },
                  ),
                  ReportRemarkSection(controller: _remarkController),
                  ReportExpectedCompletionSection(
                    onChanged: (v) => _expectedCompletionDate = v,
                  ),
                  // 图片/视频上传
                  _buildMediaSection(),
                  // 附件上传
                  _buildAttachmentSection(),
                ],
              ),
            ),
          ),
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
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(fontSize: 14, color: Color(0xFF080808)),
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
    );
  }
}
