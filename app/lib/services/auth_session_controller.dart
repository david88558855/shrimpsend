/// 云端会话阶段枚举 — 保留定义以兼容现有引用。
/// 云账户功能已移除，应用始终为 unauthenticated。
enum AuthSessionPhase {
  unauthenticated,
  validating,
  authenticated,
  sessionExpired,
  networkUnavailable,
}