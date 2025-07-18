## 1.3.4
- 优化iOS推送通知处理逻辑

## 1.3.3
- 修复阿里云官方移除 iOS SDK 3.1.1 导致不能安装问题，改为不依赖指定版本
- Android SDK 升级至 3.9.5

## 1.3.2
- 修复点击推送通知冷启动App时onNotificationOpened无效的问题
- Android SDK 升级至 3.9.4.1
- iOS SDK 升级至 3.1.1

## 1.3.1

- iOS SDK 升级至 3.0.0
- 支持 iPhone 模拟器推送
- 移除已废弃的 iOS API
- 废弃 iOS 关闭推送消息通道(closeCCPChannel)
- optimize: print debug logs in debug mode only #20
- fix: handle both String and Int values in getAppMetaData #19

## 1.2.3

- 新增 iOS 关闭推送消息通道(closeCCPChannel)

## 1.2.2

- Android SDK 升级至 3.9.2
- 修复 iOS SDK 2.2.0 移除 AlicloudUtils 导致不能安装问题

## 1.2.0

- 移除对 iOS 10 以下的支持

## 1.1.2

- 新增一些 Android 平台的 API
- 更新 README.md

## 1.1.1

- Android SDK 升级至 3.9.1
- 集成 Google 推送通道
- 更新 example

## 1.1.0

- Android 集成辅助弹窗
- 更新 example
- 更新 README.md

## 1.0.0

- 集成 Android SDK 3.9.0，辅助通道 SDK 3.9.0
- 集成 iOS SDK 2.1.0，包含隐私描述文件
