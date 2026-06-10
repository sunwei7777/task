import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 本地存储服务
class StorageService {
  static SharedPreferences? _prefs;

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyPhone = 'user_phone';
  static const String _keyPassword = 'user_password';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyToken = 'auth_token';
  static const String _keyUserInfo = 'user_info';
  static const String _keySavedLoginAccounts = 'saved_login_accounts';

  // 保存Token
  static Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(_keyToken, token);
    print('[StorageService] Token已保存');
  }

  // 获取Token
  static Future<String?> getToken() async {
    final prefs = await _instance;
    final token = prefs.getString(_keyToken);
    print('[StorageService] 获取Token: ${token != null ? '已找到' : '未找到'}');
    return token;
  }

  // 清除Token
  static Future<void> clearToken() async {
    final prefs = await _instance;
    await prefs.remove(_keyToken);
    print('[StorageService] Token已清除');
  }

  // 获取 SharedPreferences 实例（单例模式）
  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // 保存登录信息
  static Future<void> saveLoginInfo({
    required String phone,
    required String password,
    required bool rememberMe,
  }) async {
    final prefs = await _instance;

    print('[StorageService] 开始保存登录信息...');
    await prefs.setString(_keyPhone, phone);
    print('[StorageService] 手机号已保存: $phone');

    await prefs.setString(_keyPassword, password);
    print('[StorageService] 密码已保存');

    await prefs.setBool(_keyRememberMe, rememberMe);
    print('[StorageService] 记住我状态已保存: $rememberMe');

    if (rememberMe) {
      await prefs.setBool(_keyIsLoggedIn, true);
      await saveLoginAccount(phone: phone, password: password);
      print('[StorageService] 登录状态已保存: true');
    } else {
      await prefs.remove(_keyIsLoggedIn);
      await removeSavedLoginAccount(phone);
      print('[StorageService] 登录状态已清除');
    }

    // 验证保存结果
    final savedPhone = prefs.getString(_keyPhone);
    final savedRememberMe = prefs.getBool(_keyRememberMe);
    final savedIsLoggedIn = prefs.getBool(_keyIsLoggedIn);
    print(
      '[StorageService] 验证保存结果 - phone: $savedPhone, rememberMe: $savedRememberMe, isLoggedIn: $savedIsLoggedIn',
    );

    // 获取所有 keys
    final allKeys = prefs.getKeys();
    print('[StorageService] 当前存储的所有 keys: $allKeys');
  }

  // 获取保存的登录信息
  static Future<Map<String, dynamic>> getLoginInfo() async {
    final prefs = await _instance;

    print('[StorageService] 开始读取登录信息...');

    // 获取所有 keys
    final allKeys = prefs.getKeys();
    print('[StorageService] 当前存储的所有 keys: $allKeys');

    final phone = prefs.getString(_keyPhone);
    final password = prefs.getString(_keyPassword);
    final rememberMe = prefs.getBool(_keyRememberMe);
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn);

    print(
      '[StorageService] 读取结果 - phone: $phone, password: $password, rememberMe: $rememberMe, isLoggedIn: $isLoggedIn',
    );

    return {
      'phone': phone ?? '',
      'password': password ?? '',
      'rememberMe': rememberMe ?? false,
      'isLoggedIn': isLoggedIn ?? false,
    };
  }

  // 检查是否已登录
  static Future<List<Map<String, String>>> getSavedLoginAccounts() async {
    final prefs = await _instance;
    final raw = prefs.getString(_keySavedLoginAccounts);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map>()
          .map((item) {
            return {
              'phone': item['phone']?.toString() ?? '',
              'password': item['password']?.toString() ?? '',
              'updatedAt': item['updatedAt']?.toString() ?? '',
            };
          })
          .where((item) => item['phone']!.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, String>?> getSavedLoginAccount(String phone) async {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) return null;

    final accounts = await getSavedLoginAccounts();
    for (final account in accounts) {
      if (account['phone'] == normalizedPhone) {
        return account;
      }
    }
    return null;
  }

  static Future<void> saveLoginAccount({
    required String phone,
    required String password,
  }) async {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) return;

    final prefs = await _instance;
    final accounts = await getSavedLoginAccounts();
    accounts.removeWhere((item) => item['phone'] == normalizedPhone);
    accounts.insert(0, {
      'phone': normalizedPhone,
      'password': password,
      'updatedAt': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    await prefs.setString(_keySavedLoginAccounts, jsonEncode(accounts));
  }

  static Future<void> removeSavedLoginAccount(String phone) async {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) return;

    final prefs = await _instance;
    final accounts = await getSavedLoginAccounts();
    accounts.removeWhere((item) => item['phone'] == normalizedPhone);
    await prefs.setString(_keySavedLoginAccounts, jsonEncode(accounts));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _instance;
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // 清除登录信息
  static Future<void> clearLoginInfo() async {
    print('[StorageService] ========== clearLoginInfo 被调用 ==========');
    print('[StorageService] 调用栈:');
    StackTrace.current.toString().split('\n').take(10).forEach((line) {
      print('  $line');
    });

    final prefs = await _instance;
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyRememberMe);
    print('[StorageService] 登录信息已清除');
  }

  // 保存用户信息
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await _instance;
    await prefs.setString(_keyUserInfo, jsonEncode(userInfo));
    print('[StorageService] 用户信息已保存');
  }

  // 获取用户信息
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await _instance;
    final userInfoJson = prefs.getString(_keyUserInfo);
    if (userInfoJson != null && userInfoJson.isNotEmpty) {
      return jsonDecode(userInfoJson) as Map<String, dynamic>;
    }
    return null;
  }

  // 清除用户信息
  static Future<void> clearUserInfo() async {
    final prefs = await _instance;
    await prefs.remove(_keyUserInfo);
    print('[StorageService] 用户信息已清除');
  }
}
