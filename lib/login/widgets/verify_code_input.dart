import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 验证码输入框
class VerifyCodeInputField extends StatelessWidget {
  final TextEditingController controller;
  final int countdown;
  final VoidCallback onGetCode;
  final String? Function(String?)? validator;

  const VerifyCodeInputField({
    Key? key,
    required this.controller,
    required this.countdown,
    required this.onGetCode,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: '请输入验证码',
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
        prefixIcon: const Icon(
          Icons.verified_user_outlined,
          color: Color(0xFF777777),
          size: 20,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 45,
          minHeight: 20,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: countdown > 0 ? null : onGetCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: countdown > 0
                    ? const Color(0xFFF0F0F0)
                    : const Color(0xFF4A6CF7),
                foregroundColor: countdown > 0
                    ? const Color(0xFF999999)
                    : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                countdown > 0 ? '$countdown秒' : '获取验证码',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE1E1E1), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE1E1E1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A6CF7), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF4D4F), fontSize: 12),
      ),
    );
  }
}
