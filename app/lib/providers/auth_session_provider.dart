import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_session_controller.dart';

/// 始终返回 unauthenticated — 云账户功能已移除，应用以纯离线/LAN模式运行。
final authSessionPhaseProvider = Provider<AuthSessionPhase>((ref) {
  return AuthSessionPhase.unauthenticated;
});

/// 云端功能始终不可用。
final isCloudSessionActiveProvider = Provider<bool>((ref) {
  return false;
});