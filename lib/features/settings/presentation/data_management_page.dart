import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../infrastructure/database/database_provider.dart';
import '../../../shared/notification/notification_service.dart';
import '../../../shared/notification/reminder_scheduler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/top_toast.dart';
import '../infrastructure/backup_service.dart';

/// データのエクスポート / インポートページ（issue #144）。
class DataManagementPage extends ConsumerStatefulWidget {
  const DataManagementPage({super.key});

  @override
  ConsumerState<DataManagementPage> createState() =>
      _DataManagementPageState();
}

class _DataManagementPageState extends ConsumerState<DataManagementPage> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final service = BackupService(ref.read(appDatabaseProvider));
      final file = await service.exportToFile();
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'mirai_bank データバックアップ',
      );
      if (mounted) {
        TopToast.show(context, message: 'エクスポートしました');
      }
    } catch (e) {
      if (mounted) {
        TopToast.show(
          context,
          message: 'エクスポートに失敗しました: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final ok = await showDeleteConfirmDialog(
      context: context,
      title: 'データを復元しますか？',
      message:
          '復元すると現在のデータはすべて上書きされます。\nこの操作は取り消せません。',
      deleteLabel: '復元する',
    );
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (picked == null || picked.files.single.path == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final file = File(picked.files.single.path!);
      final service = BackupService(ref.read(appDatabaseProvider));
      await service.importFromFile(file);
      // 復元後の状態に合わせて通知を再構築する（issue #195）。
      // - 復元で ActiveTimer は消えるため、常駐「計測中」通知と予約済み
      //   完了通知が残ると存在しないタイマーの通知が発火してしまう
      // - リマインダーは取り込んだ設定で再スケジュールする（OFF を復元
      //   した場合は旧予約のキャンセルになる）
      await NotificationService.instance.cancelOngoingTimer();
      await NotificationService.instance.cancelTimerCompletion();
      await ref.read(reminderSchedulerProvider).refresh();
      if (mounted) {
        TopToast.show(context, message: 'データを復元しました');
      }
    } on BackupFormatException catch (e) {
      if (mounted) {
        TopToast.show(
          context,
          message: 'ファイルの形式が不正です: ${e.message}',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        TopToast.show(
          context,
          message: '復元に失敗しました: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('データ管理')),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_outlined),
                  title: const Text('データをエクスポート'),
                  subtitle:
                      const Text('全データを JSON ファイルとして書き出します'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _busy ? null : _export,
                ),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('データを復元'),
                  subtitle: const Text('JSON ファイルから読み込みます'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _busy ? null : _import,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Text(
                    'エクスポートしたファイルは iCloud Drive / Google Drive / '
                    'メールなどで保存できます。'
                    '機種変更時は別端末でアプリをインストール後、'
                    '同じファイルを復元してください。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
            if (_busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
