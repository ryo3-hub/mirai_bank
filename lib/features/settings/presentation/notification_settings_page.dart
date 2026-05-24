import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/mirai_time_picker_sheet.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../../shared/widgets/weekday_picker.dart';
import '../application/setting_providers.dart';
import '../domain/app_setting.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingAsync = ref.watch(appSettingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('通知設定')),
      body: settingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('設定の読み込みに失敗: $e'),
          ),
        ),
        data: (setting) => ListView(
          children: [_NotificationSection(setting: setting)],
        ),
      ),
    );
  }
}

class _NotificationSection extends ConsumerWidget {
  const _NotificationSection({required this.setting});

  final AppSetting setting;

  Future<void> _toggleReminder(
      BuildContext context, WidgetRef ref, bool value) async {
    try {
      await ref.read(settingControllerProvider.notifier).setReminderEnabled(
            enabled: value,
            time: setting.reminderTimeOfDay,
            weekdays: setting.reminderWeekdays,
          );
    } catch (e) {
      if (context.mounted) {
        TopToast.show(context, message: '$e', isError: true);
      }
    }
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final picked = await MiraiTimePickerSheet.show(
      context,
      initialTime: setting.reminderTimeOfDay,
      title: 'リマインダー時刻',
    );
    if (picked == null) return;
    await ref.read(settingControllerProvider.notifier).setReminderTime(picked);
  }

  Future<void> _toggleWeekday(WidgetRef ref, int weekday) async {
    final current = setting.reminderWeekdays;
    final next = current.contains(weekday)
        ? (current.toSet()..remove(weekday))
        : (current.toSet()..add(weekday));
    await ref
        .read(settingControllerProvider.notifier)
        .setReminderWeekdays(next);
  }

  Future<void> _toggleAchievement(WidgetRef ref, bool value) async {
    await ref
        .read(settingControllerProvider.notifier)
        .setAchievementNotificationEnabled(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeLabel = setting.reminderTimeOfDay.format(context);
    final weekdaysEmpty =
        setting.reminderEnabled && setting.reminderWeekdays.isEmpty;
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text('学習リマインダー'),
          subtitle: const Text('指定時刻に通知'),
          value: setting.reminderEnabled,
          onChanged: (v) => _toggleReminder(context, ref, v),
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('リマインダー時刻'),
          subtitle: Text(timeLabel),
          enabled: setting.reminderEnabled,
          trailing: const Icon(Icons.edit_outlined),
          onTap:
              setting.reminderEnabled ? () => _pickTime(context, ref) : null,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: _WeekdayPickerSection(
            selected: setting.reminderWeekdays,
            enabled: setting.reminderEnabled,
            warn: weekdaysEmpty,
            onToggle: (w) => _toggleWeekday(ref, w),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.emoji_events_outlined),
          title: const Text('達成通知'),
          subtitle: const Text('目標達成・連続学習の節目で通知'),
          value: setting.achievementNotificationEnabled,
          onChanged: (v) => _toggleAchievement(ref, v),
        ),
      ],
    );
  }
}

/// 通知設定ページ用の曜日セクション。
///
/// 共通 `WeekdayPicker` をラップして、ヘッダーラベルと「曜日が空のとき」の
/// 警告メッセージを付与する。
class _WeekdayPickerSection extends StatelessWidget {
  const _WeekdayPickerSection({
    required this.selected,
    required this.enabled,
    required this.warn,
    required this.onToggle,
  });

  final Set<int> selected;
  final bool enabled;
  final bool warn;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '通知する曜日',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        WeekdayPicker(
          selected: selected,
          enabled: enabled,
          onToggle: onToggle,
        ),
        if (warn) ...[
          const SizedBox(height: 6),
          Text(
            '曜日を 1 つ以上選んでください（現在は通知されません）',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
