import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/version_info.dart';
import '../services/update_service.dart';

class CheckUpdatePage extends StatefulWidget {
  const CheckUpdatePage({super.key});

  @override
  State<CheckUpdatePage> createState() => _CheckUpdatePageState();
}

class _CheckUpdatePageState extends State<CheckUpdatePage>
    with SingleTickerProviderStateMixin {
  final UpdateService _updateService = UpdateService();

  bool _isChecking = true;
  bool _hasUpdate = false;
  bool _isDownloading = false;
  bool _isWaitingUserChoice = false;
  double _downloadProgress = 0.0;
  double _pausedProgress = 0.0;

  String _currentVersion = '1.0.0';
  int _currentBuildNumber = 1;

  /// 更新日志卡片展开状态（记录已展开的 section 索引）
  final Set<int> _expandedSections = {0};

  VersionInfo? _versionInfo;
  CancelToken? _cancelToken;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initVersion();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cancelToken?.cancel('用户取消下载');
    super.dispose();
  }

  Future<void> _initVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _currentVersion = packageInfo.version;
        _currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;
      });
      await _checkUpdate();
    } catch (e) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _checkUpdate() async {
    final versionInfo = await _updateService.checkUpdate(
      currentVersion: _currentVersion,
      currentBuildNumber: _currentBuildNumber,
    );

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      if (versionInfo != null) {
        // 不管有没有新版本，都存起来（含历史版本列表）
        _versionInfo = versionInfo;
        // 只有版本号不同才视为「有新版本」
        if (versionInfo.latestVersion != _currentVersion) {
          _hasUpdate = true;
        }
      }
    });

    if (_hasUpdate) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _downloadAndInstall() async {
    if (_versionInfo == null) return;

    _cancelToken = CancelToken();

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    await _updateService.downloadAndInstall(
      cancelToken: _cancelToken,
      versionInfo: _versionInfo!,
      onProgress: (progress) {
        if (_isWaitingUserChoice) return;
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      },
      onSuccess: () {
        if (mounted) {
          if (_isWaitingUserChoice) {
            setState(() {
              _isDownloading = false;
              _isWaitingUserChoice = false;
            });
            return;
          }
          setState(() {
            _isDownloading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('下载完成，正在安装...'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
          _showErrorDialog(error);
        }
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                '下载失败',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('确定'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGradientButton(
                      label: '重试',
                      onTap: () {
                        Navigator.pop(ctx);
                        _downloadAndInstall();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resumeDownload() async {
    if (_versionInfo == null) return;

    _cancelToken = CancelToken();

    await _updateService.downloadAndInstall(
      cancelToken: _cancelToken,
      versionInfo: _versionInfo!,
      onProgress: (progress) {
        if (_isWaitingUserChoice) return;
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      },
      onSuccess: () {
        if (mounted) {
          if (_isWaitingUserChoice) {
            setState(() {
              _isDownloading = false;
              _isWaitingUserChoice = false;
            });
            return;
          }
          setState(() {
            _isDownloading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('下载完成，正在安装...'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _isWaitingUserChoice = false;
          });
          _showErrorDialog(error);
        }
      },
    );
  }

  Future<bool> _showExitConfirmDialog() async {
    return await showModalBottomSheet<bool>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '取消下载？',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '当前正在下载更新，退出将中断下载进度。',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '已下载: ${(_pausedProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _buildGradientButton(
                    label: '继续下载',
                    onTap: () => Navigator.pop(ctx, false),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('确认退出', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  // ---------- UI Helpers ----------

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF8A4AF3)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A6CF7).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [Color(0xFF4A6CF7), Color(0xFF8A4AF3)],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
        ],
      ),
    );
  }

  // ========== 渲染结构化更新日志（直接从 VersionSection 渲染）==========

  /// 渲染单段描述文本（可带序号）
  Widget _buildSubItem(String item, {int index = 0, int total = 1}) {
    final showIndex = total > 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIndex)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6CF7).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A6CF7),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 30),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 渲染单个分类（飞书风格纯列表）
  Widget _buildSectionCard(VersionSection section, int index) {
    final isExpanded = _expandedSections.contains(index);
    final isBug = section.type == SectionType.bugfix;
    final icon = isBug ? Icons.bug_report_rounded : Icons.auto_awesome_rounded;
    final iconColor = isBug ? const Color(0xFFE53935) : const Color(0xFF4A6CF7);
    final label = isBug ? '修复' : '新增';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedSections.remove(index);
              } else {
                _expandedSections.add(index);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 12, color: iconColor),
                      const SizedBox(width: 3),
                      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: iconColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1F1F1F), height: 1.4),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: section.content.asMap().entries.map((e) => _buildSubItem(e.value, index: e.key, total: section.content.length)).toList(),
            ),
          ),
        Divider(height: 1, color: Colors.grey[100]),
      ],
    );
  }

  /// 渲染完整更新日志（直接从 VersionSection 列表渲染）
  Widget _buildStructuredLog(List<VersionSection> sections) {
    if (sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          '暂无更新日志',
          style: TextStyle(fontSize: 14, color: Colors.grey[400], height: 1.6),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(sections.length, (i) => _buildSectionCard(sections[i], i)),
      ),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDownloading,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_isDownloading && !_isWaitingUserChoice) {
          _cancelToken?.cancel('用户点击返回');
          _pausedProgress = _downloadProgress;
          setState(() => _isWaitingUserChoice = true);

          final navigator = Navigator.of(context);
          final shouldExit = await _showExitConfirmDialog();
          if (!mounted) return;

          if (shouldExit) {
            setState(() {
              _isDownloading = false;
              _isWaitingUserChoice = false;
            });
            navigator.pop();
          } else {
            setState(() => _isWaitingUserChoice = false);
            _resumeDownload();
          }
        } else if (_isWaitingUserChoice) {
          setState(() {
            _isDownloading = false;
            _isWaitingUserChoice = false;
          });
          if (mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 22),
            ),
            onPressed: () {
              if (_isDownloading) return;
              Navigator.pop(context);
            },
          ),
          title: const Text(
            '检查更新',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isChecking) return _buildCheckingView();
    if (_isDownloading) return _buildDownloadingView();
    if (_hasUpdate) return _buildUpdateView();
    return _buildNoUpdateView();
  }

  // ========== 1. 检查中 ==========

  Widget _buildCheckingView() {
    return SizedBox(
      key: const ValueKey('checking'),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A6CF7), Color(0xFF8A4AF3)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A6CF7).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.system_update_rounded, color: Colors.white, size: 48),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '正在检查更新',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          _buildDotLoader(),
        ],
      ),
    );
  }

  Widget _buildDotLoader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final delay = i * 0.2;
            final value = ((_pulseController.value + delay) % 1.0);
            final opacity = 0.3 + (0.7 * value);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A6CF7).withValues(alpha: opacity),
              ),
            );
          },
        );
      }),
    );
  }

  // ========== 2. 发现新版本 ==========

  Widget _buildUpdateView() {
    final info = _versionInfo!;
    return SizedBox(
      key: const ValueKey('update'),
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // ---- 版本号卡片 ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A6CF7), Color(0xFF7B5CF7)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A6CF7).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '新版本可用',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMiniVersionChip('v$_currentVersion', isCurrent: true),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.7), size: 20),
                      ),
                      _buildMiniVersionChip('v${info.latestVersion}', isCurrent: false),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '大小: ${info.formattedFileSize}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- 更新日志 ----
            _buildSectionTitle('更新内容'),
            _buildStructuredLog(info.sections.isNotEmpty ? info.sections : []),
            const SizedBox(height: 28),

            // ---- 按钮 ----
            SizedBox(
              width: double.infinity,
              height: 52,
              child: _buildGradientButton(
                label: '立即更新',
                onTap: _downloadAndInstall,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildMiniVersionChip(String label, {required bool isCurrent}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.white.withValues(alpha: 0.15) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isCurrent ? Colors.white : const Color(0xFF4A6CF7),
        ),
      ),
    );
  }

  // ========== 3. 已是最新 ==========

  Widget _buildNoUpdateView() {
    return SizedBox(
      key: const ValueKey('noupdate'),
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // 成功动画图标
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF10B981)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              '已是最新版本',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '当前版本 v$_currentVersion',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),

            // 版本信息卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow('版本名称', 'v$_currentVersion'),
                  const SizedBox(height: 12),
                  Container(height: 1, color: Colors.grey[100]),
                  const SizedBox(height: 12),
                  _buildInfoRow('更新时间', _versionInfo?.releaseDate ?? '--'),
                ],
              ),
            ),

            // 历史版本
            if (_versionInfo?.history.isNotEmpty ?? false) ...[
              const SizedBox(height: 28),
              _buildSectionTitle('更新记录'),
              _buildTimeline(_versionInfo!.history),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(List<VersionHistory> history) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(history.length, (i) {
          final item = history[i];
          final isLast = i == history.length - 1;
          return _buildTimelineItem(item, isLast: isLast);
        }),
      ),
    );
  }

  Widget _buildTimelineItem(VersionHistory history, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线指示器
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4A6CF7),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A6CF7).withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 内容
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'v${history.version}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Text(
                        history.releaseDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (history.sections.isNotEmpty)
                    _buildStructuredLog(history.sections)
                  else
                    Text('暂无更新日志', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== 4. 下载中 ==========

  Widget _buildDownloadingView() {
    return SizedBox(
      key: const ValueKey('downloading'),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 圆环进度
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: _downloadProgress,
                  strokeWidth: 10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A6CF7)),
                  backgroundColor: Colors.grey[200],
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_downloadProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6CF7),
                    ),
                  ),
                  if (_versionInfo != null)
                    Text(
                      _versionInfo!.formattedFileSize,
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 进度条
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _downloadProgress,
                minHeight: 4,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A6CF7)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isWaitingUserChoice
                ? _buildPausedHint()
                : _buildDownloadingHint(),
          ),
          if (_versionInfo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A6CF7).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'v${_versionInfo!.latestVersion}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A6CF7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDownloadingHint() {
    return Column(
      key: const ValueKey('active'),
      children: [
        const Text(
          '正在更新，请勿关闭软件',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 4),
        Text(
          '下载完成后将自动安装',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildPausedHint() {
    return Container(
      key: const ValueKey('paused'),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            '下载已暂停 (${(_pausedProgress * 100).toInt()}%)',
            style: const TextStyle(fontSize: 13, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
