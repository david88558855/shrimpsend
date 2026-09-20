import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppMode { online, offline }

/// 始终返回离线/LAN模式 —— 应用不再需要云账户
final appModeProvider = Provider<AppMode>((ref) {
  return AppMode.offline;
});

final isOfflineModeProvider = Provider<bool>((ref) {
  return true;
});

final isOnlineModeProvider = Provider<bool>((ref) {
  return false;
});

/// 始终为 true —— 应用始终以离线模式运行
final effectiveOfflineModeProvider = Provider<bool>((ref) {
  return true;
});