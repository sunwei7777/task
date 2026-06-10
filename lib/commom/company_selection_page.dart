import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/company_selection.dart';
import '../services/company_selection_service.dart';

class CompanySelectionPage extends StatefulWidget {
  final String title;
  final Function(List<SelectedPerson>)? onConfirm;
  final List<SelectedPerson> initialSelections;

  const CompanySelectionPage({
    super.key,
    this.title = '选择负责人',
    this.onConfirm,
    this.initialSelections = const [],
  });

  @override
  State<CompanySelectionPage> createState() => _CompanySelectionPageState();
}

class _CompanySelectionPageState extends State<CompanySelectionPage> {
  final CompanySelectionService _service = CompanySelectionService();

  List<Company> companies = [];
  List<SelectedPerson> selectedPersons = [];
  String searchQuery = '';
  Map<String, bool> expandedCompanies = {};
  Map<String, bool> expandedDepartments = {};
  bool isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 初始化已选择的人员
    selectedPersons = List.from(widget.initialSelections);
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedCompanies = await _service.fetchCompaniesFromAPI();
      setState(() {
        companies = fetchedCompanies;
        _initExpandStates();
        isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = _mapDioError(e);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = '加载失败：${e.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络连接超时，请检查网络后重试';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
          return '服务器繁忙，请稍后重试';
        }
        return '服务异常 (${statusCode ?? '未知'})，请稍后重试';
      default:
        return '网络异常，请检查网络后重试';
    }
  }

  void _initExpandStates() {
    for (var company in companies) {
      expandedCompanies[company.companyId] = false;
      for (var department in company.groupUserVo) {
        expandedDepartments['${company.companyId}_${department.groupId}'] =
            false;
      }
    }
  }

  // 切换公司展开状态
  void _toggleCompanyExpansion(String companyId) {
    setState(() {
      expandedCompanies[companyId] = !(expandedCompanies[companyId] ?? false);
    });
  }

  // 切换部门展开状态
  void _toggleDepartmentExpansion(String companyId, int departmentId) {
    setState(() {
      String key = '${companyId}_$departmentId';
      expandedDepartments[key] = !(expandedDepartments[key] ?? false);
    });
  }

  // 切换员工选中状态
  void _toggleSelection(User user, Department department, Company company) {
    setState(() {
      // 检查是否已存在
      final existingIndex = selectedPersons.indexWhere(
        (person) => person.userId == user.userId,
      );

      if (existingIndex != -1) {
        // 如果已存在，移除
        selectedPersons.removeAt(existingIndex);
      } else {
        // 如果不存在，添加
        selectedPersons.add(
          SelectedPerson.fromUserAndDepartment(
            user: user,
            department: department,
            company: company,
          ),
        );
      }
    });
  }

  // 移除选中的人员
  void _removeSelectedPerson(SelectedPerson person) {
    setState(() {
      selectedPersons.removeWhere((p) => p.userId == person.userId);
    });
  }

  // 清空所有选择
  void _clearAllSelection() {
    if (selectedPersons.isEmpty) return;

    setState(() {
      selectedPersons.clear();
    });
  }

  // 判断员工是否选中
  bool _isUserSelected(String userId) {
    return selectedPersons.any((person) => person.userId == userId);
  }

  // 获取公司选中人数
  int _getCompanySelectedCount(String companyId) {
    return selectedPersons
        .where((person) => person.companyId == companyId)
        .length;
  }

  // 获取部门选中人数
  int _getDepartmentSelectedCount(String companyId, int departmentId) {
    return selectedPersons
        .where(
          (person) =>
              person.companyId == companyId &&
              person.departmentId == departmentId.toString(),
        )
        .length;
  }

  // 搜索过滤 - 只根据用户名搜索
  List<Company> get _filteredCompanies {
    if (searchQuery.isEmpty) {
      return companies;
    }

    final query = searchQuery.toLowerCase();

    // 自动展开所有匹配的公司和部门
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        for (var company in companies) {
          // 检查该公司是否有匹配的用户
          final hasMatchingUsers = company.groupUserVo.any(
            (dept) => dept.userList.any(
              (user) =>
                  user.userName != null &&
                  user.userName!.toLowerCase().contains(query),
            ),
          );

          if (hasMatchingUsers) {
            expandedCompanies[company.companyId] = true;

            // 展开该公司下的所有部门
            for (var dept in company.groupUserVo) {
              expandedDepartments['${company.companyId}_${dept.groupId}'] =
                  true;
            }
          }
        }
      });
    });

    return companies
        .map((company) {
          // 对每个公司，过滤部门和员工
          final filteredDepartments = company.groupUserVo
              .map((department) {
                // 只根据 userName 搜索匹配的员工
                final matchingUsers = department.userList
                    .where(
                      (user) =>
                          user.userName != null &&
                          user.userName!.toLowerCase().contains(query),
                    )
                    .toList();

                // 如果没有匹配的员工，返回 null
                if (matchingUsers.isEmpty) {
                  return null;
                }

                // 返回包含匹配员工的部门
                return Department(
                  id: department.id,
                  groupId: department.groupId,
                  groupName: department.groupName,
                  parentId: department.parentId,
                  company: department.company,
                  companyId: department.companyId,
                  createTime: department.createTime,
                  userList: matchingUsers,
                );
              })
              .where((department) => department != null)
              .cast<Department>()
              .toList();

          // 如果公司没有匹配的部门，返回 null
          if (filteredDepartments.isEmpty) {
            return null;
          }

          return Company(
            companyName: company.companyName,
            companyId: company.companyId,
            groupUserVo: filteredDepartments,
          );
        })
        .where((company) => company != null)
        .cast<Company>()
        .toList();
  }

  // 确认选择
  void _confirmSelection() {
    if (selectedPersons.isEmpty) return;

    widget.onConfirm?.call(selectedPersons);
    Navigator.pop(context);
  }

  // 取消选择
  void _cancelSelection() {
    Navigator.pop(context);
  }

  // 构建员工列表项
  Widget _buildUserTile(User user, Department department, Company company) {
    bool isSelected = _isUserSelected(user.userId);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleSelection(user, department, company),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F6FF) : Colors.transparent,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              // 用户层级缩进
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  user.userName ?? user.realName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF208BDE)
                        : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF208BDE) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF208BDE)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建部门列表项
  Widget _buildDepartmentTile(Company company, Department department) {
    String departmentKey = '${company.companyId}_${department.groupId}';
    bool isExpanded = expandedDepartments[departmentKey] ?? false;
    bool hasSelectedUsers = department.userList.any(
      (user) => _isUserSelected(user.userId),
    );

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleDepartmentExpansion(
              company.companyId,
              department.groupId,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: hasSelectedUsers
                    ? const Color(0xFFF0F6FF)
                    : Colors.transparent,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  // 部门层级缩进
                  const SizedBox(width: 20),
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.keyboard_arrow_right,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      department.groupName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: hasSelectedUsers
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: hasSelectedUsers
                            ? const Color(0xFF208BDE)
                            : Colors.black87,
                      ),
                    ),
                  ),
                  if (hasSelectedUsers)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F0FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${department.userList.where((user) => _isUserSelected(user.userId)).length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF208BDE),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          ...department.userList.map((user) {
            return _buildUserTile(user, department, company);
          }),
      ],
    );
  }

  // 构建公司列表项
  Widget _buildCompanyTile(Company company) {
    bool isExpanded = expandedCompanies[company.companyId] ?? false;
    bool hasSelectedUsers = company.groupUserVo.any(
      (department) =>
          department.userList.any((user) => _isUserSelected(user.userId)),
    );

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleCompanyExpansion(company.companyId),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: hasSelectedUsers
                    ? const Color(0xFFF0F6FF)
                    : Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.keyboard_arrow_right,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      company.companyName,
                      style: TextStyle(
                        fontSize: 15,
                        // fontWeight: FontWeight.w600,
                        color: hasSelectedUsers
                            ? const Color(0xFF208BDE)
                            : Colors.black87,
                      ),
                    ),
                  ),
                  if (hasSelectedUsers)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F0FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${company.groupUserVo.expand((d) => d.userList.where((user) => _isUserSelected(user.userId))).length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF208BDE),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  // const SizedBox(width: 8),
                  // Icon(
                  //   isExpanded ? Icons.expand_less : Icons.expand_more,
                  //   color: Colors.grey.shade600,
                  //   size: 20,
                  // ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          ...company.groupUserVo.map((department) {
            return _buildDepartmentTile(company, department);
          }),
      ],
    );
  }

  // 构建已选择成员的标签
  Widget _buildSelectedTags() {
    if (selectedPersons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '已选择 (${selectedPersons.length})',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF208BDE),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedPersons.map((person) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF208BDE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(person.realName, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _removeSelectedPerson(person),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF208BDE),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 构建右侧已选择成员列表
  Widget _buildSelectedList() {
    if (selectedPersons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '暂无已选择成员',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '点击左侧人员进行选择',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: selectedPersons.length,
      itemBuilder: (context, index) {
        final person = selectedPersons[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _removeSelectedPerson(person),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      person.realName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Icon(Icons.close, size: 18, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCompanies = _filteredCompanies;

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black87,
      //   leading: IconButton(
      //     icon: const Icon(Icons.close),
      //     onPressed: _cancelSelection,
      //   ),
      //   actions: [
      //     TextButton(
      //       onPressed: selectedPersons.isNotEmpty ? _confirmSelection : null,
      //       child: Text(
      //         '确定',
      //         style: TextStyle(
      //           color: selectedPersons.isNotEmpty
      //               ? const Color(0xFF208BDE)
      //               : Colors.grey.shade400,
      //           fontWeight: FontWeight.w600,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            // 搜索框
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索用户名',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: Color(0xFF208BDE),
                      width: 1,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            // 主内容区
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            '正在加载数据...',
                            style: TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadCompanies,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('重试'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF208BDE),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        // 左侧：组织架构
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              // 组织架构标题
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                color: Colors.white,
                                child: const Row(
                                  children: [
                                    Text(
                                      '组织',
                                      style: TextStyle(
                                        fontSize: 14,
                                        // fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 公司列表
                              Expanded(
                                child: filteredCompanies.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.search_off,
                                              size: 48,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              searchQuery.isEmpty
                                                  ? '暂无数据'
                                                  : '未找到匹配结果',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        itemCount: filteredCompanies.length,
                                        itemBuilder: (context, index) {
                                          return _buildCompanyTile(
                                            filteredCompanies[index],
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),

                        // 分割线
                        Container(width: 1, color: Colors.grey.shade200),

                        // 右侧：已选择成员
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              // 已选择成员标题
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '已选择成员',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    GestureDetector(
                                      onTap: _clearAllSelection,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        // decoration: BoxDecoration(
                                        //   color: const Color(0xFFF0F6FF),
                                        //   borderRadius: BorderRadius.circular(12),
                                        // ),
                                        child: const Text(
                                          '清空',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF208BDE),
                                            // fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 已选择成员列表
                              Expanded(child: _buildSelectedList()),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            // 底部按钮行
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedPersons.isEmpty
                          ? '请选择'
                          : '已选择 ${selectedPersons.length} 人',
                      style: TextStyle(
                        color: selectedPersons.isEmpty
                            ? Colors.grey.shade600
                            : const Color(0xFF208BDE),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _cancelSelection,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: selectedPersons.isNotEmpty
                            ? _confirmSelection
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPersons.isNotEmpty
                              ? const Color(0xFF208BDE)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: selectedPersons.isNotEmpty ? 2 : 0,
                        ),
                        child: Text(
                          '确定 (${selectedPersons.length})',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
