package com.aliyun.ams.push

import android.app.Application
import android.content.Context
import android.content.pm.PackageManager
import com.alibaba.sdk.android.push.HonorRegister
import com.alibaba.sdk.android.push.huawei.HuaWeiRegister
import com.alibaba.sdk.android.push.register.GcmRegister
import com.alibaba.sdk.android.push.register.MeizuRegister
import com.alibaba.sdk.android.push.register.MiPushRegister
import com.alibaba.sdk.android.push.register.OppoRegister
import com.alibaba.sdk.android.push.register.VivoRegister

object AliyunThirdPushUtils {
    private fun getAppMetaDataWithId(context: Context, key: String): String? {
        return getAppMetaData(context, key)?.let { value ->
            when {
                value.startsWith("id=") -> value.substring(3)
                value.startsWith("appid=") -> value.substring(6)
                else -> value
            }
        }
    }

    private fun getAppMetaData(context: Context, key: String): String? {
        return try {
            val packageManager = context.packageManager
            val packageName = context.packageName
            val info = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)

            if (info.metaData.containsKey(key)) {
                info.metaData.getString(key) ?: info.metaData.getInt(key, -1).takeIf { it != -1 }?.toString()
            } else {
                null
            }
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
            null
        }
    }

    // Meizu
    fun registerMeizuPush(application: Application) {
        val meizuId = getMeizuPushId(application)
        val meizuKey = getMeizuPushKey(application)

        if (meizuId != null && meizuKey != null) {
            MeizuRegister.register(application, meizuId, meizuKey)
        }
    }

    private fun getMeizuPushId(context: Context) =
        getAppMetaDataWithId(context, "com.meizu.push.id")

    private fun getMeizuPushKey(context: Context) =
        getAppMetaDataWithId(context, "com.meizu.push.key")

    // Oppo
    fun registerOppoPush(application: Application) {
        val oppoKey = getOppoPushKey(application)
        val oppoSecret = getOppoPushSecret(application)

        if (oppoKey != null && oppoSecret != null) {
            OppoRegister.register(application, oppoKey, oppoSecret)
        }
    }

    private fun getOppoPushKey(context: Context) =
        getAppMetaDataWithId(context, "com.oppo.push.key")

    private fun getOppoPushSecret(context: Context) =
        getAppMetaDataWithId(context, "com.oppo.push.secret")

    // Xiaomi
    fun registerXiaomiPush(application: Application) {
        val xiaomiId = getXiaomiId(application)
        val xiaomiKey = getXiaomiKey(application)

        if (xiaomiId != null && xiaomiKey != null) {
            MiPushRegister.register(application, xiaomiId, xiaomiKey)
        }
    }

    private fun getXiaomiId(context: Context) = getAppMetaDataWithId(context, "com.xiaomi.push.id")
    private fun getXiaomiKey(context: Context) =
        getAppMetaDataWithId(context, "com.xiaomi.push.key")

    // Vivo
    fun registerVivoPush(application: Application) {
        val vivoApiKey = getVivoApiKey(application)
        val vivoAppId = getVivoAppId(application)

        if (vivoApiKey != null && vivoAppId != null) {
            VivoRegister.register(application)
        }
    }

    private fun getVivoApiKey(context: Context) =
        getAppMetaDataWithId(context, "com.vivo.push.api_key")

    private fun getVivoAppId(context: Context) =
        getAppMetaDataWithId(context, "com.vivo.push.app_id")

    // Huawei
    fun registerHuaweiPush(application: Application) {
        val huaweiAppId = getHuaweiAppId(application)

        if (huaweiAppId != null) {
            HuaWeiRegister.register(application)
        }
    }

    private fun getHuaweiAppId(context: Context) =
        getAppMetaData(context, "com.huawei.hms.client.appid")

    // Honor
    fun registerHonorPush(application: Application) {
        val honorAppId = getHonorAppId(application)

        if (honorAppId != null) {
            HonorRegister.register(application)
        }
    }

    private fun getHonorAppId(context: Context) = getAppMetaData(context, "com.hihonor.push.app_id")

    // FCM
    fun registerGCM(application: Application) {
        val sendId = getGCMSendId(application)
        val applicationId = getGCMApplicationId(application)
        val projectId = getGCMProjectId(application)
        val apiKey = getGCMApiKey(application)

        if (sendId != null && applicationId != null && projectId != null && apiKey != null) {
            GcmRegister.register(application, sendId, applicationId, projectId, apiKey)
        }
    }

    private fun getGCMSendId(context: Context) =
        getAppMetaDataWithId(context, "com.gcm.push.sendid")

    private fun getGCMApplicationId(context: Context) =
        getAppMetaDataWithId(context, "com.gcm.push.applicationid")

    private fun getGCMProjectId(context: Context) =
        getAppMetaDataWithId(context, "com.gcm.push.projectid")

    private fun getGCMApiKey(context: Context) =
        getAppMetaDataWithId(context, "com.gcm.push.api.key")
}