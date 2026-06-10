/// 分类类型
enum SectionType { feature, bugfix }

/// 版本更新日志分类
class VersionSection {
  final String title;
  final SectionType type;
  final List<String> content;

  VersionSection({
    required this.title,
    required this.type,
    required this.content,
  });

  factory VersionSection.fromJson(Map<String, dynamic> json) {
    return VersionSection(
      title: json['title'] ?? '',
      type: json['type'] == 'bugfix' ? SectionType.bugfix : SectionType.feature,
      content: (json['content'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type == SectionType.bugfix ? 'bugfix' : 'feature',
        'content': content,
      };
}

/// 版本信息模型
class VersionInfo {
  final String latestVersion; // 最新版本号，如 "1.0.1"
  final int buildNumber; // 构建号
  final String downloadUrl; // APK下载地址
  final int fileSize; // 文件大小（字节）
  final bool forceUpdate; // 是否强制更新
  final String updateLog; // 更新日志（纯文本，兼容旧格式）
  final String releaseDate; // 发布日期
  final List<VersionHistory> history; // 历史版本列表
  final List<VersionSection> sections; // 当前版本的分类日志（结构化）

  VersionInfo({
    required this.latestVersion,
    required this.buildNumber,
    required this.downloadUrl,
    required this.fileSize,
    required this.forceUpdate,
    required this.updateLog,
    required this.releaseDate,
    this.history = const [],
    this.sections = const [],
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      latestVersion: json['latest_version'] ?? '',
      buildNumber: json['build_number'] ?? 0,
      downloadUrl: json['download_url'] ?? '',
      fileSize: json['file_size'] ?? 0,
      forceUpdate: json['force_update'] ?? false,
      updateLog: json['update_log'] ?? '',
      releaseDate: json['release_date'] ?? '',
      history: (json['history'] as List?)
              ?.map((e) => VersionHistory.fromJson(e))
              .toList() ??
          [],
      sections: (json['sections'] as List?)
              ?.map((e) => VersionSection.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'latest_version': latestVersion,
        'build_number': buildNumber,
        'download_url': downloadUrl,
        'file_size': fileSize,
        'force_update': forceUpdate,
        'update_log': updateLog,
        'release_date': releaseDate,
        'history': history.map((e) => e.toJson()).toList(),
        'sections': sections.map((e) => e.toJson()).toList(),
      };

  /// 格式化文件大小
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}

/// 历史版本记录
class VersionHistory {
  final String version; // 版本号
  final int buildNumber; // 构建号
  final String releaseDate; // 发布日期
  final String updateLog; // 更新日志（纯文本，兼容旧格式）
  final List<VersionSection> sections; // 该版本的分类日志

  VersionHistory({
    required this.version,
    required this.buildNumber,
    required this.releaseDate,
    this.updateLog = '',
    this.sections = const [],
  });

  factory VersionHistory.fromJson(Map<String, dynamic> json) {
    return VersionHistory(
      version: json['version'] ?? '',
      buildNumber: json['build_number'] ?? 0,
      releaseDate: json['release_date'] ?? '',
      updateLog: json['update_log'] ?? '',
      sections: (json['sections'] as List?)
              ?.map((e) => VersionSection.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'build_number': buildNumber,
        'release_date': releaseDate,
        'update_log': updateLog,
        'sections': sections.map((e) => e.toJson()).toList(),
      };
}
