import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../infrastructure/database/app_database.dart';

/// 全テーブルを JSON にシリアライズしてエクスポート / インポートするサービス
/// （issue #144）。クラウド DB は使わず、ユーザーがファイルを iCloud Drive /
/// Google Drive / メール等で運ぶ「バックアップ」用途。
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// このバージョンの JSON フォーマットで書き出している schemaVersion。
  /// 復元時はこの値と現行 DB の schemaVersion を比較して互換チェックを行う。
  static const int _formatVersion = 6;

  /// 現状の DB を JSON にシリアライズしてバックアップファイルを書き出し、
  /// そのファイルパスを返す。呼び出し側で `share_plus` 等に渡す想定。
  Future<File> exportToFile() async {
    final pkg = await PackageInfo.fromPlatform();
    // テーブル間で不整合なスナップショットにならないよう、読み出しは
    // 同一トランザクションで行う（issue #204）。
    final (categories, workSessions, timerPresets, goals, settings) =
        await _db.transaction(() async {
      return (
        await _db.select(_db.categories).get(),
        await _db.select(_db.workSessions).get(),
        await _db.select(_db.timerPresets).get(),
        await _db.select(_db.goals).get(),
        await _db.select(_db.settings).get(),
      );
    });

    final payload = <String, dynamic>{
      'schemaVersion': _formatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'appVersion': pkg.version,
      'buildNumber': pkg.buildNumber,
      'categories': categories.map(_categoryToJson).toList(),
      'workSessions': workSessions.map(_workSessionToJson).toList(),
      'timerPresets': timerPresets.map(_timerPresetToJson).toList(),
      'goals': goals.map(_goalToJson).toList(),
      'settings':
          settings.isNotEmpty ? _settingToJson(settings.first) : null,
    };

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now();
    final fileName =
        'mirai_bank_backup_${ts.year.toString().padLeft(4, '0')}'
        '${ts.month.toString().padLeft(2, '0')}'
        '${ts.day.toString().padLeft(2, '0')}_'
        '${ts.hour.toString().padLeft(2, '0')}'
        '${ts.minute.toString().padLeft(2, '0')}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    return file;
  }

  /// 指定したファイルから JSON を読み込んで DB を **上書き** する。
  /// `BackupFormatException` を返す可能性あり。トランザクション内で実行する
  /// ので途中で失敗しても中途半端な状態にならない。
  Future<void> importFromFile(File file) async {
    final raw = await file.readAsString();
    final dynamic decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const BackupFormatException('JSON のトップレベルがオブジェクトではありません');
    }
    final version = decoded['schemaVersion'];
    if (version is! int) {
      throw const BackupFormatException('schemaVersion が見つかりません');
    }
    if (version != _formatVersion) {
      throw BackupFormatException(
        'バックアップのバージョン ($version) が現アプリ ($_formatVersion) と一致しません',
      );
    }

    await _db.transaction(() async {
      // 上書き方針: 既存データを全削除してから挿入
      await _db.delete(_db.workSessions).go();
      await _db.delete(_db.goals).go();
      await _db.delete(_db.timerPresets).go();
      await _db.delete(_db.activeTimers).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.settings).go();

      final categories = (decoded['categories'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      for (final row in categories) {
        await _db.into(_db.categories).insert(_categoryFromJson(row));
      }
      final workSessions = (decoded['workSessions'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      for (final row in workSessions) {
        await _db.into(_db.workSessions).insert(_workSessionFromJson(row));
      }
      final timerPresets = (decoded['timerPresets'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      for (final row in timerPresets) {
        await _db.into(_db.timerPresets).insert(_timerPresetFromJson(row));
      }
      final goals = (decoded['goals'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      for (final row in goals) {
        await _db.into(_db.goals).insert(_goalFromJson(row));
      }
      final settings = decoded['settings'];
      if (settings is Map<String, dynamic>) {
        await _db.into(_db.settings).insert(_settingFromJson(settings));
      }
    });
  }

  // ---- シリアライズ ----

  Map<String, dynamic> _categoryToJson(CategoryRow row) => {
        'id': row.id,
        'name': row.name,
        'hourlyRate': row.hourlyRate,
        'colorCode': row.colorCode,
        'iconCode': row.iconCode,
        'sortOrder': row.sortOrder,
        'masterKey': row.masterKey,
        'createdAt': row.createdAt.toUtc().toIso8601String(),
        'updatedAt': row.updatedAt.toUtc().toIso8601String(),
        'deletedAt': row.deletedAt?.toUtc().toIso8601String(),
      };

  CategoriesCompanion _categoryFromJson(Map<String, dynamic> j) =>
      CategoriesCompanion.insert(
        id: j['id'] as String,
        name: j['name'] as String,
        hourlyRate: j['hourlyRate'] as int,
        colorCode: j['colorCode'] as String,
        iconCode: j['iconCode'] as String,
        sortOrder: Value(j['sortOrder'] as int? ?? 0),
        masterKey: Value(j['masterKey'] as String?),
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        deletedAt: Value(
          j['deletedAt'] == null
              ? null
              : DateTime.parse(j['deletedAt'] as String),
        ),
      );

  Map<String, dynamic> _workSessionToJson(WorkSessionRow row) => {
        'id': row.id,
        'categoryId': row.categoryId,
        'startTime': row.startTime.toUtc().toIso8601String(),
        'endTime': row.endTime.toUtc().toIso8601String(),
        'durationSec': row.durationSec,
        'amount': row.amount,
        'memo': row.memo,
        'inputMethod': row.inputMethod,
        'createdAt': row.createdAt.toUtc().toIso8601String(),
        'updatedAt': row.updatedAt.toUtc().toIso8601String(),
        'deletedAt': row.deletedAt?.toUtc().toIso8601String(),
      };

  WorkSessionsCompanion _workSessionFromJson(Map<String, dynamic> j) =>
      WorkSessionsCompanion.insert(
        id: j['id'] as String,
        categoryId: j['categoryId'] as String,
        startTime: DateTime.parse(j['startTime'] as String),
        endTime: DateTime.parse(j['endTime'] as String),
        durationSec: j['durationSec'] as int,
        amount: j['amount'] as int,
        memo: Value(j['memo'] as String?),
        inputMethod: j['inputMethod'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        deletedAt: Value(
          j['deletedAt'] == null
              ? null
              : DateTime.parse(j['deletedAt'] as String),
        ),
      );

  Map<String, dynamic> _timerPresetToJson(TimerPresetRow row) => {
        'id': row.id,
        'minutes': row.minutes,
        'label': row.label,
        'sortOrder': row.sortOrder,
        'isDefault': row.isDefault,
        'createdAt': row.createdAt.toUtc().toIso8601String(),
        'updatedAt': row.updatedAt.toUtc().toIso8601String(),
        'deletedAt': row.deletedAt?.toUtc().toIso8601String(),
      };

  TimerPresetsCompanion _timerPresetFromJson(Map<String, dynamic> j) =>
      TimerPresetsCompanion.insert(
        id: j['id'] as String,
        minutes: j['minutes'] as int,
        label: Value(j['label'] as String? ?? ''),
        sortOrder: Value(j['sortOrder'] as int? ?? 0),
        isDefault: Value(j['isDefault'] as bool? ?? false),
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        deletedAt: Value(
          j['deletedAt'] == null
              ? null
              : DateTime.parse(j['deletedAt'] as String),
        ),
      );

  Map<String, dynamic> _goalToJson(GoalRow row) => {
        'id': row.id,
        'type': row.type,
        'targetAmount': row.targetAmount,
        'categoryId': row.categoryId,
        'periodStart': row.periodStart?.toUtc().toIso8601String(),
        'periodEnd': row.periodEnd?.toUtc().toIso8601String(),
        'achievedAt': row.achievedAt?.toUtc().toIso8601String(),
        'sortOrder': row.sortOrder,
        'createdAt': row.createdAt.toUtc().toIso8601String(),
        'updatedAt': row.updatedAt.toUtc().toIso8601String(),
      };

  GoalsCompanion _goalFromJson(Map<String, dynamic> j) =>
      GoalsCompanion.insert(
        id: j['id'] as String,
        type: j['type'] as String,
        targetAmount: j['targetAmount'] as int,
        categoryId: Value(j['categoryId'] as String?),
        periodStart: Value(
          j['periodStart'] == null
              ? null
              : DateTime.parse(j['periodStart'] as String),
        ),
        periodEnd: Value(
          j['periodEnd'] == null
              ? null
              : DateTime.parse(j['periodEnd'] as String),
        ),
        achievedAt: Value(
          j['achievedAt'] == null
              ? null
              : DateTime.parse(j['achievedAt'] as String),
        ),
        sortOrder: Value(j['sortOrder'] as int? ?? 0),
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );

  Map<String, dynamic> _settingToJson(SettingRow row) => {
        'reminderEnabled': row.reminderEnabled,
        'reminderTime': row.reminderTime,
        'reminderWeekdaysCsv': row.reminderWeekdaysCsv,
        'achievementNotificationEnabled': row.achievementNotificationEnabled,
      };

  SettingsCompanion _settingFromJson(Map<String, dynamic> j) =>
      SettingsCompanion.insert(
        reminderEnabled: Value(j['reminderEnabled'] as bool? ?? false),
        reminderTime: Value(j['reminderTime'] as String? ?? '21:00'),
        reminderWeekdaysCsv: Value(
          j['reminderWeekdaysCsv'] as String? ?? '1,2,3,4,5,6,7',
        ),
        achievementNotificationEnabled: Value(
          j['achievementNotificationEnabled'] as bool? ?? true,
        ),
      );
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}
