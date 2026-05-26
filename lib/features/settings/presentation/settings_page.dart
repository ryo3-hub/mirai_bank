import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/services/app_review_service.dart';
import '../../../shared/widgets/top_toast.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _requestReview(BuildContext context) async {
    try {
      await AppReviewService().requestExplicit();
    } catch (e) {
      if (context.mounted) {
        TopToast.show(
          context,
          message: 'レビュー画面を開けませんでした: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
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
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('履歴'),
              subtitle: const Text('過去のセッションを一覧・追加'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/history'),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('タイマープリセット'),
              subtitle: const Text('15分 / 30分 などの集中時間を編集'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/timer-presets'),
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
            const Divider(height: 24),
            const _SectionHeader(label: 'その他'),
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('アプリを評価する'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _requestReview(context),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('利用規約'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/terms'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('プライバシーポリシー'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/privacy'),
            ),
          ],
        ),
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
