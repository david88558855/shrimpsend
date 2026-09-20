import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 离线模式下始终允许通过 —— 不需要登录
bool ensureLoggedInForRoute(BuildContext context, WidgetRef ref) {
  return true;
}