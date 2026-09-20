---
name: project-offline-mode
description: ShrimpSend已移除云账户/登录/注册模块，改为纯本地LAN模式
type: project
---

ShrimpSend（虾传）前端已改为纯离线/LAN模式，不需要云账户。

**核心改动：**
- `app_mode_provider.dart` 始终返回 `AppMode.offline`
- `auth_provider.dart` 简化为始终未登录，提供 `getOrCreateOfflineUserId()` 从SharedPreferences获取离线ID
- `auth_session_provider.dart` 始终返回 `unauthenticated`
- `connection_resolution.dart` WebRTC/S3始终不可用
- `webdav_membership_gate.dart` 始终允许
- 已删除：login_screen, account_screen, qr_scanner_screen, qr_display_screen, membership_screen, auth_session_lifecycle

**Why:** 用户要求去掉所有账户/登录/注册相关模块，让应用变成不需要云账户的纯本地局域网工具。只改前端(app/)，后端暂不修改。

**How to apply:** 前端不需要任何云账户逻辑。如需添加新功能，应基于离线/LAN模式设计。仍有少量冗余文件（auth_route_guard, auth_session_provider/controller, membership相关）可清理但用户选择保留当前状态。