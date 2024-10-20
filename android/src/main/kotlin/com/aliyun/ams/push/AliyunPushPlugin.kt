package com.aliyun.ams.push

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationChannelGroup
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationManagerCompat
import com.alibaba.sdk.android.push.CloudPushService
import com.alibaba.sdk.android.push.CommonCallback
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

/** AliyunPushPlugin */
class AliyunPushPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        private const val TAG = "MPS:PushPlugin"

        private const val CODE_SUCCESS = "10000"
        private const val CODE_PARAM_ILLEGAL = "10001"
        private const val CODE_FAILED = "10002"
        private const val CODE_NOT_SUPPORT = "10005"

        private const val CODE_KEY = "code"
        private const val ERROR_MSG_KEY = "errorMsg"

        @SuppressLint("StaticFieldLeak")
        lateinit var sInstance: AliyunPushPlugin
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mContext: Context

    init {
        sInstance = this
    }

    fun callFlutterMethod(method: String, arguments: Map<String, Any>?) {
        if (TextUtils.isEmpty(method)) {
            return
        }

        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod(method, arguments)
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "aliyun_push")
        channel.setMethodCallHandler(this)
        mContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val methodName: String = call.method
        when (methodName) {
            "initPush" -> initPush(result)
            "initThirdPush" -> initThirdPush(result)
            "getDeviceId" -> getDeviceId(result)
            "closePushLog" -> closePushLog(result)
            "setLogLevel" -> setLogLevel(call, result)
            "bindAccount" -> bindAccount(call, result)
            "unbindAccount" -> unbindAccount(result)
            "addAlias" -> addAlias(call, result)
            "removeAlias" -> removeAlias(call, result)
            "listAlias" -> listAlias(result)
            "bindTag" -> bindTag(call, result)
            "unbindTag" -> unbindTag(call, result)
            "listTags" -> listTags(call, result)
            "bindPhoneNumber" -> bindPhoneNumber(call, result)
            "unbindPhoneNumber" -> unbindPhoneNumber(result)
            "setNotificationInGroup" -> setNotificationInGroup(call, result)
            "clearNotifications" -> clearNotifications(result)
            "createChannel" -> createChannel(call, result)
            "createChannelGroup" -> createChannelGroup(call, result)
            "checkPushChannelStatus" -> checkPushChannelStatus(result)
            "turnOnPushChannel" -> turnOnPushChannel(result)
            "turnOffPushChannel" -> turnOffPushChannel(result)
            "isNotificationEnabled" -> isNotificationEnabled(call, result)
            "jumpToNotificationSettings" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    jumpToAndroidNotificationSettings(call)
                }
            }
            "setPluginLogEnabled" -> {
                val enabled = call.argument<Boolean>("enabled")
                if (enabled != null) {
                    AliyunPushLog.setLogEnabled(enabled)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // 注册推送通道
    private fun initPush(result: Result) {
        PushServiceFactory.init(mContext)

        val pushService = PushServiceFactory.getCloudPushService()
        pushService.setLogLevel(CloudPushService.LOG_DEBUG)
        pushService.register(mContext, object : CommonCallback {
            override fun onSuccess(response: String?) {
                val map = HashMap<String, String>()
                map[CODE_KEY] = CODE_SUCCESS

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }

            override fun onFailed(errorCode: String, errorMessage: String) {
                val map = HashMap<String, String>()
                map[CODE_KEY] = errorCode
                map[ERROR_MSG_KEY] = errorMessage

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }
        })

        pushService.turnOnPushChannel(object : CommonCallback {
            override fun onSuccess(s: String) {}
            override fun onFailed(s: String, s1: String) {}
        })
    }

    private fun initThirdPush(result: Result) {
        val map = HashMap<String, String>()
        val context = mContext.applicationContext

        if (context is Application) {
            AliyunThirdPushUtils.registerHuaweiPush(context)
            AliyunThirdPushUtils.registerXiaomiPush(context)
            AliyunThirdPushUtils.registerVivoPush(context)
            AliyunThirdPushUtils.registerOppoPush(context)
            AliyunThirdPushUtils.registerMeizuPush(context)
            AliyunThirdPushUtils.registerHonorPush(context)
            AliyunThirdPushUtils.registerGCM(context)

            map[CODE_KEY] = CODE_SUCCESS
        } else {
            map[CODE_KEY] = CODE_FAILED
            map[ERROR_MSG_KEY] = "context is not Application"
        }

        try {
            result.success(map)
        } catch (e: Exception) {
            AliyunPushLog.e(TAG, Log.getStackTraceString(e))
        }
    }

    // 关闭日志
    private fun closePushLog(result: Result) {
        val service = PushServiceFactory.getCloudPushService()
        service.setLogLevel(CloudPushService.LOG_OFF)

        val map = HashMap<String, String>()
        map[CODE_KEY] = CODE_SUCCESS

        try {
            result.success(map)
        } catch (e:Exception) {
            AliyunPushLog.e(TAG, Log.getStackTraceString(e))
        }
    }

    // 获取设备标识
    private fun getDeviceId(result: Result) {
        val pushService = PushServiceFactory.getCloudPushService()
        val deviceId = pushService.deviceId

        try {
            result.success(deviceId)
        } catch (e: Exception) {
            AliyunPushLog.e(TAG, Log.getStackTraceString(e))
        }
    }

    // 设置日志等级
    private fun setLogLevel(call: MethodCall, result: Result) {
        val level = call.argument<Int>("level")
        val map = HashMap<String, String>()

        if (level!=null) {
            val pushService = PushServiceFactory.getCloudPushService()
            pushService.setLogLevel(level)
            map[CODE_KEY] = CODE_SUCCESS
        } else {
            map[CODE_KEY] = CODE_PARAM_ILLEGAL
            map[ERROR_MSG_KEY] = "Log level is empty"
        }

        try {
            result.success(map)
        } catch (e: Exception) {
            AliyunPushLog.e(TAG, Log.getStackTraceString(e))
        }
    }

    // 绑定账号
    private fun bindAccount(call: MethodCall, result: Result) {
        val account = call.argument<String>("account")
        val map = HashMap<String, String>()

        if (TextUtils.isEmpty(account)) {
            map[CODE_KEY] = CODE_PARAM_ILLEGAL
            map[ERROR_MSG_KEY] = "account can not be empty"

            try {
                result.success(map)
            } catch (e: Exception) {
                AliyunPushLog.e(TAG, Log.getStackTraceString(e))
            }
        } else {
            val pushService = PushServiceFactory.getCloudPushService()
            pushService.bindAccount(account, object : CommonCallback {
                override fun onSuccess(response: String?) {
                    map[CODE_KEY] = CODE_SUCCESS

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }

                override fun onFailed(errorCode: String, errorMsg: String) {
                    map[CODE_KEY] = errorCode
                    map[ERROR_MSG_KEY] = errorMsg

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }
            })
        }
    }

    // 解绑账号
    private fun unbindAccount(result: Result) {
        val map = HashMap<String, String>()

        val pushService = PushServiceFactory.getCloudPushService()
        pushService.unbindAccount(object : CommonCallback {
            override fun onSuccess(response: String?) {
                map[CODE_KEY] = CODE_SUCCESS

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }

            override fun onFailed(errorCode: String, errorMsg: String) {
                map[CODE_KEY] = errorCode
                map[ERROR_MSG_KEY] = errorMsg

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }
        })
    }

    // 添加别名
    private fun addAlias(call: MethodCall, result: Result) {
        val alias = call.argument<String>("alias")
        val map = HashMap<String, String>()

        if (TextUtils.isEmpty(alias)) {
            map[CODE_KEY] = CODE_PARAM_ILLEGAL
            map[ERROR_MSG_KEY] = "alias can not be empty"

            try {
                result.success(map)
            } catch (e: Exception) {
                AliyunPushLog.e(TAG, Log.getStackTraceString(e))
            }
        } else {
            val pushService = PushServiceFactory.getCloudPushService()
            pushService.addAlias(alias, object : CommonCallback {
                override fun onSuccess(response: String) {
                    map[CODE_KEY] = CODE_SUCCESS

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }

                override fun onFailed(errorCode: String, errorMsg: String) {
                    map[CODE_KEY] = errorCode
                    map[ERROR_MSG_KEY] = errorMsg

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }
            })
        }
    }

    // 删除别名
    private fun removeAlias(call: MethodCall, result: Result) {
        val alias = call.argument<String>("alias")
        val map = HashMap<String, String>()

        if (TextUtils.isEmpty(alias)) {
            map[CODE_KEY] = CODE_PARAM_ILLEGAL
            map[ERROR_MSG_KEY] = "alias can not be empty"

            try {
                result.success(map)
            } catch (e: Exception) {
                AliyunPushLog.e(TAG, Log.getStackTraceString(e))
            }
        } else {
            val pushService = PushServiceFactory.getCloudPushService()
            pushService.removeAlias(alias, object : CommonCallback {
                override fun onSuccess(response: String) {
                    map[CODE_KEY] = CODE_SUCCESS

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }

                override fun onFailed(errorCode: String, errorMsg: String) {
                    map[CODE_KEY] = errorCode
                    map[ERROR_MSG_KEY] = errorMsg

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }
            })
        }
    }

    // 查询别名
    private fun listAlias(result: Result) {
        val map = HashMap<String, String>()

        val pushService = PushServiceFactory.getCloudPushService()
        pushService.listAliases(object : CommonCallback {
            override fun onSuccess(response: String) {
                map[CODE_KEY] = CODE_SUCCESS
                map["aliasList"] = response

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }

            override fun onFailed(errorCode: String, errorMsg: String) {
                map[CODE_KEY] = errorCode
                map[ERROR_MSG_KEY] = errorMsg

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }
        })
    }

    // 绑定标签
    private fun bindTag(call: MethodCall, result: Result) {
        val tags = call.argument<List<String>>("tags")
        val map = HashMap<String, String>()

        if (tags == null || tags.isEmpty()) {
            map[CODE_KEY] = CODE_PARAM_ILLEGAL
            map[ERROR_MSG_KEY] = "tags can not be empty"

            try {
                result.success(map)
            } catch (e: Exception) {
                AliyunPushLog.e(TAG, Log.getStackTraceString(e))
            }
        } else {
            val target = call.argument<Int?>("target") ?: 1
            val alias = call.argument<String?>("alias")
            val tagsArray = tags.toTypedArray()

            val pushService = PushServiceFactory.getCloudPushService()
            pushService.bindTag(target, tagsArray, alias, object : CommonCallback {
                override fun onSuccess(response: String) {
                    map[CODE_KEY] = CODE_SUCCESS

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }

                override fun onFailed(errorCode: String, errorMsg: String) {
                    map[CODE_KEY] = errorCode
                    map[ERROR_MSG_KEY] = errorMsg

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }
            })
        }
    }

    // 解绑标签
    private fun unbindTag(call: MethodCall, result: Result) {
        val tags = call.argument<List<String>>("tags")
        val map = HashMap<String, String>()

        if (tags == null || tags.isEmpty()) {
            map[CODE_KEY] = CODE_PARAM_ILLEGAL
            map[ERROR_MSG_KEY] = "tags can not be empty"

            try {
                result.success(map)
            } catch (e: Exception) {
                AliyunPushLog.e(TAG, Log.getStackTraceString(e))
            }
        } else {
            val target = call.argument<Int?>("target") ?: 1
            val alias = call.argument<String?>("alias")
            val tagsArray = tags.toTypedArray()

            val pushService = PushServiceFactory.getCloudPushService()
            pushService.unbindTag(target, tagsArray, alias, object : CommonCallback {
                override fun onSuccess(response: String) {
                    map[CODE_KEY] = CODE_SUCCESS

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }

                override fun onFailed(errorCode: String, errorMsg: String) {
                    map[CODE_KEY] = errorCode
                    map[ERROR_MSG_KEY] = errorMsg

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }
            })
        }
    }

    // 查询标签
    private fun listTags(call: MethodCall, result: Result) {
        val target = call.argument<Int>("target") ?: 1
        val map = HashMap<String, String>()

        val pushService = PushServiceFactory.getCloudPushService()
        pushService.listTags(target, object : CommonCallback {
            override fun onSuccess(response: String) {
                map[CODE_KEY] = CODE_SUCCESS
                map["tagsList"] = response

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }

            override fun onFailed(errorCode: String, errorMsg: String) {
                map[CODE_KEY] = errorCode
                map[ERROR_MSG_KEY] = errorMsg

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }
        })
    }

    // 绑定电话号码
    private fun bindPhoneNumber(call: MethodCall, result: Result) {
        val phone = call.argument<String>("phone")
        val map = HashMap<String, String>()

        if (TextUtils.isEmpty(phone)) {
            map[CODE_KEY] = CODE_PARAM_ILLEGAL
            map[ERROR_MSG_KEY] = "phone number can not be empty"

            try {
                result.success(map)
            } catch (e: Exception) {
                AliyunPushLog.e(TAG, Log.getStackTraceString(e))
            }
        } else {
            val pushService = PushServiceFactory.getCloudPushService()
            pushService.bindPhoneNumber(phone, object : CommonCallback {
                override fun onSuccess(response: String) {
                    map[CODE_KEY] = CODE_SUCCESS

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }

                override fun onFailed(errorCode: String, errorMsg: String) {
                    map[CODE_KEY] = errorCode
                    map[ERROR_MSG_KEY] = errorMsg

                    try {
                        result.success(map)
                    } catch (e: Exception) {
                        AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                    }
                }
            })
        }
    }

    // 解绑电话号码
    private fun unbindPhoneNumber(result: Result) {
        val map = HashMap<String, String>()
        val pushService = PushServiceFactory.getCloudPushService()

        pushService.unbindPhoneNumber(object : CommonCallback {
            override fun onSuccess(response: String) {
                map[CODE_KEY] = CODE_SUCCESS

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }

            override fun onFailed(errorCode: String, errorMsg: String) {
                map[CODE_KEY] = errorCode
                map[ERROR_MSG_KEY] = errorMsg

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }
        })
    }

    // 设置通知折叠展示
    private fun setNotificationInGroup(call: MethodCall, result: Result) {
        val inGroup = call.argument<Boolean>("inGroup") ?: false
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.setNotificationShowInGroup(inGroup)

        val map = HashMap<String, String>()
        map[CODE_KEY] = CODE_SUCCESS

        try {
            result.success(map)
        } catch (e: Exception) {
            AliyunPushLog.e(TAG, Log.getStackTraceString(e))
        }
    }

    // 删除所有通知
    private fun clearNotifications(result: Result) {
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.clearNotifications()

        val map = HashMap<String, String>()
        map[CODE_KEY] = CODE_SUCCESS

        try {
            result.success(map)
        } catch (e: Exception) {
            AliyunPushLog.e(TAG, Log.getStackTraceString(e))
        }
    }

    // 创建通知通道
    private fun createChannel(call: MethodCall, result: Result) {
        val map = HashMap<String, String>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val id = call.argument<String>("id")
            val name = call.argument<String>("name")
            val importance = call.argument<Int>("importance")
            val desc = call.argument<String>("desc")

            val groupId = call.argument<String?>("groupId")
            val allowBubbles = call.argument<Boolean?>("allowBubbles")
            val light = call.argument<Boolean?>("light")
            val color = call.argument<Int?>("lightColor")
            val showBadge = call.argument<Boolean?>("showBadge")
            val soundPath = call.argument<String?>("soundPath")
            val soundUsage = call.argument<Int?>("soundUsage")
            val soundContentType = call.argument<Int?>("soundContentType")
            val soundFlag = call.argument<Int?>("soundFlag")
            val vibration = call.argument<Boolean?>("vibration")
            val vibrationPattern = call.argument<List<Long>?>("vibrationPattern")

            val notificationManager = mContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val importanceValue = importance ?: NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(id, name, importanceValue).apply {
                description = desc
                groupId?.let { setGroup(it) }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    allowBubbles?.let { setAllowBubbles(it) }
                }
                light?.let { enableLights(it) }
                color?.let { setLightColor(it) }
                showBadge?.let { setShowBadge(it) }

                if (!TextUtils.isEmpty(soundPath)) {
                    val file = File(soundPath)
                    if (file.exists() && file.canRead() && file.isFile) {
                        try {
                            if (soundUsage == null) {
                                setSound(Uri.fromFile(file), null)
                            } else {
                                val builder = AudioAttributes.Builder().setUsage(soundUsage)
                                soundContentType?.let { builder.setContentType(it) }
                                soundFlag?.let { builder.setFlags(it) }
                                setSound(Uri.fromFile(file), builder.build())
                            }
                        } catch (e: Exception) {
                            AliyunPushLog.e(TAG, "设置通知声音失败: ${e.message}")
                        }
                    } else {
                        AliyunPushLog.e(TAG, "指定的声音文件不存在或无法读取")
                    }
                }

                vibration?.let { enableVibration(it) }
                vibrationPattern?.let {
                    val pattern = LongArray(it.size)
                    for (i in it.indices) {
                        pattern[i] = it[i]
                    }
                    setVibrationPattern(pattern)
                }
            }

            notificationManager.createNotificationChannel(channel)
            map[CODE_KEY] = CODE_SUCCESS

            try {
                result.success(map)
            } catch (e: Exception) {
                AliyunPushLog.e(TAG, Log.getStackTraceString(e))
            }
        } else {
            map[CODE_KEY] = CODE_NOT_SUPPORT
            map[ERROR_MSG_KEY] = "Android version is below Android O which is not support create channel"

            try {
                result.success(map)
            } catch (e: Exception) {
                AliyunPushLog.e(TAG, Log.getStackTraceString(e))
            }
        }
    }

    // 创建通知通道的分组
    private fun createChannelGroup(call: MethodCall, result: Result) {
        val map = HashMap<String, String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val id = call.argument<String?>("id")
            val name = call.argument<String?>("name")
            val desc = call.argument<String?>("desc")

            val notificationManager = mContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val group = NotificationChannelGroup(id, name).apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    description = desc
                }
            }
            notificationManager.createNotificationChannelGroup(group)
            map[CODE_KEY] = CODE_SUCCESS

            try {
                result.success(map)
            } catch (e: Exception) {
                AliyunPushLog.e(TAG, Log.getStackTraceString(e))
            }
        } else {
            map[CODE_KEY] = CODE_NOT_SUPPORT
            map[ERROR_MSG_KEY] = "Android version is below Android O which is not support create group"

            try {
                result.success(map)
            } catch (e: Exception) {
                AliyunPushLog.e(TAG, Log.getStackTraceString(e))
            }
        }
    }

    // 检查通知状态
    private fun isNotificationEnabled(call: MethodCall, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = mContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (!manager.areNotificationsEnabled()) {
                result.success(false)
                return
            }
            val id: String? = call.argument<String?>("id")
            if (id == null) {
                result.success(true)
                return
            }
            val channels = manager.notificationChannels
            for (channel in channels) {
                if (channel.id == id) {
                    if (channel.importance == NotificationManager.IMPORTANCE_NONE) {
                        result.success(false)
                    } else {
                        if (channel.group != null) {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                val group = manager.getNotificationChannelGroup(channel.group)
                                result.success(!group.isBlocked)
                                return
                            }
                        }
                        result.success(true)
                        return
                    }
                }
            }
            result.success(false)
        } else {
            val enabled = NotificationManagerCompat.from(mContext).areNotificationsEnabled()
            result.success(enabled)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun jumpToAndroidNotificationSettings(call: MethodCall) {
        val id: String? = call.argument<String?>("id")
        val intent = if (id!=null) {
            Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, mContext.packageName)
                putExtra(Settings.EXTRA_CHANNEL_ID, id)
            }
        } else {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, mContext.packageName)
            }
        }

        if (mContext !is Activity) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        mContext.startActivity(intent)
    }

    // 打开推送通道
    private fun turnOnPushChannel(result: Result) {
        val map = HashMap<String, String>()
        val pushService = PushServiceFactory.getCloudPushService()

        pushService.turnOnPushChannel(object : CommonCallback {
            override fun onSuccess(response: String) {
                map[CODE_KEY] = CODE_SUCCESS

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }

            override fun onFailed(errorCode: String, errorMsg: String) {
                map[CODE_KEY] = errorCode
                map[ERROR_MSG_KEY] = errorMsg

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }
        })
    }

    // 关闭推送通道
    private fun turnOffPushChannel(result: Result) {
        val map = HashMap<String, String>()
        val pushService = PushServiceFactory.getCloudPushService()

        pushService.turnOffPushChannel(object : CommonCallback {
            override fun onSuccess(response: String) {
                map[CODE_KEY] = CODE_SUCCESS

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }

            override fun onFailed(errorCode: String, errorMsg: String) {
                map[CODE_KEY] = errorCode
                map[ERROR_MSG_KEY] = errorMsg

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }
        })
    }

    // 查询推送通道状态
    private fun checkPushChannelStatus(result: Result) {
        val map = HashMap<String, String>()
        val pushService = PushServiceFactory.getCloudPushService()

        pushService.checkPushChannelStatus(object : CommonCallback {
            override fun onSuccess(response: String) {
                map[CODE_KEY] = CODE_SUCCESS
                map["status"] = response

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }

            override fun onFailed(errorCode: String, errorMsg: String) {
                map[CODE_KEY] = errorCode
                map[ERROR_MSG_KEY] = errorMsg

                try {
                    result.success(map)
                } catch (e: Exception) {
                    AliyunPushLog.e(TAG, Log.getStackTraceString(e))
                }
            }
        })
    }
}
