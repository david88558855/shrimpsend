import 'package:flutter/material.dart';

import '../api/membership.dart';

/// 离线模式：始终允许添加 WebDAV 连接（无会员限制）
bool membershipCanAddWebDav(MembershipMe? me) => true;

/// 离线模式：始终允许，无需会员验证
Future<bool> ensureCanAddWebDav(
  BuildContext context, {
  MembershipMe? membership,
}) async => true;