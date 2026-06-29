import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/task_service.dart';
import 'package:flutter_application_1/utils/permission_helper.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/utils/video_thumbnail.dart';

/// 媒体文件最大数量
const int maxMediaFiles = 18;

/// 图片/视频上传区域
/// 调用方通过 [onMediaChanged] 获取已上传成功的文件 ID 列表
class ReportMediaSection extends StatefulWidget {
  final ValueChanged<List<int>>? onMediaChanged;
  final ValueChanged<bool>? onUploadingChanged;

  const ReportMediaSection({
    super.key,
    this.onMediaChanged,
    this.onUploadingChanged,
  });

  @override
  State<ReportMediaSection> createState() => _ReportMediaSectionState();
}

class _ReportMediaSectionState extends State<ReportMediaSection> {
  final TaskService _taskService = TaskService();
  List<File> _files = [];
  List<String> _fileTypes = [];
  Map<int, double> _progress = {};
  List<String> _uploadedUrls = [];

  List<int> get _uploadedIds =>
      _uploadedUrls.map((url) => int.tryParse(url)).whereType<int>().toList();

  void _notify() => widget.onMediaChanged?.call(_uploadedIds);

  bool get _hasPendingUploads => _progress.values.any((p) => p >= 0 && p < 1.0);

  void _notifyUploading() =>
      widget.onUploadingChanged?.call(_hasPendingUploads);

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
        maxAssets: maxMediaFiles - _files.length,
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
        _files.add(file);
        _fileTypes.add(isVideo ? 'video' : 'image');
      });
      _uploadFile(file, isVideo ? 'video' : 'image');
    }
  }

  /// 拍摄照片
  Future<void> _capturePhoto() async {
    final hasPermission = await PermissionHelper.ensureCameraPermission(
      context,
    );
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
      _files.add(file);
      _fileTypes.add('image');
    });
    _uploadFile(file, 'image');
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
      _files.add(file);
      _fileTypes.add('video');
    });
    _uploadFile(file, 'video');
  }

  Future<void> _uploadFile(File file, String fileType) async {
    final index = _files.indexOf(file);
    if (index == -1) return;
    if (!mounted) return;
    setState(() => _progress[index] = 0);
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final url = await _taskService.uploadReportFile(
        file: file,
        fileName: fileName,
        type: fileType == 'image' ? 1 : 3,
        onSendProgress: (sent, total) {
          if (total > 0 && mounted) {
            setState(() => _progress[index] = sent / total);
          }
        },
      );
      if (!mounted) return;
      setState(() {
        _uploadedUrls.add(url);
        _progress[index] = 1.0;
      });
      _notifyUploading();
      _notify();
    } catch (_) {
      if (mounted) setState(() => _progress[index] = -1);
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _files.removeAt(index);
      if (index < _fileTypes.length) _fileTypes.removeAt(index);
      if (index < _uploadedUrls.length) _uploadedUrls.removeAt(index);
      _progress.remove(index);
      final newProgress = <int, double>{};
      for (var entry in _progress.entries) {
        final key = entry.key < index ? entry.key : entry.key - 1;
        newProgress[key] = entry.value;
      }
      _progress = newProgress;
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
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
                onTap: _files.length < maxMediaFiles ? _pickMedia : null,
                child: Text(
                  '添加',
                  style: TextStyle(
                    color: _files.length < maxMediaFiles
                        ? Color(0xFF0073FF)
                        : Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (_files.isEmpty)
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                margin: EdgeInsets.only(top: 12),
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Color(0xFFDDDDDD)),
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
                  ...List.generate(
                    _files.length,
                    (i) => _buildItem(_files[i], i),
                  ),
                  if (_files.length < maxMediaFiles)
                    GestureDetector(
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
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.grey[500],
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${_files.length}/$maxMediaFiles',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
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
      ),
    );
  }

  Widget _buildItem(File file, int index) {
    final isVideo = _fileTypes.length > index && _fileTypes[index] == 'video';
    final progress = _progress[index];
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
        if (isFailed)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: GestureDetector(
                onTap: () => _uploadFile(file, isVideo ? 'video' : 'image'),
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
}

/// 附件上传区域
/// 调用方通过 [onAttachmentChanged] 获取已上传成功的文件 ID 列表
class ReportAttachmentSection extends StatefulWidget {
  final ValueChanged<List<int>>? onAttachmentChanged;
  final ValueChanged<bool>? onUploadingChanged;

  const ReportAttachmentSection({
    super.key,
    this.onAttachmentChanged,
    this.onUploadingChanged,
  });

  @override
  State<ReportAttachmentSection> createState() =>
      _ReportAttachmentSectionState();
}

class _ReportAttachmentSectionState extends State<ReportAttachmentSection> {
  final TaskService _taskService = TaskService();
  List<File> _files = [];
  Map<int, double> _progress = {};
  List<String> _uploadedUrls = [];

  List<int> get _uploadedIds =>
      _uploadedUrls.map((url) => int.tryParse(url)).whereType<int>().toList();

  void _notify() => widget.onAttachmentChanged?.call(_uploadedIds);

  bool get _hasPendingUploads => _progress.values.any((p) => p >= 0 && p < 1.0);

  void _notifyUploading() =>
      widget.onUploadingChanged?.call(_hasPendingUploads);

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (!mounted) return;
    if (result == null || result.files.isEmpty) return;
    for (final pf in result.files) {
      if (pf.path == null) continue;
      final file = File(pf.path!);
      if (!mounted) return;
      setState(() => _files.add(file));
      _uploadFile(file);
    }
  }

  Future<void> _uploadFile(File file) async {
    final index = _files.indexOf(file);
    if (index == -1) return;
    if (!mounted) return;
    setState(() => _progress[index] = 0);
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final url = await _taskService.uploadReportFile(
        file: file,
        fileName: fileName,
        type: 2,
        onSendProgress: (sent, total) {
          if (total > 0 && mounted)
            setState(() => _progress[index] = sent / total);
        },
      );
      if (!mounted) return;
      setState(() {
        _uploadedUrls.add(url);
        _progress[index] = 1.0;
      });
      _notifyUploading();
      _notify();
    } catch (_) {
      if (mounted) setState(() => _progress[index] = -1);
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _files.removeAt(index);
      if (index < _uploadedUrls.length) _uploadedUrls.removeAt(index);
      _progress.remove(index);
      final newProgress = <int, double>{};
      for (var entry in _progress.entries) {
        final key = entry.key < index ? entry.key : entry.key - 1;
        newProgress[key] = entry.value;
      }
      _progress = newProgress;
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
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
              ...List.generate(_files.length, (i) => _buildItem(i)),
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

  Widget _buildItem(int index) {
    final fileName = _files[index].path.split(Platform.pathSeparator).last;
    final progress = _progress[index];
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
                GestureDetector(
                  onTap: () => _uploadFile(_files[index]),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 14, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        Text(
                          '上传失败，点击重试',
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
}

/// 备注输入区域
class ReportRemarkSection extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;
  final int? maxLines;
  final int minLines;

  const ReportRemarkSection({
    super.key,
    required this.controller,
    this.readOnly = false,
    this.maxLines = 3,
    this.minLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
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
                Icon(Icons.notes, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                const Text('备注', style: TextStyle(color: Color(0xFF010101))),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: readOnly ? null : maxLines,
              minLines: readOnly ? 1 : minLines,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              decoration: InputDecoration(
                hintText: '请输入备注',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Color(0xFF0073FF)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 预计完成时间选择区域
class ReportExpectedCompletionSection extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String? initialDate;

  const ReportExpectedCompletionSection({
    super.key,
    this.onChanged,
    this.initialDate,
  });

  @override
  State<ReportExpectedCompletionSection> createState() =>
      _ReportExpectedCompletionSectionState();
}

class _ReportExpectedCompletionSectionState
    extends State<ReportExpectedCompletionSection> {
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      locale: const Locale('zh'),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _selectedDate = formatted);
      widget.onChanged?.call(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            const Text('预计完成时间', style: TextStyle(color: Color(0xFF010101))),
            const Spacer(),
            Text(
              _selectedDate ?? '请选择',
              style: TextStyle(
                fontSize: 14,
                color: _selectedDate != null ? Colors.black : Colors.grey[400],
              ),
            ),
            if (_selectedDate != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = null);
                  widget.onChanged?.call('');
                },
                child: Icon(Icons.close, color: Colors.grey[400], size: 18),
              ),
            ] else
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
