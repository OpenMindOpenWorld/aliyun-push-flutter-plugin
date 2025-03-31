import 'aliyun_push_flutter_platform_interface.dart';

/// 失败
const kAliyunPushFailedCode = "10002";

/// LogLevel debug
const kAliyunPushLogLevelDebug = 2;

/// LogLevel error
const kAliyunPushLogLevelError = 0;

/// LogLevel info
const kAliyunPushLogLevelInfo = 1;

/// 不支持
const kAliyunPushNotSupport = "10005";

/// 仅支持Android
const kAliyunPushOnlyAndroid = "10003";

/// 仅支持iOS
const kAliyunPushOnlyIOS = "10004";

/// 参数错误
const kAliyunPushParamsIllegal = "10001";

/// 成功
const kAliyunPushSuccessCode = "10000";

/// 本设备绑定账号
const kAliyunTargetAccount = 2;

/// 别名
const kAliyunTargetAlias = 3;

/// 本设备
const kAliyunTargetDevice = 1;

class AliyunPushFlutter {
  void addMessageReceiver({
    PushCallback? onNotification,
    PushCallback? onMessage,
    PushCallback? onNotificationOpened,
    PushCallback? onNotificationRemoved,
    PushCallback? onAndroidNotificationReceivedInApp,
    PushCallback? onAndroidNotificationClickedWithNoAction,
    PushCallback? onIOSChannelOpened,
    PushCallback? onIOSRegisterDeviceTokenSuccess,
    PushCallback? onIOSRegisterDeviceTokenFailed,
  }) {
    return AliyunPushFlutterPlatform.instance.addMessageReceiver(
      onNotification: onNotification,
      onMessage: onMessage,
      onNotificationOpened: onNotificationOpened,
      onNotificationRemoved: onNotificationRemoved,
      onAndroidNotificationReceivedInApp: onAndroidNotificationReceivedInApp,
      onAndroidNotificationClickedWithNoAction:
          onAndroidNotificationClickedWithNoAction,
      onIOSChannelOpened: onIOSChannelOpened,
      onIOSRegisterDeviceTokenSuccess: onIOSRegisterDeviceTokenSuccess,
      onIOSRegisterDeviceTokenFailed: onIOSRegisterDeviceTokenFailed,
    );
  }

  /// 添加别名
  Future<Map<dynamic, dynamic>> addAlias(String alias) async {
    return AliyunPushFlutterPlatform.instance.addAlias(alias);
  }

  /// 绑定账号
  Future<Map<dynamic, dynamic>> bindAccount(String account) async {
    return AliyunPushFlutterPlatform.instance.bindAccount(account);
  }

  /// 绑定手机号码
  Future<Map<dynamic, dynamic>> bindPhoneNumber(String phone) async {
    return AliyunPushFlutterPlatform.instance.bindPhoneNumber(phone);
  }

  /// 添加标签
  Future<Map<dynamic, dynamic>> bindTag(List<String> tags,
      {int target = kAliyunTargetDevice, String? alias}) async {
    return AliyunPushFlutterPlatform.instance
        .bindTag(tags, target: target, alias: alias);
  }

  /// 清除所有通知
  Future<Map<dynamic, dynamic>> clearNotifications() async {
    return AliyunPushFlutterPlatform.instance.clearNotifications();
  }

  /// 关闭 Android 推送日志
  Future<Map<dynamic, dynamic>> closeAndroidPushLog() async {
    return AliyunPushFlutterPlatform.instance.closeAndroidPushLog();
  }

  /// 创建 Android 平台的NotificationChannel
  Future<Map<dynamic, dynamic>> createAndroidChannel(
    String id,
    String name,
    int importance,
    String description, {
    String? groupId,
    bool? allowBubbles,
    bool? light,
    int? lightColor,
    bool? showBadge,
    String? soundPath,
    int? soundUsage,
    int? soundContentType,
    int? soundFlag,
    bool? vibration,
    List<int>? vibrationPatterns,
  }) async {
    return AliyunPushFlutterPlatform.instance.createAndroidChannel(
      id,
      name,
      importance,
      description,
      groupId: groupId,
      allowBubbles: allowBubbles,
      light: light,
      lightColor: lightColor,
      showBadge: showBadge,
      soundPath: soundPath,
      soundUsage: soundUsage,
      soundContentType: soundContentType,
      soundFlag: soundFlag,
      vibration: vibration,
      vibrationPatterns: vibrationPatterns,
    );
  }

  /// 创建通知通道的分组
  Future<Map<dynamic, dynamic>> createAndroidChannelGroup(
    String id,
    String name,
    String desc,
  ) async {
    return AliyunPushFlutterPlatform.instance
        .createAndroidChannelGroup(id, name, desc);
  }

  /// 获取APNs Token
  Future<String> getApnsDeviceToken() async {
    return AliyunPushFlutterPlatform.instance.getApnsDeviceToken();
  }

  /// 获取 deviceId
  Future<String> getDeviceId() async {
    return AliyunPushFlutterPlatform.instance.getDeviceId();
  }

  /// 注册厂商通道
  Future<Map<dynamic, dynamic>> initAndroidThirdPush() async {
    return AliyunPushFlutterPlatform.instance.initAndroidThirdPush();
  }

  /// 注册推送
  Future<Map<dynamic, dynamic>> initPush(
      {String? appKey, String? appSecret}) async {
    return AliyunPushFlutterPlatform.instance
        .initPush(appKey: appKey, appSecret: appSecret);
  }

  /// 检查通知状态
  Future<bool> isAndroidNotificationEnabled({String? id}) async {
    return AliyunPushFlutterPlatform.instance
        .isAndroidNotificationEnabled(id: id);
  }

  /// iOS 通知通道是否已打开
  Future<bool> isIOSChannelOpened() async {
    return AliyunPushFlutterPlatform.instance.isIOSChannelOpened();
  }

  /// iOS 关闭推送消息通道
  /// 此方法已废弃
  @Deprecated("This method is no longer recommended for use in the Aliyun iOS SDK and may be removed in future versions.")
  Future<Map<dynamic, dynamic>> closeCCPChannel() async {
    return AliyunPushFlutterPlatform.instance.closeCCPChannel();
  }

  /// 跳转到通知设置页面
  void jumpToAndroidNotificationSettings({String? id}) {
    return AliyunPushFlutterPlatform.instance
        .jumpToAndroidNotificationSettings(id: id);
  }

  /// 查询绑定别名
  Future<Map<dynamic, dynamic>> listAlias() async {
    return AliyunPushFlutterPlatform.instance.listAlias();
  }

  /// 查询标签列表
  Future<Map<dynamic, dynamic>> listTags(
      {int target = kAliyunTargetDevice}) async {
    return AliyunPushFlutterPlatform.instance.listTags(target: target);
  }

  /// 移除别名
  Future<Map<dynamic, dynamic>> removeAlias(String alias) async {
    return AliyunPushFlutterPlatform.instance.removeAlias(alias);
  }

  /// 设置 Android log 的级别
  Future<Map<dynamic, dynamic>> setAndroidLogLevel(int level) async {
    return AliyunPushFlutterPlatform.instance.setAndroidLogLevel(level);
  }

  /// 设置角标数
  Future<Map<dynamic, dynamic>> setIOSBadgeNum(int num) async {
    return AliyunPushFlutterPlatform.instance.setIOSBadgeNum(num);
  }

  /// 设置通知分组展示，只支持 Android
  Future<Map<dynamic, dynamic>> setNotificationInGroup(bool inGroup) async {
    return AliyunPushFlutterPlatform.instance.setNotificationInGroup(inGroup);
  }

  /// 设置插件日志
  void setPluginLogEnabled(bool enabled) {
    return AliyunPushFlutterPlatform.instance.setPluginLogEnabled(enabled);
  }

  /// App处于前台时显示通知
  Future<Map<dynamic, dynamic>> showIOSNoticeWhenForeground(bool enable) async {
    return AliyunPushFlutterPlatform.instance
        .showIOSNoticeWhenForeground(enable);
  }

  /// 同步角标数
  Future<Map<dynamic, dynamic>> syncIOSBadgeNum(int num) async {
    return AliyunPushFlutterPlatform.instance.syncIOSBadgeNum(num);
  }

  /// 开启iOS Debug日志
  @Deprecated("This method is no longer recommended for use in the Aliyun iOS SDK and may be removed in future versions.")
  Future<Map<dynamic, dynamic>> turnOnIOSDebug() async {
    return AliyunPushFlutterPlatform.instance.turnOnIOSDebug();
  }

  /// 解绑账号
  Future<Map<dynamic, dynamic>> unbindAccount() async {
    return AliyunPushFlutterPlatform.instance.unbindAccount();
  }

  /// 解绑手机号码
  Future<Map<dynamic, dynamic>> unbindPhoneNumber() async {
    return AliyunPushFlutterPlatform.instance.unbindPhoneNumber();
  }

  /// 移除标签
  Future<Map<dynamic, dynamic>> unbindTag(List<String> tags,
      {int target = kAliyunTargetDevice, String? alias}) async {
    return AliyunPushFlutterPlatform.instance
        .unbindTag(tags, target: target, alias: alias);
  }

  /// Android 查询推送通道状态
  Future<Map<dynamic, dynamic>> checkAndroidPushChannelStatus() async {
    return AliyunPushFlutterPlatform.instance.checkAndroidPushChannelStatus();
  }

  /// Android 开启推送通道
  Future<Map<dynamic, dynamic>> turnOnAndroidPushChannel() async {
    return AliyunPushFlutterPlatform.instance.turnOnAndroidPushChannel();
  }

  /// Android 关闭推送通道
  Future<Map<dynamic, dynamic>> turnOffAndroidPushChannel() async {
    return AliyunPushFlutterPlatform.instance.turnOffAndroidPushChannel();
  }
}
