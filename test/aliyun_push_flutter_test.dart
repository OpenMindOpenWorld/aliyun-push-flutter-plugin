import 'package:flutter_test/flutter_test.dart';
import 'package:aliyun_push_flutter/aliyun_push_flutter.dart';
import 'package:aliyun_push_flutter/aliyun_push_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAliyunPushFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AliyunPushFlutterPlatform {
  @override
  Future<Map> addAlias(String alias) {
    // TODO: implement addAlias
    throw UnimplementedError();
  }

  @override
  void addMessageReceiver(
      {PushCallback? onNotification,
      PushCallback? onMessage,
      PushCallback? onNotificationOpened,
      PushCallback? onNotificationRemoved,
      PushCallback? onAndroidNotificationReceivedInApp,
      PushCallback? onAndroidNotificationClickedWithNoAction,
      PushCallback? onIOSChannelOpened,
      PushCallback? onIOSRegisterDeviceTokenSuccess,
      PushCallback? onIOSRegisterDeviceTokenFailed}) {
    // TODO: implement addMessageReceiver
  }

  @override
  Future<Map> bindAccount(String account) {
    // TODO: implement bindAccount
    throw UnimplementedError();
  }

  @override
  Future<Map> bindPhoneNumber(String phone) {
    // TODO: implement bindPhoneNumber
    throw UnimplementedError();
  }

  @override
  Future<Map> bindTag(List<String> tags,
      {int target = kAliyunTargetDevice, String? alias}) {
    // TODO: implement bindTag
    throw UnimplementedError();
  }

  @override
  Future<Map> clearNotifications() {
    // TODO: implement clearNotifications
    throw UnimplementedError();
  }

  @override
  Future<Map> closeAndroidPushLog() {
    // TODO: implement closeAndroidPushLog
    throw UnimplementedError();
  }

  @override
  Future<Map> createAndroidChannel(
      String id, String name, int importance, String description,
      {String? groupId,
      bool? allowBubbles,
      bool? light,
      int? lightColor,
      bool? showBadge,
      String? soundPath,
      int? soundUsage,
      int? soundContentType,
      int? soundFlag,
      bool? vibration,
      List<int>? vibrationPatterns}) {
    // TODO: implement createAndroidChannel
    throw UnimplementedError();
  }

  @override
  Future<Map> createAndroidChannelGroup(String id, String name, String desc) {
    // TODO: implement createAndroidChannelGroup
    throw UnimplementedError();
  }

  @override
  Future<String> getApnsDeviceToken() {
    // TODO: implement getApnsDeviceToken
    throw UnimplementedError();
  }

  @override
  Future<String> getDeviceId() {
    // TODO: implement getDeviceId
    throw UnimplementedError();
  }

  @override
  Future<Map> initAndroidThirdPush() {
    // TODO: implement initAndroidThirdPush
    throw UnimplementedError();
  }

  @override
  Future<Map> initPush({String? appKey, String? appSecret}) {
    // TODO: implement initPush
    throw UnimplementedError();
  }

  @override
  Future<bool> isAndroidNotificationEnabled({String? id}) {
    // TODO: implement isAndroidNotificationEnabled
    throw UnimplementedError();
  }

  @override
  Future<bool> isIOSChannelOpened() {
    // TODO: implement isIOSChannelOpened
    throw UnimplementedError();
  }

  @override
  void jumpToAndroidNotificationSettings({String? id}) {
    // TODO: implement jumpToAndroidNotificationSettings
  }

  @override
  Future<Map> listAlias() {
    // TODO: implement listAlias
    throw UnimplementedError();
  }

  @override
  Future<Map> listTags({int target = kAliyunTargetDevice}) {
    // TODO: implement listTags
    throw UnimplementedError();
  }

  @override
  Future<Map> removeAlias(String alias) {
    // TODO: implement removeAlias
    throw UnimplementedError();
  }

  @override
  Future<Map> setAndroidLogLevel(int level) {
    // TODO: implement setAndroidLogLevel
    throw UnimplementedError();
  }

  @override
  Future<Map> setIOSBadgeNum(int num) {
    // TODO: implement setIOSBadgeNum
    throw UnimplementedError();
  }

  @override
  Future<Map> setNotificationInGroup(bool inGroup) {
    // TODO: implement setNotificationInGroup
    throw UnimplementedError();
  }

  @override
  void setPluginLogEnabled(bool enabled) {
    // TODO: implement setPluginLogEnabled
  }

  @override
  Future<Map> showIOSNoticeWhenForeground(bool enable) {
    // TODO: implement showIOSNoticeWhenForeground
    throw UnimplementedError();
  }

  @override
  Future<Map> syncIOSBadgeNum(int num) {
    // TODO: implement syncIOSBadgeNum
    throw UnimplementedError();
  }

  @override
  Future<Map> turnOnIOSDebug() {
    // TODO: implement turnOnIOSDebug
    throw UnimplementedError();
  }

  @override
  Future<Map> unbindAccount() {
    // TODO: implement unbindAccount
    throw UnimplementedError();
  }

  @override
  Future<Map> unbindPhoneNumber() {
    // TODO: implement unbindPhoneNumber
    throw UnimplementedError();
  }

  @override
  Future<Map> unbindTag(List<String> tags,
      {int target = kAliyunTargetDevice, String? alias}) {
    // TODO: implement unbindTag
    throw UnimplementedError();
  }

  @override
  Future<Map> checkAndroidPushChannelStatus() {
    // TODO: implement checkAndroidPushChannelStatus
    throw UnimplementedError();
  }

  @override
  Future<Map> turnOffAndroidPushChannel() {
    // TODO: implement turnOffAndroidPushChannel
    throw UnimplementedError();
  }

  @override
  Future<Map> turnOnAndroidPushChannel() {
    // TODO: implement turnOnAndroidPushChannel
    throw UnimplementedError();
  }

  @override
  Future<Map> setIOSLogLevel(int level) {
    // TODO: implement setIOSLogLevel
    throw UnimplementedError();
  }
}

void main() {}
