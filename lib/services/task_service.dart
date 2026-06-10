import 'dart:io';

import 'package:dio/dio.dart';

import '../utils/top_notification.dart';
import '../core/navigator_key.dart';
import '../config/api_config.dart';
import '../core/http_client.dart';
import '../models/task.dart';

class TaskService {
  final HttpClient _httpClient = HttpClient();
  Future<TaskListResult> fetchTaskList({
    String? statusTab,
    int? taskType,
    String? styleCode,
    String? billNo,
    String? taskNo,
    String? taskName,
    String? startTime,
    String? endTime,
    String? operator,
    String? operator1,
    int currentPage = 1,
    int pageSize = 20,
    String? sortField,
    String? sortOrder,
  }) async {
    final data = <String, dynamic>{
      'currentPage': currentPage,
      'pageSize': pageSize,
      'statusTab': statusTab == 'all' ? '' : statusTab,
      'taskType': taskType,
      'styleCode': styleCode,
      'billNo': billNo,
      'taskNo': taskNo,
      'taskName': taskName,
      'startTime': startTime,
      'endTime1': endTime,
      'operator': operator,
      'operator1': operator1,
      'sortField': sortField,
      'sortOrder': sortOrder,
    };
    data.removeWhere((_, v) => v == null || (v is String && v.isEmpty));

    final response = await _httpClient.post(ApiConfig.taskList, data: data);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return TaskListResult.fromJson(data['result'] as Map<String, dynamic>);
      } else {
        if (navigatorKey.currentContext != null) {
          TopNotification.error(
            navigatorKey.currentContext!,
            data['errorMsg'] ?? '获取任务列表失败',
          );
        }
      }
    }
    return TaskListResult(
      records: [],
      page: PageInfo(total: 0, size: pageSize, current: currentPage, pages: 0),
      totalCount: 0,
      pendingCount: 0,
      completedCount: 0,
      cancelledCount: 0,
      overtimeCount: 0,
    );
  }

  /// 获取任务详情
  Future<Task?> fetchTaskDetail(int taskId) async {
    return _fetchTaskDetail({'taskId': taskId});
  }

  /// 根据任务编号获取任务详情
  Future<Task?> fetchTaskDetailByTaskNo(String taskNo) async {
    return _fetchTaskDetail({'taskNo': taskNo});
  }

  Future<Task?> _fetchTaskDetail(Map<String, dynamic> data) async {
    final response = await _httpClient.post(ApiConfig.taskDetail, data: data);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return Task.fromJson(data['result'] as Map<String, dynamic>);
      } else {
        if (navigatorKey.currentContext != null) {
          TopNotification.error(
            navigatorKey.currentContext!,
            data['errorMsg'] ?? '获取任务详情失败',
          );
        }
        return null;
      }
    }
    return null;
  }

  /// 作废任务
  Future<bool> cancelTask(int taskId) async {
    final response = await _httpClient.post(
      ApiConfig.taskCancel,
      data: {'taskId': taskId},
    );
    if (response.statusCode == 200) {
      final data = response.data;
      return data['code'] == true;
    }
    return false;
  }

  /// 获取汇报历史
  Future<List<ReportHistoryItem>> fetchReportHistory(String taskNo) async {
    final response = await _httpClient.post(
      ApiConfig.reportHistory,
      data: {'taskNo': taskNo},
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return (data['result'] as List<dynamic>)
            .map((e) => ReportHistoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// 下载附件
  Future<File> downloadAttachment(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    await _httpClient.downloadFile(
      url,
      savePath: savePath,
      onReceiveProgress: onReceiveProgress,
    );
    return File(savePath);

    // final response = await _httpClient.dio.get(
    //   url,
    //   onReceiveProgress: onReceiveProgress,
    //   options: Options(responseType: ResponseType.bytes),
    // );
    // final bytes = response.data as List<int>;
    // print('下载完成, 字节数: ${bytes.length}, 路径: $savePath');
    // final file = File(savePath);
    // await file.parent.create(recursive: true);
    // await file.writeAsBytes(bytes);
    // print('写入完成, 文件存在: ${await file.exists()}, 大小: ${await file.length()}');
    // return file;
  }

  /// 汇报上传文件（图片/附件）
  Future<String> uploadReportFile({
    required File file,
    required String fileName,
    required int type,
    ProgressCallback? onSendProgress,
  }) async {
    final response = await _httpClient.uploadFile(
      ApiConfig.reportUploadFile,
      file: file,
      data: {'fileName': fileName, 'type': type},
      onSendProgress: onSendProgress,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true) {
        final result = data['result'];
        if (result is Map && result.containsKey('id')) {
          return result['id'].toString();
        }
        return result?.toString() ?? '';
      }
      if (navigatorKey.currentContext != null) {
        TopNotification.error(
          navigatorKey.currentContext!,
          data['errorMsg'] ?? '上传失败',
        );
      }
    }
    throw Exception('上传失败');
  }

  /// 提交汇报，成功返回 result 中的 progress，失败返回 null
  Future<double?> submitReport(Map<String, dynamic> data) async {
    final response = await _httpClient.post(ApiConfig.reportDetail, data: data);
    if (response.statusCode == 200) {
      final resp = response.data;
      if (resp['code'] == true) {
        final result = resp['result'];
        if (result is Map) {
          return (result['progress'] as num?)?.toDouble();
        }
        return 0;
      }
    }
    return null;
  }

  /// 检查前道工序进度
  Future<PreTaskCheckResult> checkPreTaskReport({
    required String billNo,
    required int progress,
    required int taskId,
  }) async {
    final response = await _httpClient.post(
      ApiConfig.checkPreTaskReport,
      data: {'billNo': billNo, 'progress': progress, 'taskId': taskId},
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return PreTaskCheckResult.fromJson(data['result']);
      }
    }
    throw Exception('检查前道工序失败');
  }

  /// 保存暂存汇报（前道工序未完成时）
  Future<String> savePendingReport(Map<String, dynamic> data) async {
    final response = await _httpClient.post(
      ApiConfig.savePendingReport,
      data: data,
    );
    if (response.statusCode == 200) {
      final respData = response.data;
      if (respData['code'] == true) {
        return respData['result']?.toString() ?? '汇报数据已暂存';
      }
    }
    throw Exception('暂存汇报失败');
  }

  /// 获取任务编号
  Future<String> generateTaskNumber() async {
    final response = await _httpClient.get(ApiConfig.generateTaskNumber);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return data['result'].toString();
      } else {
        throw Exception(data['errorMsg'] ?? '获取任务编号失败');
      }
    } else {
      throw Exception('服务器异常 (${response.statusCode})');
    }
  }

  /// 获取所属公司列表
  Future<List<Map<String, dynamic>>> fetchCompanies() async {
    final response = await _httpClient.post(
      ApiConfig.selectCompany,
      data: {'pageSize': 100, 'current': 1, 'company': ''},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        final records = data['result']['records'] as List<dynamic>?;
        return records?.cast<Map<String, dynamic>>() ?? [];
      } else {
        throw Exception(data['errorMsg'] ?? '获取公司列表失败');
      }
    } else {
      throw Exception('服务器异常 (${response.statusCode})');
    }
  }

  /// 获取订单列表
  Future<Map<String, dynamic>> fetchOrderList({
    String? styleCode,
    String? custIdName,
    String? salerIdName,
    String? planDate,
    String? billNo,
    String? orderState,
    String? styleName,
    String? predictPlanDate,
    int current = 1,
    int pageSize = 20,
    String? operator,
  }) async {
    final data = <String, dynamic>{
      'current': current,
      'pageSize': pageSize,
      'styleCode': styleCode,
      'custIdName': custIdName,
      'salerIdName': salerIdName,
      'planDate': planDate,
      'billNo': billNo,
      'orderState': orderState,
      'styleName': styleName,
      'predictPlanDate': predictPlanDate,
      'operator': operator,
    };
    data.removeWhere((_, v) => v == null || (v is String && v.isEmpty));

    print('======= fetchOrderList 实际请求参数 =======');
    data.forEach((k, v) => print('  $k: $v'));
    print('==========================================');

    final response = await _httpClient.post(
      ApiConfig.orderTaskPage,
      data: data,
    );

    if (response.statusCode == 200) {
      final respData = response.data;
      print(respData);
      if (respData['code'] == true && respData['result'] != null) {
        return respData['result'] as Map<String, dynamic>;
      }
    }
    return {'records': [], 'total': 0, 'current': 1, 'pages': 0};
  }

  /// 获取项目集列表
  Future<List<Map<String, dynamic>>> fetchProjectGroups({
    required String companyId,
  }) async {
    final response = await _httpClient.post(
      ApiConfig.projectGroupList,
      data: {
        'current': 1,
        'pageSize': 99999,
        'companyId': int.tryParse(companyId) ?? companyId,
      },
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        final records = data['result']['records'] as List<dynamic>?;
        return records?.cast<Map<String, dynamic>>() ?? [];
      }
    }
    return [];
  }

  /// 获取项目集下的项目列表
  Future<Map<String, dynamic>> fetchProjectTaskList({
    required int projectGroupId,
    String? projectNo,
    String? projectName,
    String? orderState,
    String? personInCharge,
    int currentPage = 1,
    int pageSize = 20,
  }) async {
    final data = <String, dynamic>{
      'projectGroupId': projectGroupId,
      'current': currentPage,
      'pageSize': pageSize,
      'operator': '等于',
      'projectNo': projectNo,
      'projectName': projectName,
      'orderState': orderState,
      'personInCharge': personInCharge,
    };
    data.removeWhere((_, v) => v == null || (v is String && v.isEmpty));

    print('======= 项目集项目列表 请求参数 =======');
    data.forEach((k, v) => print('  $k: $v'));
    print('======================================');

    final response = await _httpClient.post(
      ApiConfig.projectTaskOrderPage,
      data: data,
    );
    if (response.statusCode == 200) {
      final respData = response.data;
      print('======= 项目集项目列表 返回 =======');
      print('  data: $respData');
      print('===================================');
      if (respData['code'] == true && respData['result'] != null) {
        return respData['result'] as Map<String, dynamic>;
      }
    }
    return {'records': [], 'total': 0, 'current': 1, 'pages': 0};
  }

  /// 上传附件
  Future<String> uploadAttachment({
    required File file,
    required String taskNo,
    ProgressCallback? onSendProgress,
  }) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    print('======= 上传附件 请求参数 =======');
    print('  接口: ${ApiConfig.uploadFile}');
    print('  taskNo: $taskNo');
    print('  fileName: $fileName');
    print('  filePath: ${file.path}');
    print('================================');

    final response = await _httpClient.uploadFile(
      ApiConfig.uploadFile,
      file: file,
      data: {'taskNo': taskNo, 'fileName': fileName},
      onSendProgress: onSendProgress,
    );

    print('======= 上传附件 接口返回 =======');
    print('  statusCode: ${response.statusCode}');
    print('  data: ${response.data}');
    print('=================================');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true) {
        final result = data['result'];
        if (result is Map && result.containsKey('id')) {
          return result['id'].toString();
        }
        return result?.toString() ?? '';
      } else {
        throw Exception(data['errorMsg'] ?? '上传失败');
      }
    } else {
      throw Exception('服务器异常 (${response.statusCode})');
    }
  }

  /// 上传图片/视频/文件
  Future<String> uploadFile({
    required File file,
    required String taskNo,
    required String fileType,
    ProgressCallback? onSendProgress,
  }) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    print('======= 上传图片/视频 请求参数 =======');
    print('  接口: ${ApiConfig.uploadImage}');
    print('  taskNo: $taskNo');
    print('  fileName: $fileName');
    print('  fileType: $fileType');
    print('  filePath: ${file.path}');
    print('======================================');

    final response = await _httpClient.uploadFile(
      ApiConfig.uploadImage,
      file: file,
      data: {'taskNo': taskNo, 'fileName': fileName, 'fileType': fileType},
      onSendProgress: onSendProgress,
    );

    print('======= 上传图片/视频 接口返回 =======');
    print('  statusCode: ${response.statusCode}');
    print('  data: ${response.data}');
    print('======================================');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true) {
        final result = data['result'];
        if (result is Map && result.containsKey('id')) {
          return result['id'].toString();
        }
        return result?.toString() ?? '';
      } else {
        throw Exception(data['errorMsg'] ?? '上传失败');
      }
    } else {
      throw Exception('服务器异常 (${response.statusCode})');
    }
  }

  /// 创建任务
  Future<dynamic> createTask(Map<String, dynamic> data) async {
    final response = await _httpClient.post(ApiConfig.taskCreate, data: data);

    print('======= 创建任务 返回 =======');
    print('  statusCode: ${response.statusCode}');
    print('  data: ${response.data}');
    print('==============================');

    if (response.statusCode == 200) {
      final respData = response.data;
      if (respData['code'] == true) {
        return respData['result'];
      } else {
        throw Exception(respData['errorMsg'] ?? '创建任务失败');
      }
    } else {
      throw Exception('服务器异常 (${response.statusCode})');
    }
  }

  /// 获取工序类型列表
  Future<List<String>> fetchWorkTypes(int taskType) async {
    final response = await _httpClient.post(
      ApiConfig.getWorkType,
      data: {'taskType': taskType},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return (data['result'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
    }
    return [];
  }

  /// 获取客户名称列表
  Future<List<String>> fetchCustomerInfo(int taskType) async {
    final response = await _httpClient.post(
      ApiConfig.getCustomerInfo,
      data: {'taskType': taskType},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return (data['result'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
    }
    return [];
  }

  /// 获取其他任务统计
  Future<OtherTaskCounts> fetchOtherTaskCounts({
    required String startTime,
    required String endTime,
  }) async {
    final response = await _httpClient.post(
      ApiConfig.countMyTask,
      data: {'startTime': startTime, 'endTime': endTime},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return OtherTaskCounts.fromJson(data['result'] as Map<String, dynamic>);
      }
    }
    return OtherTaskCounts();
  }

  /// 获取自定义汇报物料列表
  Future<List<ReportItem>> fetchStyleInfo({
    required String reportMethod,
    required String taskNo,
  }) async {
    final response = await _httpClient.post(
      ApiConfig.getStyleInfo,
      data: {'reportMethod': reportMethod, 'taskNo': taskNo},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return (data['result'] as List<dynamic>)
            .map((e) => ReportItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// 获取SKU汇报物料列表
  Future<List<SkuItem>> fetchSkuList({
    required String reportMethod,
    required String taskNo,
  }) async {
    final response = await _httpClient.post(
      ApiConfig.getStyleInfo,
      data: {'reportMethod': reportMethod, 'taskNo': taskNo},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return (data['result'] as List<dynamic>)
            .map((e) => SkuItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// 开始计时
  Future<bool> startTimer({int deviceType = 2, String remark = ''}) async {
    final response = await _httpClient.post(
      ApiConfig.timerStart,
      data: {'deviceType': deviceType, 'remark': remark},
      silentError: true,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true) {
        return true;
      } else {
        throw Exception(data['errorMsg'] ?? '启动计时失败');
      }
    }
    throw Exception('服务器异常 (${response.statusCode})');
  }

  /// 查询计时状态
  Future<Map<String, dynamic>?> getTimerStatus() async {
    final response = await _httpClient.get(
      ApiConfig.timerStatus,
      options: Options(extra: {'silentError': true}),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return data['result'] as Map<String, dynamic>;
      }
    }
    return null;
  }

  /// 查询语音提醒上下班状态
  Future<bool?> getVoiceStatus() async {
    final response = await _httpClient.get(
      ApiConfig.voiceStatus,
      options: Options(extra: {'silentError': true}),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] is Map) {
        final result = data['result'] as Map<String, dynamic>;
        return result['voiceEnabled'] == true;
      }
    }
    return null;
  }

  /// 上班：开启语音提醒
  Future<bool> clockIn() async {
    final response = await _httpClient.post(
      ApiConfig.clockIn,
      silentError: true,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true) return true;
      throw Exception(data['errorMsg'] ?? '上班失败');
    }
    throw Exception('服务器异常 (${response.statusCode})');
  }

  /// 下班：关闭语音提醒
  Future<bool> clockOut() async {
    final response = await _httpClient.post(
      ApiConfig.clockOut,
      silentError: true,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true) return true;
      throw Exception(data['errorMsg'] ?? '下班失败');
    }
    throw Exception('服务器异常 (${response.statusCode})');
  }

  /// 暂停计时
  Future<bool> pauseTimer() async {
    final response = await _httpClient.post(
      ApiConfig.timerPause,
      silentError: true,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true) return true;
      throw Exception(data['errorMsg'] ?? '暂停计时失败');
    }
    throw Exception('服务器异常 (${response.statusCode})');
  }

  /// 恢复计时
  Future<bool> resumeTimer() async {
    final response = await _httpClient.post(
      ApiConfig.timerResume,
      silentError: true,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true) return true;
      throw Exception(data['errorMsg'] ?? '恢复计时失败');
    }
    throw Exception('服务器异常 (${response.statusCode})');
  }

  /// 结束计时
  Future<bool> stopTimer() async {
    final response = await _httpClient.post(
      ApiConfig.timerStop,
      silentError: true,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true) return true;
      throw Exception(data['errorMsg'] ?? '结束计时失败');
    }
    throw Exception('服务器异常 (${response.statusCode})');
  }

  /// 查询款号和订单编号
  Future<Map<String, List<String>>> queryBillNoAndStyleCode({
    required int taskType,
    required String queryContent,
  }) async {
    final response = await _httpClient.post(
      ApiConfig.queryBillNoAndStyleCode,
      data: {'taskType': taskType, 'queryContent': queryContent},
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        final result = data['result'] as Map<String, dynamic>;
        return {
          'styleCode':
              (result['styleCode'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          'billNo':
              (result['billNo'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
        };
      }
    }
    return {'styleCode': [], 'billNo': []};
  }

  /// 个人统计-我的汇报
  Future<MyReportResult?> fetchMyReport({
    required String timeDimension,
    required String date,
    required List<String> dateRange,
  }) async {
    final response = await _httpClient.post(
      ApiConfig.myReport,
      data: {
        'timeDimension': timeDimension,
        'date': date,
        'dateRange': dateRange,
      },
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return MyReportResult.fromJson(data['result'] as Map<String, dynamic>);
      }
    }
    return null;
  }
}
