import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences/locale_region_store.dart';
import 'chat_screen.dart';
import 'locale_region_gate_screen.dart';

/// Chooses gate → chat (no login required, pure local LAN mode).
class AppEntryScreen extends ConsumerStatefulWidget {
  const AppEntryScreen({
    super.key,
    required this.localeRegionStore,
    this.initialOfflineWithoutLogin = true,
  });

  final LocaleRegionStore localeRegionStore;
  final bool initialOfflineWithoutLogin;

  @override
  ConsumerState<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends ConsumerState<AppEntryScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LocaleRegionState>(
      valueListenable: widget.localeRegionStore.notifier,
      builder: (context, lr, _) {
        if (!lr.localeGateCompleted) {
          return LocaleRegionGateScreen(store: widget.localeRegionStore);
        }

        // Always go directly to chat screen — no login required.
        return const ChatScreen();
      },
    );
  }
}