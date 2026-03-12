# HotCar Xcode 配置指南

## 编译状态
✅ 项目已成功编译 (2026-03-11)

---

## 必需的 Xcode Capabilities 配置

### 1. Push Notifications (推送通知)
**路径**: Target → Signing & Capabilities → + Capability → Push Notifications

**用途**:
- 本地通知 (计时完成提醒)
- 天气预警通知
- 保养提醒通知
- 智能提醒通知

**相关文件**:
- `NotificationService.swift`
- `WeatherAlertService.swift`
- `SmartReminderService.swift`

---

### 2. Background Modes (后台模式)
**路径**: Target → Signing & Capabilities → + Capability → Background Modes

**需要启用以下选项**:
- ✅ Location updates (位置更新)
- ✅ Background fetch (后台获取)
- ✅ Background processing (后台处理)
- ✅ Audio, AirPlay, and Picture in Picture (音频播放 - 用于提醒声音)

**用途**:
- 后台位置监控 (地理围栏)
- 后台计时器运行
- 后台天气数据更新

**相关文件**:
- `LocationService.swift`
- `GeoFenceService.swift`
- `CountdownTimer.swift`

---

### 3. Location (位置服务)
**路径**: Target → Signing & Capabilities → + Capability → Location

**需要在 Info.plist 中添加以下权限说明**:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>HotCar needs your location to provide accurate weather data and warm-up recommendations.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>HotCar needs your location to monitor geo-fences and provide smart reminders.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>HotCar needs your location to monitor geo-fences and provide smart reminders.</string>
```

**用途**:
- 获取当前位置天气
- 地理围栏监控
- 智能提醒

**相关文件**:
- `LocationService.swift`
- `GeoFenceService.swift`

---

### 4. App Groups (应用组)
**路径**: Target → Signing & Capabilities → + Capability → App Groups

**配置**:
- 点击 "+" 添加 App Group
- 格式: `group.your.bundle.identifier`

**用途**:
- 主应用与 Widget Extension 共享数据
- Live Activity 数据同步

**相关文件**:
- `WidgetDataService.swift`
- `LiveActivityManager.swift`

---

### 5. Siri (Siri 快捷指令)
**路径**: Target → Signing & Capabilities → + Capability → Siri

**用途**:
- "开始预热" Siri 快捷指令
- "检查温度" Siri 快捷指令

**相关文件**:
- `StartWarmUpIntent.swift`
- `CheckTemperatureIntent.swift`
- `Intents.intentdefinition`

---

## Info.plist 配置

### 必需的权限说明

```xml
<!-- 位置权限 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>HotCar needs your location to provide accurate weather data and warm-up recommendations.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>HotCar needs your location to monitor geo-fences and provide smart reminders.</string>

<!-- 通知权限 -->
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>processing</string>
    <string>audio</string>
</array>

<!-- 后台任务标识符 -->
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.hotcar.weather.refresh</string>
    <string>com.hotcar.reminder.check</string>
</array>
```

---

## Widget Extension 配置

### 创建 Widget Extension
1. File → New → Target
2. 选择 "Widget Extension"
3. 命名为 "hotcarWidgetExtension"
4. 勾选 "Include Configuration Intent" (可选)

### Widget Extension Capabilities
- App Groups (与主应用相同的 group)
- Push Notifications (可选)

---

## Live Activity 配置

### ActivityKit 权限
在 Info.plist 中添加:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

### Push to Start (可选)
如果需要从服务器启动 Live Activity:
```xml
<key>NSSupportsLiveActivitiesFrequentPushEnablement</key>
<true/>
```

---

## 构建设置

### Deployment Target
- iOS 16.4+ (支持 Live Activity)
- iOS 17.0+ (支持完整的 Live Activity 功能)

### Swift Version
- Swift 5.9+

### Architectures
- arm64 (真机)
- x86_64 + arm64 (模拟器)

---

## 已修复的编译问题

### 1. Codable 问题
- ✅ 修复 `CLLocationCoordinate2D` 不支持 Codable
- ✅ 创建 `CLLocationCoordinate2DCodable` 包装器

### 2. 类型不匹配
- ✅ 修复 `CLLocation` vs `CLLocationCoordinate2D` 类型问题
- ✅ 修复 `Color.cardBackground` → `Color.backgroundCard`
- ✅ 修复 `Font.hotCarCaption2` → `Font.hotCarFootnote`

### 3. 异步问题
- ✅ 添加 `@MainActor` 到 `NotificationService`
- ✅ 修复 `setNotificationCategories` 不需要 await
- ✅ 修复 `UNNotificationSound` 完整类型引用

### 4. 缺失组件
- ✅ 创建 `EmptyStateView` 组件
- ✅ 添加缺失的 `import UserNotifications`
- ✅ 添加缺失的 `import Combine`

### 5. 属性访问问题
- ✅ 修复 `CountdownTimer.$progress` → 直接计算 `progress`
- ✅ 修复 `MaintenanceService.getReminders` → `getScheduledReminders`
- ✅ 修复 `WeatherAlert.isRead` 从 `let` 改为 `var`

---

## 新增功能模块

### P0 优先级 (已完成)
1. ✅ CountdownTimer 集成到 HomeViewModel
2. ✅ TimerButton 进度环绑定
3. ✅ Live Activity 实时进度
4. ✅ 手动时间调整 UI

### P1 优先级 (已完成)
5. ✅ 通知声音设置
6. ✅ StatisticsService 增强 (fuelSaved, CO2Saved)
7. ✅ 保养提醒入口

### P2 优先级 (已完成)
8. ✅ WeatherAlertService (天气预警)
9. ✅ SmartReminderService (智能提醒)
10. ✅ EngineIdleMonitor (怠速监控)
11. ✅ GeoFenceService (地理围栏)
12. ✅ IdleAlertService (怠速预警)

---

## 测试建议

### 功能测试清单
- [ ] 计时器启动/暂停/停止
- [ ] 进度环动画
- [ ] Live Activity 显示
- [ ] 本地通知接收
- [ ] 天气数据获取
- [ ] 地理围栏触发
- [ ] 智能提醒调度
- [ ] 保养提醒显示
- [ ] 设置保存/加载

### 单元测试
运行测试:
```bash
xcodebuild test -project hotcar.xcodeproj -scheme hotcar -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

---

## 常见问题

### Q: 编译报错 "No such module 'ActivityKit'"
A: 确保部署目标设置为 iOS 16.4 或更高版本

### Q: Widget 不显示数据
A: 检查 App Groups 是否正确配置，确保主应用和 Widget 使用相同的 group identifier

### Q: 位置服务不工作
A: 检查 Info.plist 中的位置权限描述是否正确添加

### Q: 后台任务不执行
A: 检查 Background Modes 是否正确启用，BGTaskSchedulerPermittedIdentifiers 是否配置

---

## 联系信息
如有问题，请检查以上配置或参考 Apple 官方文档。
