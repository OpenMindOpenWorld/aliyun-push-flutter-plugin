package com.aliyun.ams.push

import com.alibaba.sdk.android.push.MessageReceiver
import com.alibaba.sdk.android.push.notification.CPushMessage
import com.alibaba.sdk.android.push.notification.NotificationConfigure
import com.alibaba.sdk.android.push.notification.PushData
import android.app.Notification
import android.content.Context
import androidx.core.app.NotificationCompat

class AliyunPushMessageReceiver : MessageReceiver() {
    companion object {
        // 消息接收部分的 LOG_TAG
        const val TAG = "MPS:receiver"
    }

    override fun hookNotificationBuild(): NotificationConfigure {
        return object : NotificationConfigure {
            override fun configBuilder(builder: Notification.Builder, pushData: PushData) {
                AliyunPushLog.e(TAG, "configBuilder")
            }

            override fun configBuilder(builder: NotificationCompat.Builder, pushData: PushData) {
                AliyunPushLog.e(TAG, "configBuilder")
            }

            override fun configNotification(notification: Notification, pushData: PushData) {
                AliyunPushLog.e(TAG, "configNotification")
            }
        }
    }

    override fun showNotificationNow(context: Context, map: Map<String, String>): Boolean {
        for ((key, value) in map) {
            AliyunPushLog.e(TAG, "key=>$key value=>$value")
        }
        return super.showNotificationNow(context, map)
    }

    // 推送通知的回调方法
    override fun onNotification(
        context: Context,
        title: String,
        summary: String,
        extraMap: Map<String, String>?
    ) {
        val arguments = HashMap<String, Any>()
        extraMap?.let { arguments.putAll(it) }
        arguments["title"] = title
        arguments["summary"] = summary
        
        AliyunPushPlugin.sInstance.callFlutterMethod("onNotification", arguments)
    }

    // 应用处于前台时通知到达回调
    override fun onNotificationReceivedInApp(
        context: Context,
        title: String,
        summary: String,
        extraMap: Map<String, String>,
        openType: Int,
        openActivity: String,
        openUrl: String
    ) {
        val arguments = HashMap<String, Any>()
        extraMap.let { arguments.putAll(it) }
        arguments["title"] = title
        arguments["summary"] = summary
        arguments["openType"] = openType
        arguments["openActivity"] = openActivity
        arguments["openUrl"] = openUrl

        AliyunPushPlugin.sInstance.callFlutterMethod("onNotificationReceivedInApp", arguments)
    }

    // 推送消息的回调方法
    override fun onMessage(context: Context, cPushMessage: CPushMessage) {
        val arguments = HashMap<String, Any>()
        arguments["title"] = cPushMessage.title
        arguments["content"] = cPushMessage.content
        arguments["msgId"] = cPushMessage.messageId
        arguments["appId"] = cPushMessage.appId
        arguments["traceInfo"] = cPushMessage.traceInfo

        AliyunPushPlugin.sInstance.callFlutterMethod("onMessage", arguments)
    }

    // 从通知栏打开通知的扩展处理
    override fun onNotificationOpened(
        context: Context,
        title: String,
        summary: String,
        extraMap: String
    ) {
        val arguments = HashMap<String, Any>()
        arguments["title"] = title
        arguments["summary"] = summary
        arguments["extraMap"] = extraMap

        AliyunPushPlugin.sInstance.callFlutterMethod("onNotificationOpened", arguments)
    }

    // 通知删除回调
    override fun onNotificationRemoved(context: Context, messageId: String) {
        val arguments = HashMap<String, Any>()
        arguments["msgId"] = messageId

        AliyunPushPlugin.sInstance.callFlutterMethod("onNotificationRemoved", arguments)
    }

    // 无动作通知点击回调（当在后台或阿里云控制台指定的通知动作为无逻辑跳转时）
    override fun onNotificationClickedWithNoAction(
        context: Context,
        title: String,
        summary: String,
        extraMap: String
    ) {
        val arguments = HashMap<String, Any>()
        arguments["title"] = title
        arguments["summary"] = summary
        arguments["extraMap"] = extraMap

        AliyunPushPlugin.sInstance.callFlutterMethod("onNotificationClickedWithNoAction", arguments)
    }
}