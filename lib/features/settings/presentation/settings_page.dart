import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/setting_providers.dart';
import '../domain/app_setting.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingAsync = ref.watch(appSettingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          const _SectionHeader(label: '管理'),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('カテゴリ管理'),
            subtitle: const Text('学習カテゴリと時給を編集'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('目標設定'),
            subtitle: const Text('累計・期間の目標を管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/goals'),
          ),
          const Divider(height: 24),
          const _SectionHeader(label: '通知'),
          settingAsync.when(
            loading: () => const ListTile(
              title: LinearProgressIndicator(),
            ),
            error: (e, _) => ListTile(
              title: Text('設定の読み込みに失敗: $e'),
            ),
            data: (setting) => _NotificationSection(setting: setting),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _NotificationSection extends ConsumerWidget {
  const _NotificationSection({required this.setting});

  final AppSetting setting;

  Future<void> _toggleReminder(BuildContext context, WidgetRef ref, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(settingControllerProvider.notifier).setReminderEnabled(
            enabled: value,
            time: setting.reminderTimeOfDay,
          );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: setting.reminderTimeOfDay,
    );
    if (picked == null) return;
    await ref.read(settingControllerProvider.notifier).setReminderTime(picked);
  }

  Future<void> _toggleAchievement(WidgetRef ref, bool value) async {
    await ref
        .read(settingControllerProvider.notifier)
        .setAchievementNotificationEnabled(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeLabel = setting.reminderTimeOfDay.format(context);
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text('学習リマインダー'),
          subtitle: const Text('毎日決まった時間に通知'),
          value: setting.reminderEnabled,
          onChanged: (v) => _toggleReminder(context, ref, v),
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('リマインダー時刻'),
          subtitle: Text(timeLabel),
          enabled: setting.reminderEnabled,
          trailing: const Icon(Icons.edit_outlined),
          onTap: setting.reminderEnabled ? () => _pickTime(context, ref) : null,
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
