// 用户模型
class User {
  final String? id;
  final String? userName;
  final String? password;
  final String realName;
  final String userId;
  final String? loginTime;
  final String? loginIp;
  final String? createTime;
  final String? phone;
  final String? companyId;
  final String? token;
  final bool? isManager;
  final String? newPassword;
  final String? ipAddress;

  User({
    this.id,
    this.userName,
    this.password,
    required this.realName,
    required this.userId,
    this.loginTime,
    this.loginIp,
    this.createTime,
    this.phone,
    this.companyId,
    this.token,
    this.isManager,
    this.newPassword,
    this.ipAddress,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      userName: json['userName']?.toString(),
      password: json['password']?.toString(),
      realName: json['realName']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      loginTime: json['loginTime']?.toString(),
      loginIp: json['loginIp']?.toString(),
      createTime: json['createTime']?.toString(),
      phone: json['phone']?.toString(),
      companyId: json['companyId']?.toString(),
      token: json['token']?.toString(),
      isManager: json['isManager'] as bool?,
      newPassword: json['newPassword']?.toString(),
      ipAddress: json['ipAddress']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'password': password,
      'realName': realName,
      'userId': userId,
      'loginTime': loginTime,
      'loginIp': loginIp,
      'createTime': createTime,
      'phone': phone,
      'companyId': companyId,
      'token': token,
      'isManager': isManager,
      'newPassword': newPassword,
      'ipAddress': ipAddress,
    };
  }
}

// 部门/组模型
class Department {
  final String? id;
  final int groupId;
  final String groupName;
  final String? parentId;
  final String? company;
  final String? companyId;
  final String? createTime;
  final List<User> userList;

  Department({
    this.id,
    required this.groupId,
    required this.groupName,
    this.parentId,
    this.company,
    this.companyId,
    this.createTime,
    required this.userList,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id']?.toString(),
      groupId: json['groupId'] as int? ?? 0,
      groupName: json['groupName']?.toString() ?? '',
      parentId: json['parentId']?.toString(),
      company: json['company']?.toString(),
      companyId: json['companyId']?.toString(),
      createTime: json['createTime']?.toString(),
      userList: (json['userList'] as List? ?? [])
          .map((user) => User.fromJson(user))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'groupName': groupName,
      'parentId': parentId,
      'company': company,
      'companyId': companyId,
      'createTime': createTime,
      'userList': userList.map((user) => user.toJson()).toList(),
    };
  }
}

// 公司模型
class Company {
  final String companyName;
  final String companyId;
  final List<Department> groupUserVo;

  Company({
    required this.companyName,
    required this.companyId,
    required this.groupUserVo,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyName: json['companyName']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      groupUserVo: (json['groupUserVo'] as List? ?? [])
          .map((department) => Department.fromJson(department))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'companyId': companyId,
      'groupUserVo': groupUserVo
          .map((department) => department.toJson())
          .toList(),
    };
  }
}

// 选中的人员模型
class SelectedPerson {
  final String userId;
  final String realName;
  final String departmentName;
  final String departmentId;
  final String companyName;
  final String companyId;

  SelectedPerson({
    required this.userId,
    required this.realName,
    required this.departmentName,
    required this.departmentId,
    required this.companyName,
    required this.companyId,
  });

  factory SelectedPerson.fromUserAndDepartment({
    required User user,
    required Department department,
    required Company company,
  }) {
    return SelectedPerson(
      userId: user.userId,
      realName: user.realName,
      departmentName: department.groupName,
      departmentId: department.groupId.toString(),
      companyName: company.companyName,
      companyId: company.companyId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'realName': realName,
      'departmentName': departmentName,
      'departmentId': departmentId,
      'companyName': companyName,
      'companyId': companyId,
    };
  }
}
