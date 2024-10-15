package com.aliyun.ams.push

import android.util.Log

object AliyunPushLog {
    private var isLogEnabled = false

    fun isLogEnabled(): Boolean {
        return isLogEnabled
    }

    fun setLogEnabled(logEnabled: Boolean) {
        isLogEnabled = logEnabled
    }

    fun d(tag: String, msg: String) {
        if (isLogEnabled) {
            Log.d(tag, msg)
        }
    }

    fun e(tag: String, msg: String) {
        if (isLogEnabled) {
            Log.e(tag, msg)
        }
    }
}