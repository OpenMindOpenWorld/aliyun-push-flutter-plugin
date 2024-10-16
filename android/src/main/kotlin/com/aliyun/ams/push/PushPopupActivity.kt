package com.aliyun.ams.push

import android.content.Intent
import android.os.Bundle
import com.alibaba.sdk.android.push.AndroidPopupActivity

class PushPopupActivity : AndroidPopupActivity() {
    companion object {
        const val TAG = "MPS:PushPopup"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    // 通知打开时回调方法，获取通知相关信息
    override fun onSysNoticeOpened(title: String, summary: String, extMap: Map<String, String>) {
        try {
            // 启动MainActivity
            val intent = Intent().apply {
                val packageName = packageName
                setClassName(this@PushPopupActivity, "$packageName.MainActivity")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }

            startActivity(intent)

            val arguments = mapOf(
                "title" to title,
                "summary" to summary,
                "extraMap" to extMap
            )

            AliyunPushPlugin.sInstance.callFlutterMethod("onNotificationOpened", arguments)
        } catch (e: Exception){
            AliyunPushLog.e(TAG, "打开通知出错: $e")
        }

        finish()
    }

    // 不是推送数据的回调
    override fun onNotPushData(intent: Intent?) {
        super.onNotPushData(intent)
        AliyunPushLog.e(TAG, "不是推送数据：intent=>$intent")
        finish()
    }

    // 是推送数据，但是又解密失败时的回调
    override fun onParseFailed(intent: Intent?) {
        super.onParseFailed(intent)
        AliyunPushLog.e(TAG, "推送数据解密失败：intent=>$intent")
        finish()
    }
}