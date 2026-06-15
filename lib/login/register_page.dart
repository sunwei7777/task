import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'widgets/phone_input.dart';
import 'widgets/password_input.dart';
import 'widgets/verify_code_input.dart';
import 'widgets/agreement_checkbox.dart';
import 'widgets/social_login_button.dart';
import '../utils/top_notification.dart';
import '../services/auth_service.dart';

/// 注册页面
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreeToTerms = false;
  bool _isLoading = false;
  int _countdown = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 手机号验证
  bool _validatePhone(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }

  // 密码验证
  bool _validatePassword(String password) {
    return password.length >= 6 && password.length <= 20;
  }

  // 验证码验证
  bool _validateCode(String code) {
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  // 获取验证码
  void _getVerifyCode() {
    if (_phoneController.text.isEmpty) {
      TopNotification.error(context, '请输入手机号');
      return;
    }

    if (!_validatePhone(_phoneController.text)) {
      TopNotification.error(context, '请输入正确的手机号');
      return;
    }

    // 开始倒计时
    setState(() {
      _countdown = 60;
    });

    // 模拟发送验证码
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        TopNotification.success(
          context,
          '模拟验证码已发送至 ${_phoneController.text}\n测试验证码：123456',
          duration: const Duration(seconds: 3),
        );
      }
    });

    // 倒计时
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
      }
      return _countdown > 0;
    });
  }

  // 注册处理
  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      TopNotification.error(context, '请先阅读并同意用户协议和隐私政策');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final result = await authService.register(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        rePassword: _confirmPasswordController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        TopNotification.success(context, result['message'] ?? '注册成功！');
        // 注册成功返回登录页
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        TopNotification.error(context, result['message'] ?? '注册失败');
      }
    } catch (e) {
      if (!mounted) return;
      String msg;
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        msg = (data is Map)
            ? (data['errorMsg']?.toString() ??
                  data['message']?.toString() ??
                  '注册失败')
            : '注册失败';
      } else if (e is Exception) {
        msg = e.toString().replaceFirst('Exception: ', '');
      } else {
        msg = '网络异常，请检查网络连接';
      }
      TopNotification.error(context, msg);
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '创建账户',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    '使用手机号注册新账户',
                    style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
                  ),
                  const SizedBox(height: 24),

                  // 手机号输入
                  PhoneInputField(
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入手机号';
                      }
                      if (!_validatePhone(value)) {
                        return '请输入正确的手机号';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 验证码输入
                  // VerifyCodeInputField(
                  //   controller: _codeController,
                  //   countdown: _countdown,
                  //   onGetCode: _getVerifyCode,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return '请输入验证码';
                  //     }
                  //     if (!_validateCode(value)) {
                  //       return '请输入6位验证码';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  // const SizedBox(height: 20),

                  // 密码输入
                  PasswordInputField(
                    controller: _passwordController,
                    hintText: '请设置密码（6-20位）',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入密码';
                      }
                      if (!_validatePassword(value)) {
                        return '密码长度应为6-20位';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 确认密码
                  PasswordInputField(
                    controller: _confirmPasswordController,
                    hintText: '请再次输入密码',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请再次输入密码';
                      }
                      if (value != _passwordController.text) {
                        return '两次密码不一致';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 用户协议
                  AgreementCheckbox(
                    agreed: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // 注册按钮
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
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
                            colors: [Color(0xFF4A6CF7), Color(0xFF8A4AF3)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A6CF7).withOpacity(0.3),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                '注册',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
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
                  //         '或通过以下方式注册',
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

                  // 切换登录
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '已有账户？',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF777777),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '立即登录',
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
