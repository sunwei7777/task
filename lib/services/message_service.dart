import '../config/api_config.dart';
import '../core/http_client.dart';
import '../models/message.dart';

class MessageService {
  final HttpClient _httpClient = HttpClient();

  /// 获取备注处理列表
  Future<RemarkReviewListResult?> fetchRemarkReviewList({
    int? taskType,
    int? readStatus,
    String? billNo,
    String? styleCode,
    String? expectFinishDate,
    int current = 1,
    int size = 20,
  }) async {
    final data = <String, dynamic>{
      'currentPage': current,
      'pageSize': size,
    };
    if (taskType != null) data['taskType'] = taskType;
    if (readStatus != null) data['readStatus'] = readStatus;
    if (billNo != null && billNo.isNotEmpty) data['billNo'] = billNo;
    if (styleCode != null && styleCode.isNotEmpty)
      data['styleCode'] = styleCode;
    if (expectFinishDate != null && expectFinishDate.isNotEmpty)
      data['expectFinishDate'] = expectFinishDate;

    final response = await _httpClient.post(
      ApiConfig.reportRemarkReviewList,
      data: data,
    );

    if (response.statusCode == 200) {
      final respData = response.data;
      if (respData['code'] == true && respData['result'] != null) {
        return RemarkReviewListResult.fromJson(
          respData['result'] as Map<String, dynamic>,
        );
      }
    }
    return null;
  }

  Future<MessageUnreadResult?> fetchUnreadCount() async {
    final response = await _httpClient.get(ApiConfig.messageUnreadCount);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return MessageUnreadResult.fromJson(
          data['result'] as Map<String, dynamic>,
        );
      }
    }
    return null;
  }

  Future<MessageListResult?> fetchMessageList({
    required String category,
    int current = 1,
    int size = 10,
  }) async {
    final response = await _httpClient.post(
      ApiConfig.messageList,
      data: {'category': category, 'current': current, 'size': size},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return MessageListResult.fromJson(
          data['result'] as Map<String, dynamic>,
        );
      }
    }
    return null;
  }

  Future<bool> markAsRead(List<int> messageIds) async {
    final response = await _httpClient.post(
      ApiConfig.messageRead,
      data: {'messageIds': messageIds},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      return data['code'] == true;
    }
    return false;
  }

  Future<bool> markCategoryAsRead(String category) async {
    final response = await _httpClient.post(
      ApiConfig.messageRead,
      data: {'category': category},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      return data['code'] == true;
    }
    return false;
  }

  /// 获取备注处理详情
  Future<RemarkReviewItem?> fetchRemarkDetail(int reportId) async {
    final response = await _httpClient.get(
      ApiConfig.reportRemarkReviewDetail,
      queryParameters: {'reportId': reportId},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        return RemarkReviewItem.fromJson(
          data['result'] as Map<String, dynamic>,
        );
      }
    }
    return null;
  }

  /// 提交备注处理意见
  Future<bool> submitRemarkComment(int reviewId, String comment) async {
    final response = await _httpClient.post(
      ApiConfig.reportRemarkReviewSubmitComment,
      data: {'reviewId': reviewId, 'comment': comment},
    );
    if (response.statusCode == 200) {
      final data = response.data;
      return data['code'] == true;
    }
    return false;
  }

  /// 批量标记备注已读
  Future<bool> batchMarkRemarkRead(List<int> reviewIds) async {
    final response = await _httpClient.post(
      ApiConfig.reportRemarkReviewBatchMarkRead,
      data: {'reviewIds': reviewIds},
    );
    if (response.statusCode == 200) {
      final data = response.data;
      return data['code'] == true;
    }
    return false;
  }

  Future<WorkTimeReport?> fetchMyWorkTimeReport() async {
    final response = await _httpClient.get(ApiConfig.myWorkTimeReport);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] == true && data['result'] != null) {
        final list = data['result'] as List<dynamic>;
        if (list.isNotEmpty) {
          return WorkTimeReport.fromJson(list[0] as Map<String, dynamic>);
        }
      }
    }
    return null;
  }
}
