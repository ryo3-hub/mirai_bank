import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// アプリ情報ページ（issue #143）。
/// バージョン / ビルド番号 / OSS ライセンス を表示する。
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('アプリについて')),
      body: SafeArea(
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final pkg = snapshot.data!;
            return ListView(
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.savings_outlined,
                      size: 44,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    pkg.appName.isEmpty ? 'mirai_bank' : pkg.appName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'バージョン ${pkg.version} (${pkg.buildNumber})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.collections_bookmark_outlined),
                  title: const Text('OSS ライセンス'),
                  subtitle: const Text('利用しているオープンソースの一覧'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: pkg.appName.isEmpty
                        ? 'mirai_bank'
                        : pkg.appName,
                    applicationVersion: '${pkg.version} (${pkg.buildNumber})',
                    applicationLegalese: '© 2026 ryo3-hub',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.savings_outlined,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
