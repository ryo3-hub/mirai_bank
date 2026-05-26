import 'package:flutter/material.dart';

import '../domain/legal_texts.dart';

/// プライバシーポリシー / 利用規約など、法務系の静的テキストを表示する
/// 共通ページ（issue #139 / #140）。
///
/// 外部 URL を使わずアプリ内表示で完結させているので、オフラインでも
/// 開ける。本文の改訂はアプリのバージョンアップで配信する。
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.sections,
    required this.updatedAt,
  });

  /// AppBar に表示するタイトル（「プライバシーポリシー」「利用規約」）。
  final String title;
  final List<LegalSection> sections;
  final String updatedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              '最終更新日: $updatedAt',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            for (final section in sections) ...[
              _LegalSectionView(section: section),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegalSectionView extends StatelessWidget {
  const _LegalSectionView({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return switch (section) {
      LegalHeading(:final text) => Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      LegalParagraph(:final text) => Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
            height: 1.7,
          ),
        ),
      LegalBullets(:final items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '・',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
    };
  }
}

/// プライバシーポリシー専用のラッパー（ルーティングから直接呼び出す用）。
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentPage(
      title: 'プライバシーポリシー',
      sections: LegalTexts.privacyPolicy,
      updatedAt: LegalTexts.privacyPolicyUpdatedAt,
    );
  }
}

/// 利用規約専用のラッパー（issue #140 で使う）。
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentPage(
      title: '利用規約',
      sections: LegalTexts.terms,
      updatedAt: LegalTexts.termsUpdatedAt,
    );
  }
}
