import 'package:flutter/material.dart';

class ServiceAgreementPage extends StatelessWidget {
  const ServiceAgreementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          '用户协议',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户协议',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '最近更新日期：2026/03/18',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            _buildSection(
              '1. 接受条款',
              '通过下载、安装或使用"Max Task"，即表示您同意遵守本用户协议("协议")的所有条款和条件。如果您不同意这些条款，请不要使用本应用。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '2. 服务描述',
              '本应用提供任务管理、日程安排等功能。我们保留随时修改或中断服务的权利，无需事先通知。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '3. 用户资格',
              '您必须年满18岁才能使用本应用，或在使用本应用时已获得父母或法定监护人的同意。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '4. 账户注册与安全',
              '某些功能可能需要注册账户。您同意：\n\n'
              '• 提供真实、准确、完整的注册信息\n'
              '• 及时更新注册信息\n'
              '• 对账户密码保密并承担账户活动的全部责任\n'
              '• 立即通知我们任何未经授权的账户使用行为',
            ),
            SizedBox(height: 20),
            _buildSection(
              '5. 用户行为规范',
              '您同意不会：\n\n'
              '• 使用本应用进行任何非法活动\n'
              '• 上传或传播病毒、恶意代码\n'
              '• 干扰或破坏本应用的正常运行\n'
              '• 尝试未经授权访问我们的系统或其他用户账户\n'
              '• 侵犯他人的知识产权或隐私权',
            ),
            SizedBox(height: 20),
            _buildSection(
              '6. 隐私政策',
              '您的隐私对我们很重要。我们的隐私政策说明了我们如何收集、使用和保护您的个人信息。隐私政策是本协议的组成部分。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '7. 知识产权',
              '本应用及其所有内容、功能和服务(包括但不限于所有信息、软件、文本、显示、图像、视频和音频)归我们或我们的许可方所有，受版权、商标、专利和其他法律保护。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '8. 应用内购买',
              '如果本应用提供应用内购买：\n\n'
              '• 所有购买均通过应用商店处理\n'
              '• 购买是不可退款的，除非应用商店另有规定\n'
              '• 价格可能随时更改，恕不另行通知',
            ),
            SizedBox(height: 20),
            _buildSection(
              '9. 免责声明',
              '本应用按"原样"提供，不作任何明示或暗示的保证。我们不保证本应用将满足您的要求、无中断、及时、安全或无错误。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '10. 责任限制',
              '在法律允许的最大范围内，我们不对任何间接、附带、特殊、后果性或惩罚性损害承担责任，包括但不限于利润损失、数据丢失或其他无形损失。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '11. 协议修改',
              '我们保留随时修改本协议的权利。修改后的协议将在本应用或我们的网站上发布后生效。您继续使用本应用即表示接受修改后的协议。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '12. 终止',
              '我们可随时终止或暂停您的访问权限，无需事先通知或承担责任。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '13. 适用法律',
              '本协议受中华人民共和国法律管辖并据其解释。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '14. 联系我们',
              '如有任何关于本协议的问题，请通过以下方式与我们联系：\n\n'
              '电子邮件：hotline@clevermax.com.cn\n'
              '电　　话：15851212811\n'
              '地　　址：上海市闵行区虹莘路3998号宝信大厦',
            ),
            SizedBox(height: 32),
            Text(
              '感谢您使用"Max Task"！',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }
}
