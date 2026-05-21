import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('通知設定'),
            subtitle: const Text('リマインダー・達成通知'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/notifications'),
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
