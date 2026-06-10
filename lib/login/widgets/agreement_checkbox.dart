import 'package:flutter/material.dart';
import '../../my/service_agreement_page.dart';
import '../../my/privacy_policy_page.dart';

/// 用户协议勾选框
class AgreementCheckbox extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool?>? onChanged;

  const AgreementCheckbox({Key? key, required this.agreed, this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: agreed,
          onChanged: onChanged,
          activeColor: const Color(0xFF4A6CF7),
        ),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: -4, // 让文字紧凑排列
            children: [
              const Text(
                '我已阅读并同意 ',
                style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServiceAgreementPage(),
                    ),
                  );
                },
                child: const Text(
                  '《用户协议》',
                  style: TextStyle(fontSize: 12, color: Color(0xFF4A6CF7)),
                ),
              ),
              const Text(
                ' 和 ',
                style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage(),
                    ),
                  );
                },
                child: const Text(
                  '《隐私政策》',
                  style: TextStyle(fontSize: 12, color: Color(0xFF4A6CF7)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
