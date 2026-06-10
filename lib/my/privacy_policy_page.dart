import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

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
          '隐私政策',
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
              '隐私政策',
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
            SizedBox(height: 16),
            Text(
              '本应用尊重并保护所有使用服务用户的个人隐私权。为了给您提供更准确、更有个性化的服务，本应用会按照本隐私权政策的规定使用和披露您的个人信息。但本应用将以高度的勤勉、审慎义务对待这些信息。除本隐私权政策另有规定外，在未征得您事先许可的情况下，本应用不会将这些信息对外披露或向第三方提供。本应用会不时更新本隐私权政策。您在同意本应用服务使用协议之时，即视为您已经同意本隐私权政策全部内容。本隐私权政策属于本应用服务使用协议不可分割的。',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '本政策仅适用于"上海汇叁科技发展有限公司"的"Max Task"产品或服务。',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            _buildSection(
              '一、我们收集信息',
              '当您使用"Max Task"产品或服务时，我们将收集您提供给我们的信息，以便向您提供更好的用户服务。这些信息和服务包括：\n\n'
                  '1. 基于相机/摄像头的权限：您可在开启相机/摄像头权限后使用该功能拍摄及上传照片/视频等功能。\n\n'
                  '2. 基于存储，相册（图片库/视频库）的图片/视频访问及上传的权限：您可在开启相册权限后使用该功能上传您的照片/图片/视频，以实现上传图片/视频的功能。\n\n'
                  '3. 基于麦克风的语音技术相关权限：您可在开启麦克风权限后使用麦克风实现语音录入功能。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '二、信息使用',
              '1. 本应用不会向任何无关第三方提供、出售、出租、分享或交易您的个人信息。\n\n'
                  '2. 本应用亦不允许任何第三方以任何手段收集、编辑、出售或者无偿传播您的个人信息。',
            ),
            SizedBox(height: 20),
            _buildSection('三、信息存储和交换', '本应用没有在云服务器存储您的私人信息。'),
            SizedBox(height: 20),
            _buildSection(
              '四、信息安全',
              '为更有效的保障您的信息安全，我们也希望您能够加强自我保护意识。我们仅在服务直接导致您个人信息泄露的范围内承担责任，因此，请您妥善保管您的账号及密码信息，避免您的个人信息泄露。除非您判断认为必要的情形下，不向任何第三人提供您的账号密码等个人信息。请您妥善保护自己的个人信息，仅在必要的情形下向他人提供。如您发现自己的个人信息泄密，尤其是本应用用户名及密码发生泄露，请您立即联络本应用客服，以便本应用采取相应措施。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '五、本隐私政策的更改',
              '1. 如果决定更改隐私政策，我们会在本政策中、本公司网站中以及我们认为适当的位置发布这些更改，以便您了解我们如何收集、使用您的个人信息，哪些人可以访问这些信息，以及在什么情况下我们会透露这些信息。\n\n'
                  '2. 本公司保留随时修改本政策的权利，您应定期查看以了解我们的隐私政策。您继续使用本服务即意味着您对本隐私政策及其任何更新版本的同意。',
            ),
            SizedBox(height: 20),
            _buildSection(
              '六、如何联系我们',
              '如果您对本隐私政策有任何疑问、意见或建议，通过以下方式与我们联系：\n\n'
                  '电子邮件：hotline@clevermax.com.cn\n'
                  '电　　话：15851212811\n'
                  '地　　址：上海市闵行区虹莘路3998号宝信大厦',
            ),
            SizedBox(height: 32),
            Text(
              '感谢您信任并使用我们的应用！',
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
