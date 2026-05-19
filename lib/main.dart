import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'features/settings/application/setting_providers.dart';
import 'shared/notification/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP');
  await NotificationService.instance.init();
  final container = ProviderContainer();
  try {
    final setting = await container.read(settingRepositoryProvider).fetch();
    if (setting.reminderEnabled) {
      await NotificationService.instance
          .scheduleDailyReminder(setting.reminderTimeOfDay);
    }
  } catch (e, st) {
    debugPrint('Bootstrap error: $e\n$st');
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MiraiBankApp(),
    ),
  );
}
