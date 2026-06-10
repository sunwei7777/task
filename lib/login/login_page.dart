import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'register_page.dart';
import 'widgets/phone_input.dart';
import 'widgets/password_input.dart';
import 'widgets/social_login_button.dart';
import '../utils/top_notification.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

/// 登录页面
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  List<Map<String, String>> _savedLoginAccounts = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 检查登录状态
  Future<void> _checkLoginStatus() async {
    final loginInfo = await StorageService.getLoginInfo();
    final savedAccounts = await StorageService.getSavedLoginAccounts();
    if (mounted) {
      setState(() {
        _savedLoginAccounts = savedAccounts;
      });
    }

    // 如果勾选了记住我，用保存的账号密码自动调用登录接口获取新 token
    if (loginInfo['rememberMe'] == true) {
      final phone = loginInfo['phone'] ?? '';
      final password = loginInfo['password'] ?? '';

      if (phone.isNotEmpty && password.isNotEmpty) {
        // 填充保存的账号信息到输入框
        if (mounted) {
          _accountController.text = phone;
          _passwordController.text = password;
          _rememberMe = true;
          setState(() {
            _isLoading = true; // 显示加载中状态，避免用户操作
          });
        }

        try {
          final authService = AuthService();
          final result = await authService.login(
            phone: phone,
            password: password,
          );

          if (!mounted) return;

          if (result['success'] == true) {
            // 刷新登录信息存储（延长记住密码有效期）
            await StorageService.saveLoginInfo(
              phone: phone,
              password: password,
              rememberMe: true,
            );
            if (!mounted) return;
            // 跳转首页（WebSocket 已在 AuthService.login 中连接）
            Navigator.of(context).pushReplacementNamed('/home');
            return;
          }

          // 自动登录失败（如密码已变更），停止加载，后续正常显示登录页
          print('自动登录失败: ${result['message']}');
        } catch (e) {
          print('自动登录异常: $e');
        }

        // 自动登录失败，停留在登录页，显示温和提示
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          TopNotification.info(context, '登录已过期，请重新登录');
        }
        return;
      }
    }

    // 非记住密码场景：填充手机号或已保存账号
    if (loginInfo['phone'] != null && loginInfo['phone']!.isNotEmpty) {
      if (mounted) {
        _accountController.text = loginInfo['phone'] ?? '';
        _fillPasswordForAccount(_accountController.text);
      }
    } else if (savedAccounts.isNotEmpty) {
      if (mounted) {
        _selectSavedAccount(savedAccounts.first);
      }
    } else {
      print('没有保存的登录信息');
    }
  }

  void _fillPasswordForAccount(String account) {
    final normalizedAccount = account.trim();
    Map<String, String>? matchedAccount;
    for (final item in _savedLoginAccounts) {
      if (item['phone'] == normalizedAccount) {
        matchedAccount = item;
        break;
      }
    }

    if (matchedAccount == null) {
      _passwordController.clear();
      setState(() {
        _rememberMe = false;
      });
      return;
    }

    _passwordController.text = matchedAccount['password'] ?? '';
    setState(() {
      _rememberMe = true;
    });
  }

  void _selectSavedAccount(Map<String, String> account) {
    _accountController.text = account['phone'] ?? '';
    _passwordController.text = account['password'] ?? '';
    setState(() {
      _rememberMe = true;
    });
  }

  Widget? _buildSavedAccountMenu() {
    if (_savedLoginAccounts.isEmpty) return null;

    return PopupMenuButton<int>(
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF777777)),
      tooltip: '选择已保存账号',
      onSelected: (index) {
        _selectSavedAccount(_savedLoginAccounts[index]);
      },
      itemBuilder: (context) {
        return List.generate(_savedLoginAccounts.length, (index) {
          final account = _savedLoginAccounts[index];
          return PopupMenuItem<int>(
            value: index,
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: Color(0xFF777777),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    account['phone'] ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 登录处理
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用真实的登录 API
      final authService = AuthService();
      final account = _accountController.text.trim();
      final result = await authService.login(
        phone: account,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // 保存登录信息
        await StorageService.saveLoginInfo(
          phone: account,
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );
        final savedAccounts = await StorageService.getSavedLoginAccounts();

        // 登录成功，跳转到首页
        if (mounted) {
          setState(() {
            _savedLoginAccounts = savedAccounts;
          });
          Navigator.of(context).pushReplacementNamed('/home');
          TopNotification.success(context, result['message'] ?? '登录成功！');
        }
      } else {
        // 登录失败，显示错误信息
        if (mounted) {
          TopNotification.error(context, result['message'] ?? '登录失败');
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        String msg;
        if (e is DioException && e.response?.data != null) {
          final data = e.response!.data;
          msg = (data is Map)
              ? (data['errorMsg']?.toString() ??
                    data['message']?.toString() ??
                    '登录失败')
              : '登录失败';
        } else if (e is Exception) {
          msg = e.toString().replaceFirst('Exception: ', '');
        } else {
          msg = '网络异常，请检查网络连接';
        }
        TopNotification.error(context, msg);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 卡片容器
                  Container(
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 标题
                        const Text(
                          '欢迎回来',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '登录您的账户',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF777777),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 手机号输入
                        PhoneInputField(
                          controller: _accountController,
                          suffixIcon: _buildSavedAccountMenu(),
                          onChanged: _fillPasswordForAccount,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入账号';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // 密码输入
                        PasswordInputField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // 记住密码 & 忘记密码
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: const Color(0xFF4A6CF7),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  '记住密码',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF777777),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                TopNotification.warning(
                                  context,
                                  '请联系系统管理员重置密码',
                                );
                              },
                              child: const Text(
                                '忘记密码?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4A6CF7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 登录按钮
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF4A6CF7),
                                    Color(0xFF8A4AF3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4A6CF7,
                                    ).withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      '登录',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 社交登录分隔线
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Container(
                  //         height: 1,
                  //         color: const Color(0xFFE1E1E1),
                  //       ),
                  //     ),
                  //     const Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 16),
                  //       child: Text(
                  //         '或通过以下方式登录',
                  //         style: TextStyle(
                  //           fontSize: 13,
                  //           color: Color(0xFF777777),
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Container(
                  //         height: 1,
                  //         color: const Color(0xFFE1E1E1),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 20),
                  //
                  // // 微信登录
                  // const SocialLoginButton(),
                  // const SizedBox(height: 20),

                  // 切换注册
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '还没有账户？',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF777777),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          '立即注册',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A6CF7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
