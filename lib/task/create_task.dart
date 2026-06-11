import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/task/correlation_order.dart';
import 'package:flutter_application_1/task/cycle_task_explain.dart';
import 'package:flutter_application_1/task/select_task_bottom.dart';
import 'package:flutter_application_1/task/set_cycle.dart';
import 'package:flutter_application_1/task/task_type.dart';
import 'package:flutter_application_1/home/toast_custom.dart';
import 'package:flutter_application_1/utils/form_widgets.dart';
import 'package:flutter_application_1/utils/video_thumbnail.dart';

import '../commom/company_selection_page.dart';
import '../models/company_selection.dart';
import '../models/task.dart';
import '../services/task_service.dart';

import 'package:get/get.dart';
import 'package:flutter_application_1/store/task_controller.dart';

import '../utils/cors_image.dart';
import '../utils/dialog_custom.dart';
import '../utils/permission_helper.dart';
import '../index.dart';

class CreateTask extends StatefulWidget {
  final String? wherePage;
  final Task? initTask;
  final ValueChanged<dynamic>? onTaskCreated;

  const CreateTask({
    super.key,
    this.wherePage,
    this.initTask,
    this.onTaskCreated,
  });

  @override
  State<CreateTask> createState() => CreateTaskState();
}

class CreateTaskState extends State<CreateTask> {
  // 表单输入控制器
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskContentController = TextEditingController();
  // 动态联络电话列表
  List<TextEditingController> _phoneControllers = [TextEditingController()];
  // 动态地址列表
  List<TextEditingController> _addressControllers = [TextEditingController()];
  final TextEditingController companyController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  // 日期选择器状态
  DateTime? startDate;
  DateTime? endDate;
  // 选择状态
  String taskType = '临时任务';
  String setCycle = '每天';
  String? selectedProject;

  // 负责人相关
  List<SelectedPerson> selectedPrincipals = [];
  // 抄送相关
  List<SelectedPerson> selectedCcPersons = [];

  // 图片/视频上传
  List<File> _mediaFiles = [];
  List<String> _uploadedUrls = [];
  List<String> _mediaFileTypes = []; // 'image' or 'video'
  // 每个文件的上传进度：null=未开始, 0.0~1.0=上传中, 1.0=成功, -1=失败
  Map<int, double> _mediaProgress = {};

  // 编辑模式下已有的附件（服务端返回的）
  List<Attachment> _existingAttachments = [];

  // 附件上传
  List<File> _attachmentFiles = [];
  List<String> _uploadedAttachmentUrls = [];
  Map<int, double> _attachmentProgress = {};

  // 任务编号
  final TaskService _taskService = TaskService();
  String _taskNumber = '获取中...';
  String get taskNo => _taskNumber;

  // 所属公司
  List<Map<String, dynamic>> _companyList = [];
  String? _selectedCompanyId;
  String? _selectedCompanyName;

  // 从 TaskController 获取当前任务
  late TaskController _taskController;

  bool get _isEdit => widget.initTask != null;
  List<Attachment> get _existingImages =>
      _existingAttachments.where((a) => a.isImage).toList();
  List<Attachment> get _existingFiles =>
      _existingAttachments.where((a) => !a.isImage).toList();

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    if (_isEdit) {
      _fillFormWithTask(widget.initTask!);
    } else {
      _fetchTaskNumber();
    }
    _fetchCompanies();
  }

  void _fillFormWithTask(Task task) {
    _taskNumber = task.taskNo;
    taskNameController.text = task.taskName;
    taskContentController.text = task.taskContent ?? '';

    // 日期
    if (task.startTime != null) {
      startDate = DateTime.tryParse(task.startTime!);
    }
    if (task.endTime != null) {
      endDate = DateTime.tryParse(task.endTime!);
    }

    // 任务类型
    final typeMap = {
      3: '临时任务',
      4: '周期任务',
      5: '周期任务',
      6: '周期任务',
      7: '会议任务',
      8: '外派任务',
    };
    taskType = typeMap[task.taskType] ?? '临时任务';

    // 周期
    if (task.cycleConfig != null) {
      try {
        final cycle = _parseCycleConfig(task.cycleConfig!);
        if (cycle['cycleType'] == 'daily') {
          setCycle = '每天';
        } else if (cycle['cycleType'] == 'weekly') {
          final dayNames = {
            '1': '周一',
            '2': '周二',
            '3': '周三',
            '4': '周四',
            '5': '周五',
            '6': '周六',
            '7': '周日',
          };
          final days = (cycle['weeklyDays'] as List? ?? [])
              .map((d) => dayNames[d.toString()] ?? '')
              .where((s) => s.isNotEmpty)
              .join('、');
          setCycle = '每周$days';
        } else if (cycle['cycleType'] == 'monthly') {
          final days = (cycle['monthlyDays'] as List? ?? []).join('、');
          setCycle = '每月${days}号';
        }
      } catch (_) {}
    }

    // 负责人/抄送
    selectedPrincipals = task.principalsList
        .map(
          (name) => SelectedPerson(
            realName: name,
            userId: '',
            departmentName: '',
            departmentId: '',
            companyName: '',
            companyId: '',
          ),
        )
        .toList();
    selectedCcPersons = task.ccPersonsList
        .map(
          (name) => SelectedPerson(
            realName: name,
            userId: '',
            departmentName: '',
            departmentId: '',
            companyName: '',
            companyId: '',
          ),
        )
        .toList();

    // 所属公司
    _selectedCompanyId = task.companyId;
    _selectedCompanyName = task.companyName;
    companyController.text = task.companyName;

    // 联络人/电话/地址
    contactController.text = task.contactPerson ?? '';
    if (task.contactPhonesList.isNotEmpty) {
      _phoneControllers = task.contactPhonesList
          .map((p) => TextEditingController(text: p))
          .toList();
    }
    if (task.contactAddressesList.isNotEmpty) {
      _addressControllers = task.contactAddressesList
          .map((a) => TextEditingController(text: a))
          .toList();
    }

    // 关联项目
    selectedProject = task.relatedProjectOrder;

    // 已有附件
    if (task.attachments != null) {
      _existingAttachments = task.attachments!;
      for (final att in _existingAttachments) {
        if (att.isImage) {
          _uploadedUrls.add(att.id.toString());
          _mediaFileTypes.add('image');
        } else {
          _uploadedAttachmentUrls.add(att.id.toString());
        }
      }
    }
  }

  Map<String, dynamic> _parseCycleConfig(String raw) {
    try {
      return Map<String, dynamic>.from((jsonDecode(raw) as Map));
    } catch (_) {
      return {};
    }
  }

  @override
  void dispose() {
    for (var c in _phoneControllers) {
      c.dispose();
    }
    for (var c in _addressControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ============ 联络电话 ============

  void _addPhoneField() {
    setState(() {
      _phoneControllers.add(TextEditingController());
    });
  }

  void _removePhoneField(int index) {
    setState(() {
      _phoneControllers[index].dispose();
      _phoneControllers.removeAt(index);
    });
  }

  Widget _buildPhoneList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.phone, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('联络电话')),
              GestureDetector(
                onTap: _addPhoneField,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF208BDE)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Color(0xFF208BDE)),
                      SizedBox(width: 2),
                      Text(
                        '新增',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF208BDE),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(_phoneControllers.length, (index) {
          return Container(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneControllers[index],
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: index == 0 ? '请输入联络电话' : '请输入联络电话${index + 1}',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 24,
                        bottom: 12,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 0.5),
                      ),
                    ),
                  ),
                ),
                if (_phoneControllers.length > 1)
                  GestureDetector(
                    onTap: () => _removePhoneField(index),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ============ 地址 ============

  void _addAddressField() {
    setState(() {
      _addressControllers.add(TextEditingController());
    });
  }

  void _removeAddressField(int index) {
    setState(() {
      _addressControllers[index].dispose();
      _addressControllers.removeAt(index);
    });
  }

  Widget _buildAddressList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('添加地址')),
              GestureDetector(
                onTap: _addAddressField,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF208BDE)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Color(0xFF208BDE)),
                      SizedBox(width: 2),
                      Text(
                        '新增',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF208BDE),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(_addressControllers.length, (index) {
          return Container(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressControllers[index],
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: index == 0 ? '请输入地址' : '请输入地址${index + 1}',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 24,
                        bottom: 12,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 0.5),
                      ),
                    ),
                  ),
                ),
                if (_addressControllers.length > 1)
                  GestureDetector(
                    onTap: () => _removeAddressField(index),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ============ 任务编号 ============

  Future<void> _fetchTaskNumber() async {
    try {
      final number = await _taskService.generateTaskNumber();
      setState(() {
        _taskNumber = number;
      });
    } catch (e) {
      setState(() {
        _taskNumber = '自动生成';
      });
    }
  }

  // ============ 所属公司 ============

  Future<void> _fetchCompanies() async {
    try {
      final companies = await _taskService.fetchCompanies();
      setState(() {
        _companyList = companies;
      });
    } catch (e) {
      // 公司列表加载失败，使用空列表
    }
  }

  void _showCompanyPicker() {
    final textController = TextEditingController();
    String searchText = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _companyList.where((c) {
              final name = (c['company'] ?? '').toString().toLowerCase();
              return name.contains(searchText.toLowerCase());
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Text(
                            '取消',
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                          ),
                        ),
                        const Text(
                          '选择所属公司',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF208BDE,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_companyList.length}家',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF208BDE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: textController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '搜索公司名称',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        suffixIcon: searchText.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  textController.clear();
                                  setModalState(() => searchText = '');
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.grey[300],
                                  size: 18,
                                ),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => setModalState(() => searchText = v),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.business_outlined,
                                  size: 48,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  searchText.isNotEmpty ? '无匹配公司' : '暂无数据',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              indent: 16,
                              color: Colors.grey[100],
                            ),
                            itemBuilder: (context, index) {
                              final company = filtered[index];
                              final companyName = company['company'] ?? '';
                              final isSelected =
                                  _selectedCompanyId ==
                                  company['id'].toString();
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCompanyId = company['id']
                                        .toString();
                                    _selectedCompanyName = company['company'];
                                  });
                                  Navigator.pop(ctx);
                                },
                                child: Container(
                                  color: isSelected
                                      ? const Color(
                                          0xFF208BDE,
                                        ).withValues(alpha: 0.06)
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(
                                                  0xFF208BDE,
                                                ).withValues(alpha: 0.1)
                                              : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.business,
                                          size: 20,
                                          color: isSelected
                                              ? const Color(0xFF208BDE)
                                              : Colors.grey[400],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          companyName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? const Color(0xFF208BDE)
                                                : const Color(0xFF333333),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF208BDE),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============ 图片/视频上传 ============

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
    setState(() {
      _mediaProgress[index] = 0.0;
    });
    try {
      final url = await _taskService.uploadFile(
        file: file,
        taskNo: _taskNumber,
        fileType: fileType,
        onSendProgress: (sent, total) {
          if (total > 0) {
            setState(() {
              _mediaProgress[index] = sent / total;
            });
          }
        },
      );
      setState(() {
        _uploadedUrls.add(url);
        _mediaProgress[index] = 1.0;
      });
    } catch (e) {
      setState(() {
        _mediaProgress[index] = -1;
      });
    }
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
          if (_mediaFiles.isEmpty && _existingImages.isEmpty)
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
                  ..._existingImages.map((img) => _buildExistingImageItem(img)),
                  ...List.generate(_mediaFiles.length, (index) {
                    return _buildMediaItem(_mediaFiles[index], index);
                  }),
                  if (_existingImages.length + _mediaFiles.length < 9)
                    _buildAddMediaButtons(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExistingImageItem(Attachment img) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 80,
            height: 80,
            child: CorsImage(
              url: img.filePath,
              fit: BoxFit.cover,
              errorWidget: Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 32,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                final idx = _uploadedUrls.indexOf(img.id.toString());
                if (idx != -1) {
                  _uploadedUrls.removeAt(idx);
                  _mediaFileTypes.removeAt(idx);
                }
                _existingAttachments.remove(img);
              });
            },
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
            top: 0,
            right: 0,
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

  // ============ 附件上传 ============

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _attachmentFiles.add(file);
      });
      _uploadAttachmentFile(file);
    }
  }

  Future<void> _uploadAttachmentFile(File file) async {
    final index = _attachmentFiles.indexOf(file);
    if (index == -1) return;
    setState(() {
      _attachmentProgress[index] = 0.0;
    });
    try {
      final url = await _taskService.uploadAttachment(
        file: file,
        taskNo: _taskNumber,
        onSendProgress: (sent, total) {
          if (total > 0) {
            setState(() {
              _attachmentProgress[index] = sent / total;
            });
          }
        },
      );
      setState(() {
        _uploadedAttachmentUrls.add(url);
        _attachmentProgress[index] = 1.0;
      });
    } catch (e) {
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
              ..._existingFiles.map((file) => _buildExistingFileItem(file)),
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

  Widget _buildExistingFileItem(Attachment file) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            file.fileNameOriginal,
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _uploadedAttachmentUrls.remove(file.id.toString());
                _existingAttachments.remove(file);
              });
            },
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
        ],
      ),
    );
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
                    onTap: () => _uploadAttachmentFile(_attachmentFiles[index]),
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

  // ============ 校验 ============

  bool validateFields() {
    if (taskNameController.text.trim().isEmpty) {
      ToastCustom.showToast(context, '提示', '请填写任务名称');
      return false;
    }
    if (startDate == null) {
      ToastCustom.showToast(context, '提示', '请选择计划开始时间');
      return false;
    }
    if (endDate == null) {
      ToastCustom.showToast(context, '提示', '请选择计划结束时间');
      return false;
    }
    if (selectedPrincipals.isEmpty) {
      ToastCustom.showToast(context, '提示', '请选择负责人');
      return false;
    }
    if (_selectedCompanyId == null || _selectedCompanyId!.isEmpty) {
      ToastCustom.showToast(context, '提示', '请选择所属公司');
      return false;
    }
    return true;
  }

  void printFormData() {
    print('======= 表单内容 =======');
    print('任务名称: ${taskNameController.text}');
    print('任务内容: ${taskContentController.text}');
    print('单据编号: $_taskNumber');
    print('任务类型: $taskType');
    print('所属公司: ${_selectedCompanyName ?? '无'}');
    if (taskType == '周期任务') {
      print('设置周期: $setCycle');
    }
    print('计划开始时间: $startDate');
    print('计划结束时间: $endDate');
    print('负责人: ${selectedPrincipals.map((p) => p.realName).join(', ')}');
    print('抄送: ${selectedCcPersons.map((p) => p.realName).join(', ')}');
    print('关联企业: ${companyController.text}');
    print('关联项目/订单: ${selectedProject ?? '无'}');
    print('联络人: ${contactController.text}');
    for (int i = 0; i < _phoneControllers.length; i++) {
      print('联络电话${i + 1}: ${_phoneControllers[i].text}');
    }
    for (int i = 0; i < _addressControllers.length; i++) {
      print('地址${i + 1}: ${_addressControllers[i].text}');
    }
    print('图片/视频数量: ${_mediaFiles.length}');
    print('附件数量: ${_attachmentFiles.length}');
    print('=======================');
  }

  // ============ 提交任务 ============

  Future<void> submitTask() async {
    if (!validateFields()) return;
    // 检查是否有未上传完成的文件
    final hasUploading =
        _mediaProgress.values.any((p) => p >= 0 && p < 1) ||
        _attachmentProgress.values.any((p) => p >= 0 && p < 1);
    if (hasUploading) {
      ToastCustom.showToast(context, '提示', '请等待文件上传完成');
      return;
    }

    // 任务类型映射: 3-临时, 4-周期(按日), 5-周期(按周), 6-周期(按月), 7-会议, 8-外派
    String taskTypeValue;
    if (taskType == '临时任务') {
      taskTypeValue = '3';
    } else if (taskType == '周期任务') {
      if (setCycle == '每天') {
        taskTypeValue = '4';
      } else if (setCycle.startsWith('每周')) {
        taskTypeValue = '5';
      } else {
        taskTypeValue = '6';
      }
    } else if (taskType == '会议任务') {
      taskTypeValue = '7';
    } else if (taskType == '外派任务') {
      taskTypeValue = '8';
    } else {
      taskTypeValue = '3';
    }

    // 时间格式化
    final fmt = (DateTime dt) =>
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    final fmtTime = (DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';

    // 区分图片和视频ID
    final imageIds = <int>[];
    final videoIds = <int>[];
    for (int i = 0; i < _uploadedUrls.length; i++) {
      final id = int.tryParse(_uploadedUrls[i]);
      if (id == null) continue;
      if (i < _mediaFileTypes.length && _mediaFileTypes[i] == 'video') {
        videoIds.add(id);
      } else {
        imageIds.add(id);
      }
    }

    // 附件ID
    final attachmentIds = _uploadedAttachmentUrls
        .map((url) => int.tryParse(url))
        .whereType<int>()
        .toList();

    final data = <String, dynamic>{
      'taskNo': _taskNumber,
      'taskType': taskTypeValue,
      'companyId': int.tryParse(_selectedCompanyId ?? '') ?? _selectedCompanyId,
      'taskContent': taskContentController.text.trim(),
      'taskName': taskNameController.text.trim(),
      'startTime': const ['4', '5', '6'].contains(taskTypeValue)
          ? null
          : fmt(startDate!),
      'endTime': const ['4', '5', '6'].contains(taskTypeValue)
          ? null
          : fmt(endDate!),
      'principals': selectedPrincipals.map((p) => p.realName).toList(),
      'ccPersons': selectedCcPersons.map((p) => p.realName).toList(),
      'relatedCompanies': companyController.text.trim(),
      'relatedProjectOrder': selectedProject ?? '',
      'contactPerson': contactController.text.trim(),
      'contactPhones': _phoneControllers
          .map((c) => c.text.trim())
          .where((p) => p.isNotEmpty)
          .toList(),
      'contactAddresses': _addressControllers
          .map((c) => c.text.trim())
          .where((a) => a.isNotEmpty)
          .toList(),
      'imageIds': imageIds,
      'videoIds': videoIds,
      'attachmentIds': attachmentIds,
      'save': true,
      if (_isEdit) 'id': widget.initTask!.id,
    };

    // 周期任务添加 cycleConfig
    if (taskType == '周期任务') {
      String cycleType;
      List<String> weeklyDays = [];
      List<String> monthlyDays = [];

      if (setCycle == '每天') {
        cycleType = 'daily';
      } else if (setCycle.startsWith('每周')) {
        cycleType = 'weekly';
        const weekDayMap = {
          '周一': '1',
          '周二': '2',
          '周三': '3',
          '周四': '4',
          '周五': '5',
          '周六': '6',
          '周日': '7',
        };
        final dayStr = setCycle.replaceAll('每周', '');
        for (var entry in weekDayMap.entries) {
          if (dayStr.contains(entry.key)) weeklyDays.add(entry.value);
        }
      } else if (setCycle.startsWith('每月')) {
        cycleType = 'monthly';
        final dayStr = setCycle.replaceAll('每月', '').replaceAll('号', '');
        monthlyDays = dayStr.split('、').where((s) => s.isNotEmpty).toList();
      } else {
        cycleType = 'daily';
      }

      data['cycleConfig'] =
          '{"cycleType":"$cycleType","weeklyDays":${_encodeList(weeklyDays)},"monthlyDays":${_encodeList(monthlyDays)},"startTime":"${fmtTime(startDate!)}","endTime":"${fmtTime(endDate!)}"}';
    }

    print('======= 创建任务 请求参数 =======');
    data.forEach((k, v) => print('  $k: $v'));
    print('==================================');

    try {
      final result = await _taskService.createTask(data);
      if (widget.wherePage == 'report') {
        widget.onTaskCreated?.call(result);
      } else {
        _showSuccessDialog();
      }
    } on Exception catch (e) {
      final msg = "系统异常，请稍后再试";
      _showErrorDialog(msg);
    } catch (e) {
      _showErrorDialog('网络连接异常，请检查网络后重试');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => DialogCustom(
        title: '任务创建失败',
        description: message,
        icon: Icons.close,
        iconColor: Color(0xFFFF4D4F),
        leftButtonText: '取消',
        rightButtonText: '重试',
        onLeftButtonPressed: () {
          Navigator.pop(context);
        },
        onRightButtonPressed: () {
          Navigator.pop(context);
          submitTask();
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DialogCustom(
        title: '任务创建成功',
        description: '您可以在任务列表查看创建的任务',
        icon: Icons.check,
        iconColor: Color(0xFF52C41A),
        leftButtonText: '关闭',
        rightButtonText: '去列表查看',
        onLeftButtonPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onRightButtonPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Index.switchToTab(1);
        },
      ),
    );
  }

  static String _encodeList(List<String> list) {
    return '[${list.map((e) => '"$e"').join(',')}]';
  }

  // ============ Build ============

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(color: Color(0xFFEEF0F2), height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // 任务名称
                Stack(
                  children: [
                    FormWidgets.buildInputItem(
                      '任务名称',
                      true,
                      taskNameController,
                      Icons.title,
                    ),
                    if (widget.wherePage == 'report')
                      Positioned(
                        right: 0,
                        top: 0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            minimumSize: const Size(0, 28),
                          ),
                          onPressed: () => {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (cotext) {
                                return SelectTaskBottom(
                                  onTaskSelected: (int index) {
                                    // 设置当前任务
                                    _taskController.setCurrentTask(
                                      _taskController.allTasks[index],
                                    );
                                  },
                                );
                              },
                            ),
                          },
                          child: const Text(
                            '选择',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                // 任务内容
                FormWidgets.buildInputItem(
                  '任务内容',
                  false,
                  taskContentController,
                  Icons.description,
                ),
                // 单据编号
                FormWidgets.buildReadOnlyItem(
                  '单据编号',
                  false,
                  _taskNumber,
                  Icons.request_quote,
                ),
                // 所属公司
                FormWidgets.buildReadOnlyItem(
                  '所属公司',
                  true,
                  _selectedCompanyName ?? '请选择',
                  Icons.business,
                  onTap: _showCompanyPicker,
                ),
                // 任务类型
                FormWidgets.buildReadOnlyItem(
                  '任务类型',
                  true,
                  taskType,
                  Icons.category,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (cotext) {
                      return TaskType((index) {
                        setState(() {
                          taskType = ['周期任务', '临时任务', '外派任务', '会议任务'][index];
                          if (taskType == '周期任务') {
                            final now = DateTime.now();
                            startDate = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              9,
                              0,
                              0,
                            );
                            endDate = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              18,
                              0,
                              0,
                            );
                          } else {
                            startDate = null;
                            endDate = null;
                          }
                        });
                        if (index == 0) _showDialog();
                      }, initialValue: taskType);
                    },
                  ),
                ),
                if (taskType == '周期任务')
                  FormWidgets.buildReadOnlyItem(
                    '设置周期',
                    true,
                    setCycle,
                    Icons.alarm,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (cotext) {
                        return SetCycle(
                          initialValue: setCycle,
                          onConfirm: (result) {
                            setState(() {
                              setCycle = result;
                            });
                          },
                        );
                      },
                    ),
                  ),
                // 计划开始时间
                FormWidgets.buildDateItem(
                  context,
                  '计划开始时间',
                  true,
                  startDate,
                  Icons.access_time,
                  timeOnly: taskType == '周期任务',
                  onPressed: (selectedDateTime) {
                    setState(() {
                      startDate = selectedDateTime;
                    });
                    Navigator.pop(context);
                    return null;
                  },
                ),
                // 计划结束时间
                FormWidgets.buildDateItem(
                  context,
                  '计划结束时间',
                  true,
                  endDate,
                  Icons.event,
                  timeOnly: taskType == '周期任务',
                  onPressed: (selectedDateTime) {
                    setState(() {
                      endDate = selectedDateTime;
                    });
                    Navigator.pop(context);
                    return null;
                  },
                ),
                // 负责人
                FormWidgets.buildReadOnlyItem(
                  '负责人',
                  true,
                  selectedPrincipals.isEmpty
                      ? ''
                      : selectedPrincipals.map((p) => p.realName).join(', '),
                  Icons.person,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                    ),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    builder: (cotext) {
                      return CompanySelectionPage(
                        initialSelections: selectedPrincipals,
                        onConfirm: (selectedPersons) {
                          setState(() {
                            selectedPrincipals = selectedPersons;
                          });
                        },
                      );
                    },
                  ),
                ),
                // 抄送
                FormWidgets.buildReadOnlyItem(
                  '抄送',
                  false,
                  selectedCcPersons.isEmpty
                      ? ''
                      : selectedCcPersons.map((p) => p.realName).join(', '),
                  Icons.mail,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                    ),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    builder: (cotext) {
                      return CompanySelectionPage(
                        title: '选择抄送人',
                        initialSelections: selectedCcPersons,
                        onConfirm: (selectedPersons) {
                          setState(() {
                            selectedCcPersons = selectedPersons;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(color: Color(0xFFEEF0F2), height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // 关联企业
                FormWidgets.buildInputItem(
                  '关联企业',
                  false,
                  companyController,
                  Icons.business,
                ),
                // 关联项目/订单
                FormWidgets.buildReadOnlyItem(
                  '关联项目/订单',
                  false,
                  selectedProject ?? '',
                  Icons.assignment,
                  onTap: () {
                    if (_selectedCompanyId == null ||
                        _selectedCompanyId!.isEmpty) {
                      ToastCustom.showToast(context, '提示', '请先选择所属公司');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CorrelationOrder(companyId: _selectedCompanyId!),
                      ),
                    ).then((result) {
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          selectedProject =
                              result['billNo']?.toString() ??
                              result['projectNo']?.toString() ??
                              '';
                        });
                      }
                    });
                  },
                ),
                // 联络人
                FormWidgets.buildInputItem(
                  '联络人',
                  false,
                  contactController,
                  Icons.contact_page,
                ),
                // 联络电话
                _buildPhoneList(),
                // 添加地址
                _buildAddressList(),
                // 图片/视频上传
                _buildMediaSection(),
                // 附件上传
                _buildAttachmentSection(),
              ],
            ),
          ),
          Container(color: Color(0xFFEEF0F2), height: 10),
        ],
      ),
    );
  }

  Future<dynamic> _showDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CycleTaskExplain();
      },
    );
  }
}
