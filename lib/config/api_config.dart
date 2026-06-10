/// API配置类, 包含基础URL、连接超时时间、接收超时时间、接口路径等,后续新增后端接口地址，直接新增即可
class ApiConfig {
  // 基础配置
  // static const String baseUrl = 'http://192.168.1.141:3002';
  static const String baseUrl = 'http://10.30.208.251:8001';
  static const String wsUrl = 'ws://10.30.208.251/ws/app';
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 120);

  // 接口路径
  static const String login = '/erpUser/login';
  //获取负责人
  static const String getCompanyUsers = '/fsUser/getCompanyUsers';
  //创建我的任务，生成任务编号
  static const String generateTaskNumber = '/taskManage/generate';
  //上传图片/视频/文件
  static const String uploadImage = '/taskManage/uploadImage';
  //上传附件
  static const String uploadFile = '/taskManage/uploadFile';
  //所属公司下拉
  static const String selectCompany = '/projectGroup/selectCompany';
  static const String taskList = '/taskManage/list';
  static const String taskDetail = '/taskManage/getTaskDetail';
  static const String taskCancel = '/taskManage/taskCancel';
  static const String reportDetail = '/taskManage/report/reportDetail';
  static const String reportHistory = '/taskManage/report/reportHistory';
  static const String reportUploadFile = '/taskManage/report/uploadFile';
  //创建任务
  static const String taskCreate = '/taskManage/create';
  // 其他任务统计
  static const String countMyTask = '/taskManage/countMyTask';
  // 获取工序类型
  static const String getWorkType = '/taskManage/getWorkType';
  // 获取客户名称列表
  static const String getCustomerInfo = '/taskManage/getCustomerInfo';
  //订单列表
  static const String orderTaskPage = '/orderTask/orderTaskPage';
  //项目集列表
  static const String projectGroupList = '/projectGroup/projectGroup';
  //项目集下的项目列表
  static const String projectTaskOrderPage = '/projectTask/orderTaskPage';
  // 汇报模板列表
  static const String reportList = '/template/reportList';
  // 计时开始
  static const String timerStart = '/taskManage/timer/start';
  // 计时暂停
  static const String timerPause = '/taskManage/timer/pause';
  // 计时恢复
  static const String timerResume = '/taskManage/timer/resume';
  // 计时结束
  static const String timerStop = '/taskManage/timer/stop';
  // 计时状态查询
  static const String timerStatus = '/taskManage/timer/status';
  // 获取自定义汇报物料列表
  static const String getStyleInfo = '/taskManage/getStyleInfo';
  // 查询款号和订单编号
  static const String queryBillNoAndStyleCode =
      '/taskManage/queryBillNoAndStyleCode';
  // 个人统计-我的汇报
  static const String myReport = '/taskManage/report/myReport';
  static const String checkPreTaskReport = '/orderTask/checkPreTaskReport';
  static const String savePendingReport =
      '/taskManage/report/savePendingReport';
  // 消息未读数量
  static const String messageUnreadCount = '/taskManage/message/unreadCount';
  // 消息列表
  static const String messageList = '/taskManage/message/list';
  // 标记消息已读
  static const String messageRead = '/taskManage/message/read';
  // 我的工作报告
  static const String myWorkTimeReport = '/taskManage/message/myWorkTimeReport';
  // 语音提醒上下班状态
  static const String voiceStatus = '/taskManage/message/voiceStatus';
  // 上班开启语音提醒
  static const String clockIn = '/taskManage/message/clockIn';
  // 下班关闭语音提醒
  static const String clockOut = '/taskManage/message/clockOut';

  // 连接超时时间
  static const int connectTimeoutSeconds = 60;
  static const int receiveTimeoutSeconds = 120;
}
