import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../logger.dart';

const _keyOfflineUserId = 'ultrasend_offline_user_id';

/// 获取已存储的云账户 userId（离线模式下始终返回 null）
Future<String?> getStoredUserId() async => null;

/// 获取或创建离线用户 ID（持久化到 SharedPreferences）
Future<String> getOrCreateOfflineUserId() async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString(_keyOfflineUserId);
  if (id != null && id.isNotEmpty) return id;
  id = const Uuid().v4();
  await prefs.setString(_keyOfflineUserId, id);
  return id;
}

/// 简化的认证状态 —— 应用始终以离线/LAN模式运行，不需要云账户
class AuthState {
  final bool isLoggedIn;
  final String? userId;
  final String? accessToken;

  const AuthState({
    this.isLoggedIn = false,
    this.userId,
    this.accessToken,
  });
}

/// 认证通知器 —— 始终返回未登录状态（离线模式不需要云账户）
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> loadFromStorage() async {
    logAuth.info('AuthNotifier loadFromStorage: offline mode, no auth needed');
  }

  Future<void> logout() async {
    logAuth.info('AuthNotifier logout: no-op in offline mode');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});