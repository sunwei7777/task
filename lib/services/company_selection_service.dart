// services/company_selection_service.dart
import '../config/api_config.dart';
import '../core/http_client.dart';
import '../models/company_selection.dart';

class CompanySelectionService {
  final HttpClient _httpClient = HttpClient();

  /// 获取公司用户列表
  /// 网络异常、超时、服务端错误等会直接抛出，由调用方处理
  Future<List<Company>> fetchCompaniesFromAPI({
    String userName = '',
    List<String>? companyIds,
  }) async {
    final defaultCompanyIds = [
      'hh_001',
      'mx_002',
      'hxy_003',
      'yd_004',
      'hs_005',
      'hm_006',
      'hhgg_007',
      'zshs_008',
    ];

    final Map<String, dynamic> requestData = {
      'companyIds': companyIds ?? defaultCompanyIds,
    };

    final trimmedUserName = userName.trim();
    if (trimmedUserName.isNotEmpty) {
      requestData['userName'] = trimmedUserName;
    }

    final response = await _httpClient.post(
      ApiConfig.getCompanyUsers,
      data: requestData,
    );

    if (response.statusCode == 200) {
      final data = response.data;

      if (data['code'] == true && data['result'] != null) {
        final List<dynamic> result = data['result'] as List;
        return result
            .map((companyJson) => Company.fromJson(companyJson))
            .toList();
      } else {
        throw Exception(data['errorMsg'] ?? '服务端返回错误');
      }
    } else {
      throw Exception('服务器异常 (${response.statusCode})');
    }
  }

  /// 获取指定公司的用户数据
  Future<List<Company>> fetchCompaniesByUser({
    required String userName,
    List<String>? companyIds,
  }) async {
    return fetchCompaniesFromAPI(userName: userName, companyIds: companyIds);
  }
}
