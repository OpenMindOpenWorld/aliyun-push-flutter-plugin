import CloudPushSDK
import Flutter
import UserNotifications

let KEY_CODE = "code"
let KEY_ERROR_MSG = "errorMsg"

let CODE_SUCCESS = "10000"
let CODE_PARAMS_ILLEGAL = "10001"
let CODE_FAILED = "10002"
let CODE_NO_NET = "10003"

// MARK: - AliyunPushPlugin

public class AliyunPushPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    private var channel: FlutterMethodChannel?
    private var notificationCenter: UNUserNotificationCenter?
    private var showNoticeWhenForeground: Bool = false

    // MARK: - FlutterPlugin

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "aliyun_push", binaryMessenger: registrar.messenger())
        let instance = AliyunPushPlugin()
        instance.channel = channel
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        CloudPushSDK.registerDevice(deviceToken) { res in
            if res.success {
                AliyunPushLog.d(
                    "Register deviceToken successfully, deviceToken: %@",
                    CloudPushSDK.getApnsDeviceToken() ?? "")
                let dic = ["apnsDeviceToken": CloudPushSDK.getApnsDeviceToken()]
                self.invokeFlutterMethodOnMainThread(
                    method: "onRegisterDeviceTokenSuccess", arguments: dic)
            } else {
                AliyunPushLog.d(
                    "Register deviceToken failed, error: %@",
                    (res.error as NSError?)?.description ?? "")
                let dic = ["error": (res.error as NSError?)?.description ?? ""]
                self.invokeFlutterMethodOnMainThread(
                    method: "onRegisterDeviceTokenFailed", arguments: dic)
            }
        }
        AliyunPushLog.d("####### ===> APNs register success")
    }

    public func application(
        _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        let dic = ["error": error.localizedDescription]
        invokeFlutterMethodOnMainThread(method: "onRegisterDeviceTokenFailed", arguments: dic)
        AliyunPushLog.d("####### ===> APNs register failed, %@", error.localizedDescription)
    }

    // MARK: - Method Handler

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initPushSdk":
            initPushSdk(call, result: result)
        case "getDeviceId":
            getDeviceId(result: result)
        case "turnOnDebug":
            turnOnDebug(result: result)
        case "setIOSLogLevel":
            setLogLevel(call, result: result)
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
            if let arguments = call.arguments as? [String: Any],
                let badgeNum = arguments["badgeNum"] as? Int
            {
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

    private func registerAPNs() {
        notificationCenter = UNUserNotificationCenter.current()
        notificationCenter?.delegate = self
        notificationCenter?.requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    // MARK: - Push SDK Methods

    private func initPushSdk(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
            let appKey = arguments["appKey"] as? String,
            let appSecret = arguments["appSecret"] as? String
        else {
            result([
                KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "appKey or appSecret config error",
            ])
            return
        }

        // CloudPushSDK.turnOnDebug()

        guard !appKey.isEmpty, !appSecret.isEmpty else {
            result([
                KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "appKey or appSecret config error",
            ])
            return
        }

        registerAPNs()

        CloudPushSDK.start(withAppkey: appKey, appSecret: appSecret) { res in
            if res.success {
                AliyunPushLog.d(
                    "Push SDK init success, deviceId: %@.", CloudPushSDK.getDeviceId() ?? "")
                result([KEY_CODE: CODE_SUCCESS])
            } else {
                AliyunPushLog.d(
                    "###### Push SDK init failed, error: %@",
                    (res.error as NSError?)?.description ?? "")
                NSLog(
                    "=======> Push SDK init failed, error: %@",
                    (res.error as NSError?)?.description ?? "")
                result([
                    KEY_CODE: CODE_FAILED,
                    KEY_ERROR_MSG: (res.error as NSError?)?.description ?? "",
                ])
            }
        }

        listenerOnChannelOpened()
        registerMessageReceive()
    }

    // 添加这个辅助方法来确保在主线程上调用Flutter方法
    private func invokeFlutterMethodOnMainThread(method: String, arguments: Any?) {
        DispatchQueue.main.async {
            self.channel?.invokeMethod(method, arguments: arguments)
        }
    }

    private func listenerOnChannelOpened() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onChannelOpened(_:)),
            name: NSNotification.Name(rawValue: "CCPDidChannelConnectedSuccess"), object: nil)
    }

    @objc private func onChannelOpened(_ notification: Notification) {
        invokeFlutterMethodOnMainThread(method: "onChannelOpened", arguments: [:])
    }

    private func registerMessageReceive() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onMessageReceived(_:)),
            name: NSNotification.Name(rawValue: "CCPDidReceiveMessageNotification"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func onMessageReceived(_ notification: Notification) {
        guard let data = notification.object as? [String: Any] else {
            return
        }

        let title = data["title"] as? String ?? ""
        let content = data["content"] as? String ?? ""

        let dic: [String: Any] = [
            "title": title,
            "content": content,
            // @available(*, deprecated, message: "Use 'content' instead")
            "body": content,
        ]

        invokeFlutterMethodOnMainThread(method: "onMessage", arguments: dic)
    }

    /// 设置角标数
    private func setBadgeNum(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
    private func syncBadgeNum(_ badgeNum: Int, result: FlutterResult?) {
        CloudPushSDK.syncBadgeNum(UInt(badgeNum)) { res in
            if res.success {
                AliyunPushLog.d("Sync badge num: [%d] success.", badgeNum)
                result?([KEY_CODE: CODE_SUCCESS])
            } else {
                AliyunPushLog.d(
                    "Sync badge num: [%d] failed, error: %@", badgeNum,
                    (res.error as NSError?)?.description ?? "")
                result?([
                    KEY_CODE: CODE_FAILED,
                    KEY_ERROR_MSG: (res.error as NSError?)?.description ?? "",
                ])
            }
        }
    }

    /// 获取设备Id
    private func getDeviceId(result: @escaping FlutterResult) {
        result(CloudPushSDK.getDeviceId() ?? "")
    }

    /// 打开Debug日志
    private func turnOnDebug(result: @escaping FlutterResult) {
        CloudPushSDK.setLogLevel(MPLogLevel.debug)
        result([KEY_CODE: CODE_SUCCESS])
    }

    /// 设置日志级别
    private func setLogLevel(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
            let level = arguments["level"] as? Int
        else {
            result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "Invalid level number"])
            return
        }

        // 0,1,2,3,4分别对应MPLogLevel
        if level < 0 || level > 4 {
            result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "Invalid level number"])
            return
        }

        var logLevel: MPLogLevel

        switch level {
        case 0: logLevel = MPLogLevel.none
        case 1: logLevel = MPLogLevel.error
        case 2: logLevel = MPLogLevel.warn
        case 3: logLevel = MPLogLevel.info
        case 4: logLevel = MPLogLevel.debug
        default: logLevel = MPLogLevel.none
        }

        CloudPushSDK.setLogLevel(logLevel)
        result([KEY_CODE: CODE_SUCCESS])
    }

    /// App处于前台时显示通知
    private func showNoticeWhenForeground(
        _ call: FlutterMethodCall, result: @escaping FlutterResult
    ) {
        guard let arguments = call.arguments as? [String: Any],
            let enable = arguments["enable"] as? Bool
        else {
            result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "Invalid enable value"])
            return
        }
        showNoticeWhenForeground = enable
        result([KEY_CODE: CODE_SUCCESS])
    }

    /// 获取 APNs Token
    private func getApnsDeviceToken(result: @escaping FlutterResult) {
        result(CloudPushSDK.getApnsDeviceToken())
    }

    /// 绑定账号
    private func bindAccount(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
            let account = arguments["account"] as? String
        else {
            result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "account can not be empty"])
            return
        }

        CloudPushSDK.bindAccount(account) { res in
            if res.success {
                result([KEY_CODE: CODE_SUCCESS])
            } else {
                result([
                    KEY_CODE: CODE_FAILED,
                    KEY_ERROR_MSG: (res.error as NSError?)?.description ?? "",
                ])
            }
        }
    }

    /// 解绑账号
    private func unbindAccount(result: @escaping FlutterResult) {
        CloudPushSDK.unbindAccount { res in
            if res.success {
                result([KEY_CODE: CODE_SUCCESS])
            } else {
                result([
                    KEY_CODE: CODE_FAILED,
                    KEY_ERROR_MSG: (res.error as NSError?)?.description ?? "",
                ])
            }
        }
    }

    /// 添加别名
    private func addAlias(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
            let alias = arguments["alias"] as? String
        else {
            result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "alias can not be empty"])
            return
        }

        CloudPushSDK.addAlias(alias) { res in
            if res.success {
                result([KEY_CODE: CODE_SUCCESS])
            } else {
                result([
                    KEY_CODE: CODE_FAILED,
                    KEY_ERROR_MSG: (res.error as NSError?)?.description ?? "",
                ])
            }
        }
    }

    /// 移除别名
    private func removeAlias(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
            let alias = arguments["alias"] as? String
        else {
            result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "alias can not be empty"])
            return
        }

        CloudPushSDK.removeAlias(alias) { res in
            if res.success {
                result([KEY_CODE: CODE_SUCCESS])
            } else {
                result([
                    KEY_CODE: CODE_FAILED,
                    KEY_ERROR_MSG: (res.error as NSError?)?.description ?? "",
                ])
            }
        }
    }

    /// 查询别名
    private func listAlias(result: @escaping FlutterResult) {
        CloudPushSDK.listAliases { res in
            if res.success {
                result([KEY_CODE: CODE_SUCCESS, "aliasList": res.data ?? []])
            } else {
                result([
                    KEY_CODE: CODE_FAILED,
                    KEY_ERROR_MSG: (res.error as NSError?)?.description ?? "",
                ])
            }
        }
    }

    /// 添加标签
    private func bindTag(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
            if res.success {
                result([KEY_CODE: CODE_SUCCESS])
            } else {
                AliyunPushLog.d("#### ===> %@", (res.error as NSError?)?.description ?? "")
                result([
                    KEY_CODE: CODE_FAILED,
                    KEY_ERROR_MSG: (res.error as NSError?)?.description ?? "",
                ])
            }
        }
    }

    /// 移除标签
    private func unbindTag(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
            if res.success {
                result([KEY_CODE: CODE_SUCCESS])
            } else {
                result([
                    KEY_CODE: CODE_FAILED,
                    KEY_ERROR_MSG: (res.error as NSError?)?.description ?? "",
                ])
            }
        }
    }

    /// 查询标签列表
    private func listTags(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result([KEY_CODE: CODE_PARAMS_ILLEGAL, KEY_ERROR_MSG: "Invalid arguments"])
            return
        }

        let target = arguments["target"] as? Int ?? 1

        CloudPushSDK.listTags(Int32(target)) { res in
            if res.success {
                result([KEY_CODE: CODE_SUCCESS, "tagsList": res.data ?? []])
            } else {
                result([
                    KEY_CODE: CODE_FAILED,
                    KEY_ERROR_MSG: (res.error as NSError?)?.description ?? "",
                ])
            }
        }
    }

    /// 设置是否开启插件日志
    private func setPluginLogEnabled(_ call: FlutterMethodCall) {
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

    /// 推送消息通道状态
    private func isChannelOpened(result: @escaping FlutterResult) {
        result(CloudPushSDK.isChannelOpened())
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) ->
            Void
    ) {
        let userInfo = notification.request.content.userInfo
        CloudPushSDK.sendNotificationAck(userInfo)
        invokeFlutterMethodOnMainThread(method: "onNotification", arguments: userInfo)

        if showNoticeWhenForeground {
            completionHandler([.sound, .alert, .badge])
        } else {
            completionHandler([])
        }
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let userAction = response.actionIdentifier

        if userAction == UNNotificationDefaultActionIdentifier {
            CloudPushSDK.sendNotificationAck(userInfo)
            invokeFlutterMethodOnMainThread(method: "onNotificationOpened", arguments: userInfo)
        }

        if userAction == UNNotificationDismissActionIdentifier {
            CloudPushSDK.sendDeleteNotificationAck(userInfo)
            invokeFlutterMethodOnMainThread(method: "onNotificationRemoved", arguments: userInfo)
        }

        completionHandler()
    }
}
