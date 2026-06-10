import '../config/api_config.dart';
import '../core/http_client.dart';
import '../models/message.dart';

class MessageService {
  final HttpClient _httpClient = HttpClient();

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
