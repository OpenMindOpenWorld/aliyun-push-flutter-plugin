import AlicloudUtils
import CloudPushSDK
import Flutter
import UserNotifications

let KEY_CODE = "code"
let KEY_ERROR_MSG = "errorMsg"

let CODE_SUCCESS = "10000"
let CODE_PARAMS_ILLEGAL = "10001"
let CODE_FAILED = "10002"
let CODE_NO_NET = "10003"

func PushLogD(_ format: String, _ args: CVarArg...) {
  if AliyunPushLog.isLogEnabled() {
    NSLog("[CloudPush Debug]: \(String(format: format, arguments: args))")
  }
}

func PushLogE(_ format: String, _ args: CVarArg...) {
  if AliyunPushLog.isLogEnabled() {
    NSLog("[CloudPush Error]: \(String(format: format, arguments: args))")
  }
}

public class AliyunPushPlugin: NSObject, FlutterPlugin {
  var channel: FlutterMethodChannel?
  var notificationCenter: UNUserNotificationCenter?
  var showNoticeWhenForeground: Bool = false
  var deviceToken: Data?
  var remoteNotification: [AnyHashable: Any]?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "aliyun_push", binaryMessenger: registrar.messenger())
    let instance = AliyunPushPlugin()
    instance.channel = channel
    registrar.addApplicationDelegate(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initPushSdk":
      initPushSdk(call, result: result)
    case "getDeviceId":
      getDeviceId(result: result)
    case "turnOnDebug":
      turnOnDebug(result: result)
    case "bindAccount":
      bindAccount(call, result: result)
    case "unbindAccount":
      unbindAccount(result: result)
    case "addAlias":
      addAlias(call, result: result)
    case "removeAlias":
      removeAlias(call, result: result)
    case "listAlias":
      listAlias(result: result)
    case "bindTag":
      bindTag(call, result: result)
    case "unbindTag":
      unbindTag(call, result: result)
    case "listTags":
      listTags(call, result: result)
    case "showNoticeWhenForeground":
      showNoticeWhenForeground(call, result: result)
    case "setBadgeNum":
      setBadgeNum(call, result: result)
    case "syncBadgeNum":
      if let arguments = call.arguments as? [String: Any], let badgeNum = arguments["badgeNum"] as? Int {
        syncBadgeNum(badgeNum, result: result)
      }
    case "getApnsDeviceToken":
      getApnsDeviceToken(result: result)
    case "isChannelOpened":
      isChannelOpened(result: result)
    case "setPluginLogEnabled":
      setPluginLogEnabled(call)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// 设置角标数
  func setBadgeNum(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
      let badgeNum = arguments["badgeNum"] as? Int
    else {
      result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "Invalid badge number"])
      return
    }

    guard badgeNum >= 0 else {
      result([
        KEY_CODE: CODE_PARAMS_ILLEGAL,
        KEY_ERROR_MSG: "badgeNum must be a non-negative integer",
      ])
      return
    }

    UIApplication.shared.applicationIconBadgeNumber = badgeNum
    result([KEY_CODE: CODE_SUCCESS])
  }

  /// 同步角标数
  func syncBadgeNum(_ badgeNum: Int, result: FlutterResult?) {
    CloudPushSDK.syncBadgeNum(UInt(badgeNum)) { res in
      if let res = res, res.success {
        PushLogD("Sync badge num: [%d] success.", badgeNum)
        result?([KEY_CODE: CODE_SUCCESS])
      } else {
        PushLogD(
          "Sync badge num: [%d] failed, error: %@", badgeNum,
          (res?.error as NSError?)?.description ?? "")
        result?([KEY_CODE: CODE_FAILED, KEY_ERROR_MSG: (res?.error as NSError?)?.description ?? ""])
      }
    }
  }

  /// 获取设备Id
  func getDeviceId(result: @escaping FlutterResult) {
    result(CloudPushSDK.getDeviceId() ?? "")
  }

  /// 打开推送SDK的日志
  func turnOnDebug(result: @escaping FlutterResult) {
    CloudPushSDK.turnOnDebug()
    result([KEY_CODE: CODE_SUCCESS])
  }

  /// App处于前台时显示通知
  func showNoticeWhenForeground(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
      let enable = arguments["enable"] as? Bool
    else {
      result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "Invalid enable value"])
      return
    }
    showNoticeWhenForeground = enable
    result([KEY_CODE: CODE_SUCCESS])
  }

  /// 获取APNs Token
  func getApnsDeviceToken(result: @escaping FlutterResult) {
    result(CloudPushSDK.getApnsDeviceToken())
  }

  /// 绑定账号
  func bindAccount(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
      let account = arguments["account"] as? String
    else {
      result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "account can not be empty"])
      return
    }

    CloudPushSDK.bindAccount(account) { res in
      if let res = res, res.success {
        result([KEY_CODE: CODE_SUCCESS])
      } else {
        result([KEY_CODE: CODE_FAILED, KEY_ERROR_MSG: (res?.error as NSError?)?.description ?? ""])
      }
    }
  }

  /// 解绑账号
  func unbindAccount(result: @escaping FlutterResult) {
    CloudPushSDK.unbindAccount { res in
      if let res = res, res.success {
        result([KEY_CODE: CODE_SUCCESS])
      } else {
        result([KEY_CODE: CODE_FAILED, KEY_ERROR_MSG: (res?.error as NSError?)?.description ?? ""])
      }
    }
  }

  /// 添加别名
  func addAlias(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
      let alias = arguments["alias"] as? String
    else {
      result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "alias can not be empty"])
      return
    }

    CloudPushSDK.addAlias(alias) { res in
      if let res = res, res.success {
        result([KEY_CODE: CODE_SUCCESS])
      } else {
        result([KEY_CODE: CODE_FAILED, KEY_ERROR_MSG: (res?.error as NSError?)?.description ?? ""])
      }
    }
  }

  /// 移除别名
  func removeAlias(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
      let alias = arguments["alias"] as? String
    else {
      result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "alias can not be empty"])
      return
    }

    CloudPushSDK.removeAlias(alias) { res in
      if let res = res, res.success {
        result([KEY_CODE: CODE_SUCCESS])
      } else {
        result([KEY_CODE: CODE_FAILED, KEY_ERROR_MSG: (res?.error as NSError?)?.description ?? ""])
      }
    }
  }

  /// 查询别名
  func listAlias(result: @escaping FlutterResult) {
    CloudPushSDK.listAliases { res in
      if let res = res, res.success {
        result([KEY_CODE: CODE_SUCCESS, "aliasList": res.data ?? []])
      } else {
        result([KEY_CODE: CODE_FAILED, KEY_ERROR_MSG: (res?.error as NSError?)?.description ?? ""])
      }
    }
  }

  /// 添加标签
  func bindTag(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
      let tags = arguments["tags"] as? [String],
      !tags.isEmpty
    else {
      result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "tags can not be empty"])
      return
    }

    let alias = arguments["alias"] as? String
    let target = arguments["target"] as? Int ?? 1

    CloudPushSDK.bindTag(Int32(target), withTags: tags, withAlias: alias) { res in
      if let res = res, res.success {
        result([KEY_CODE: CODE_SUCCESS])
      } else {
        PushLogD("#### ===> %@", (res?.error as NSError?)?.description ?? "")
        result([KEY_CODE: CODE_FAILED, KEY_ERROR_MSG: (res?.error as NSError?)?.description ?? ""])
      }
    }
  }

  /// 移除标签
  func unbindTag(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
      let tags = arguments["tags"] as? [String],
      !tags.isEmpty
    else {
      result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "tags can not be empty"])
      return
    }

    let alias = arguments["alias"] as? String
    let target = arguments["target"] as? Int ?? 1

    CloudPushSDK.unbindTag(Int32(target), withTags: tags, withAlias: alias) { res in
      if let res = res, res.success {
        result([KEY_CODE: CODE_SUCCESS])
      } else {
        result([KEY_CODE: CODE_FAILED, KEY_ERROR_MSG: (res?.error as NSError?)?.description ?? ""])
      }
    }
  }

  /// 查询标签列表
  func listTags(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any] else {
      result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "Invalid arguments"])
      return
    }

    let target = arguments["target"] as? Int ?? 1

    CloudPushSDK.listTags(Int32(target)) { res in
      if let res = res, res.success {
        result([KEY_CODE: CODE_SUCCESS, "tagsList": res.data ?? []])
      } else {
        result([KEY_CODE: CODE_FAILED, KEY_ERROR_MSG: (res?.error as NSError?)?.description ?? ""])
      }
    }
  }

  /// 设置是否开启插件日志
  func setPluginLogEnabled(_ call: FlutterMethodCall) {
    if let arguments = call.arguments as? [String: Any],
      let enabled = arguments["enabled"] as? Bool
    {
      if enabled {
        AliyunPushLog.enableLog()
      } else {
        AliyunPushLog.disableLog()
      }
    }
  }

  /// 通知通道是否已打开
  func isChannelOpened(result: @escaping FlutterResult) {
    result(CloudPushSDK.isChannelOpened())
  }
}

// init push sdk
extension AliyunPushPlugin {
  func isNetworkReachable() -> Bool {
    return AlicloudReachabilityManager.shareInstance().checkInternetConnection()
  }

  func registerAPNs() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if granted {
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
  }

  func initPushSdk(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
      let appKey = arguments["appKey"] as? String,
      let appSecret = arguments["appSecret"] as? String
    else {
      result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "appKey or appSecret config error"])
      return
    }

    CloudPushSDK.turnOnDebug()

    guard !appKey.isEmpty, !appSecret.isEmpty else {
      result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "appKey or appSecret config error"])
      return
    }

    guard isNetworkReachable() else {
      result([KEY_CODE: CODE_NO_NET, KEY_ERROR_MSG: "no network"])
      return
    }

    registerAPNs()

    CloudPushSDK.asyncInit(appKey, appSecret: appSecret) { res in
      if let res = res, res.success {
        PushLogD("Push SDK init success, deviceId: %@.", CloudPushSDK.getDeviceId() ?? "")
        result([KEY_CODE: CODE_SUCCESS])
      } else {
        PushLogD(
          "###### Push SDK init failed, error: %@", (res?.error as NSError?)?.description ?? "")
        NSLog(
          "=======> Push SDK init failed, error: %@", (res?.error as NSError?)?.description ?? "")
        result([KEY_CODE: CODE_FAILED, KEY_ERROR_MSG: (res?.error as NSError?)?.description ?? ""])
      }
    }

    listenerOnChannelOpened()
    registerMessageReceive()
  }

  private func listenerOnChannelOpened() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(onChannelOpened(_:)),
      name: NSNotification.Name(rawValue: "CCPDidChannelConnectedSuccess"), object: nil)
  }

  @objc private func onChannelOpened(_ notification: Notification) {
    self.channel?.invokeMethod("onChannelOpened", arguments: [:])
  }

  private func registerMessageReceive() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(onMessageReceived(_:)),
      name: NSNotification.Name(rawValue: "CCPDidReceiveMessageNotification"), object: nil)
  }

  @objc private func onMessageReceived(_ notification: Notification) {
    guard let message = notification.object as? CCPSysMessage else { return }
    let dic: [String: Any] = [
      "title": message.title ?? "",
      "body": message.body ?? "",
    ]
    self.channel?.invokeMethod("onMessage", arguments: dic)
  }
}

extension AliyunPushPlugin: UNUserNotificationCenterDelegate {
  func handleIOS10Notification(_ notification: UNNotification) {
    let request = notification.request
    let content = request.content
    let userInfo = content.userInfo

    // 通知角标数清0
    UIApplication.shared.applicationIconBadgeNumber = 0
    // 同步角标数到服务端
    syncBadgeNum(0, result: nil)

    // 通知打开回执上报
    CloudPushSDK.sendNotificationAck(userInfo)
    channel?.invokeMethod("onNotification", arguments: userInfo)
  }

  public func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if showNoticeWhenForeground {
      // 通知弹出，且带有声音、内容和角标
      completionHandler([.sound, .alert, .badge])
    } else {
      // 处理iOS 10通知，并上报通知打开回执
      handleIOS10Notification(notification)
      completionHandler([])
    }
  }

  public func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userAction = response.actionIdentifier
    if userAction == UNNotificationDefaultActionIdentifier {
      CloudPushSDK.sendNotificationAck(response.notification.request.content.userInfo)
      channel?.invokeMethod(
        "onNotificationOpened", arguments: response.notification.request.content.userInfo)
    }
    if userAction == UNNotificationDismissActionIdentifier {
      CloudPushSDK.sendDeleteNotificationAck(response.notification.request.content.userInfo)
      channel?.invokeMethod(
        "onNotificationRemoved", arguments: response.notification.request.content.userInfo)
    }

    completionHandler()
  }
}

extension AliyunPushPlugin {
  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    NSLog("###### didFinishLaunchingWithOptions launchOptions \(String(describing: launchOptions))")
    if let options = launchOptions,
      let remoteNotification = options[UIApplication.LaunchOptionsKey.remoteNotification]
        as? [AnyHashable: Any]
    {
      self.remoteNotification = remoteNotification
    }
    return true
  }

  public func application(
    _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    CloudPushSDK.registerDevice(deviceToken) { res in
      if let res = res, res.success {
        PushLogD(
          "Register deviceToken successfully, deviceToken: %@", CloudPushSDK.getApnsDeviceToken())
        let dic = ["apnsDeviceToken": CloudPushSDK.getApnsDeviceToken()]
        self.channel?.invokeMethod("onRegisterDeviceTokenSuccess", arguments: dic)
      } else {
        PushLogD(
          "Register deviceToken failed, error: %@", (res?.error as NSError?)?.description ?? "")
        let dic = ["error": (res?.error as NSError?)?.description ?? ""]
        self.channel?.invokeMethod("onRegisterDeviceTokenFailed", arguments: dic)
      }
    }
    PushLogD("####### ===> APNs register success")
  }

  public func application(
    _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    let dic = ["error": error.localizedDescription]
    self.channel?.invokeMethod("onRegisterDeviceTokenFailed", arguments: dic)
    PushLogD("####### ===> APNs register failed, %@", error.localizedDescription)
  }

  public func application(
    _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) -> Bool {
    /// TODO: 此方法可能会触发两次

    PushLogD("onNotification, userInfo = [%@]", userInfo)
    NSLog("###### onNotification  userInfo = [%@]", userInfo)

    CloudPushSDK.sendNotificationAck(userInfo)

    channel?.invokeMethod("onNotification", arguments: userInfo)

    if let remoteNotification = self.remoteNotification {
      if let msgId = userInfo["m"] as? String, let remoteMsgId = remoteNotification["m"] as? String,
        msgId == remoteMsgId
      {
        CloudPushSDK.sendNotificationAck(remoteNotification)
        NSLog("###### onNotificationOpened  argument = [%@]", remoteNotification)
        channel?.invokeMethod("onNotificationOpened", arguments: remoteNotification)
        self.remoteNotification = nil
      }
    }

    completionHandler(.newData)

    return true
  }
}
