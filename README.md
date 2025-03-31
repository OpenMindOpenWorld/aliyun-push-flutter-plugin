# 阿里云移动推送 Flutter 插件

阿里云移动推送 Flutter 插件，集成最新版本推送 SDK（Android `3.9.3` / iOS `3.0.0`），采用 Kotlin 和 Swift 分别实现 Android 和 iOS 平台功能。

## 特性

- **跨平台支持**：兼容 Android 和 iOS 平台，支持最新版本的阿里云移动推送 SDK。
- **问题修复**：修复了官方插件中的已知问题，提升了推送服务的可靠性。
- **持续维护**：插件将跟随阿里云 SDK 更新，确保推送功能始终保持最新版本。

## 示例

请查看 [example](/example/) 了解如何在项目中集成和使用该插件。

## 新增 APIs

### ~~[已废弃]iOS 关闭推送消息通道~~
~~`Future<Map<dynamic, dynamic>> closeCCPChannel()`~~

> Aliyun iOS SDK 3.0.0 已经废弃了关闭推送消息通道的接口。

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

***

### Android 查询推送通道状态


`Future<Map<dynamic, dynamic>> checkAndroidPushChannelStatus()`

返回值：

`Map<dynamic, dynamic>`

map 中包含三个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息
- `status`: on表示推送通道打开，off表示推送通道关闭

***

### Android 开启推送通道
`Future<Map<dynamic, dynamic>> turnOnAndroidPushChannel()`

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

***

### Android 关闭推送通道
`Future<Map<dynamic, dynamic>> turnOffAndroidPushChannel()`

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息


---

## 一、快速入门

### 1.1 创建应用

EMAS 平台中的应用是您实际端应用的映射，您需要在 EMAS 控制台创建应用，与您要加载 SDK 的端应用进行关联。创建应用请参见[快速入门](https://help.aliyun.com/document_detail/436513.htm?spm=a2c4g.11186623.0.0.78fa671bjAye93#topic-2225340)。

### 1.2 应用配置

Android

- 厂商通道配置：移动推送全面支持接入厂商通道，请参见[配置厂商通道秘钥](https://help.aliyun.com/document_detail/434643.htm?spm=a2c4g.11186623.0.0.78fa671bjAye93#topic-1993457)
- 短信联动配置：移动推送支持与短信联动，通过补充推送短信提升触达效果，请参见[短信联动配置](https://help.aliyun.com/document_detail/434653.htm?spm=a2c4g.11186623.0.0.78fa671bjAye93#topic-1993467)
- 多包名配置：移动推送支持预先针对各渠道添加包名，实现一次推送，全渠道包消息可达。请参见[配置多包名](https://help.aliyun.com/document_detail/434645.htm?spm=a2c4g.11186623.0.0.78fa671bjAye93#topic-2019868)。

iOS

- 证书配置：iOS 应用推送需配置开发环境/生产环境推送证书，详细信息请参见[iOS 配置推送证书指南](https://help.aliyun.com/document_detail/434701.htm?spm=a2c4g.11186623.0.0.78fa4bfcpKinVG#topic-1824039)。

## 二、安装

在`pubspec.yaml`中加入 dependencies

```yaml
dependencies:
  aliyun_push_flutter: latest_version
```

## 三、配置

### 3.1 Android

#### 3.1.1 AndroidManifest 配置

**1. AppKey、AppSecret 配置**

在 Flutter 工程的 android 模块下的`AndroidManifest.xml`文件中设置 AppKey、AppSecret：

```xml
<application android:name="*****">
    <!-- 请填写你自己的- appKey -->
    <meta-data android:name="com.alibaba.app.appkey" android:value="*****"/>
    <!-- 请填写你自己的appSecret -->
    <meta-data android:name="com.alibaba.app.appsecret" android:value="****"/>
</application>
```

`com.alibaba.app.appkey`和`com.alibaba.app.appsecret`为您在 EMAS 平台上的 App 对应信息。在 EMAS 控制台的应用管理中或在下载的配置文件中查看 AppKey 和 AppSecret。

AppKey 和 AppSecret 请务必写在`<application>`标签下，否则 SDK 会报找不到 AppKey 的错误。

**2. 消息接收 Receiver 配置**

将该 receiver 添加到 AndroidManifest.xml 文件中：

```xml
<!-- 接收推送消息 -->
<receiver
    android:name="com.aliyun.ams.push.AliyunPushMessageReceiver"
    android:exported="false"> <!-- 为保证receiver安全，建议设置不可导出，如需对其他应用开放可通过android：permission进行限制 -->
    <intent-filter>
        <action android:name="com.alibaba.push2.action.NOTIFICATION_OPENED" />
    </intent-filter>
    <intent-filter>
        <action android:name="com.alibaba.push2.action.NOTIFICATION_REMOVED" />
    </intent-filter>
    <intent-filter>
        <action android:name="com.alibaba.sdk.android.push.RECEIVE" />
    </intent-filter>
</receiver>

```

**3. 辅助弹窗 Activity 配置**

将辅助弹窗 Activity 添加到 AndroidManifest.xml 文件中：

```xml
<!-- 辅助弹窗Activity -->
<activity
    android:name="com.aliyun.ams.push.PushPopupActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />

        <data
            android:host="${applicationId}"
            android:path="/thirdpush"
            android:scheme="agoo" />
    </intent-filter>
</activity>
```

> **注意：`android:exported=true` 必须配置**


**4. 混淆配置**

如果您的项目中使用 Proguard 等工具做了代码混淆，请保留以下配置：

```txt
-keepclasseswithmembernames class ** {
    native <methods>;
}
-keepattributes Signature
-keep class sun.misc.Unsafe { *; }
-keep class com.taobao.** {*;}
-keep class com.alibaba.** {*;}
-keep class com.alipay.** {*;}
-keep class com.ut.** {*;}
-keep class com.ta.** {*;}
-keep class anet.**{*;}
-keep class anetwork.**{*;}
-keep class org.android.spdy.**{*;}
-keep class org.android.agoo.**{*;}
-keep class android.os.**{*;}
-keep class org.json.**{*;}
-dontwarn com.taobao.**
-dontwarn com.alibaba.**
-dontwarn com.alipay.**
-dontwarn anet.**
-dontwarn org.android.spdy.**
-dontwarn org.android.agoo.**
-dontwarn anetwork.**
-dontwarn com.ut.**
-dontwarn com.ta.**
```

#### 3.1.2 辅助通道集成

在国内 Android 生态中，推送通道都是由终端与云端之间的长链接来维持，非常依赖于应用进程的存活状态。如今一些手机厂家会在自家 ROM 中做系统级别的推送通道，再由系统分发给各个 App，以此提高在自家 ROM 上的推送送达率。

移动推送针对小米、华为、荣耀、vivo、OPPO、魅族、谷歌等设备管控较严的情况，分别接入了相应的设备厂商推送辅助通道以提高这些设备上的到达率。

辅助通道的集成可参考[辅助通道集成](https://help.aliyun.com/document_detail/434677.html)。

在 Flutter 工程的 android 模块下的`AndroidManifest.xml`文件中设置各个辅助通道的配置参数：

```xml
<application android:name="*****">
      <!-- 华为通道的参数appid -->
      <meta-data android:name="com.huawei.hms.client.appid" android:value="appid=xxxxx" />

      <!-- vivo通道的参数api_key为appkey -->
      <meta-data android:name="com.vivo.push.api_key" android:value="" />
      <meta-data android:name="com.vivo.push.app_id" android:value="" />

      <!-- honor通道的参数-->
      <meta-data android:name="com.hihonor.push.app_id" android:value="" />

      <!-- oppo -->
      <meta-data android:name="com.oppo.push.key" android:value="" />
      <meta-data android:name="com.oppo.push.secret" android:value="" />
      <!-- 小米-->
      <meta-data android:name="com.xiaomi.push.id" android:value="" />
      <meta-data android:name="com.xiaomi.push.key" android:value="" />

      <!-- 魅族-->
      <meta-data android:name="com.meizu.push.id" android:value="" />
      <meta-data android:name="com.meizu.push.key" android:value="" />

      <!-- fcm -->
      <meta-data android:name="com.gcm.push.sendid" android:value="" />
      <meta-data android:name="com.gcm.push.applicationid" android:value="" />
      <meta-data android:name="com.gcm.push.projectid" android:value="" />
      <meta-data android:name="com.gcm.push.api.key" android:value="" />
</application>
```

**注意：**

以下 3 个通道配置时需要特殊处理

- 华为通道的`com.huawei.hms.client.appid`参数值的格式是`appid=xxxx`，有个前缀`appid=`
- 小米通道的`com.xiaomi.push.id`和`com.xiaomi.push.key`的值一般都是长数字，如果直接配置原始值，系统读取时会自动判断成 long 类型，但是 AndroidManifest 中的 meta-data 是不支持 long 类型的，这样就会造成插件读取到的值和实际值不一致，进而导致小米通道初始化失败
- fcm 通道的`com.gcm.push.sendid`值也是长数字，同样会导致插件读取时出错

解决办法：

- 配置时在原始值前方加入`id=`，插件会自动解析并读取原始值

```xml
<application android:name="*****">
      <!-- 小米-->
      <meta-data android:name="com.xiaomi.push.id" android:value="id=2222222222222222222" />
      <meta-data android:name="com.xiaomi.push.key" android:value="id=5555555555555" />

      <!-- fcm -->
      <meta-data android:name="com.gcm.push.sendid" android:value="id=999999999999" />
</application>
```

### 3.2 iOS

#### 3.2.1 推送配置

在`ios/Runner/Info.plist`中添加推送权限配置：

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

#### 3.2.2 Objc 配置

使用 Xcode 打开 Flutter 工程的 iOS 模块，需要做`-Objc`配置，即应用的 TARGETS -> Build Settings -> Linking -> Other Linker Flags ，需添加上 -ObjC 这个属性，否则推送服务无法正常使用 。

Other Linker Flags 中设定链接器参数-ObjC，加载二进制文件时，会将 Objective-C 类和 Category 一并载入 ，若工程依赖多个三方库 ，将所有 Category 一并加载后可能发生冲突，可以使用 -force_load 单独载入指定二进制文件，配置如下 ：

```c++
-force_load<framework_path>/CloudPushSDK.framework/CloudPushSDK
```

## 四、APIs

### `initPush`

`Future<Map<dynamic, dynamic>> initPush({String? appKey, String? appSecret}) async`

参数:

| 参数名    | 类型   | 是否必须 |
| --------- | ------ | -------- |
| appKey    | String | 可选参数 |
| appSecret | String | 可选参数 |

Android 的 AppKey 和 AppSecret 是配置在`AnroidManifest.xml`文件中。

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例:

```dart
String appKey;
String appSecret;
if (Platform.isIOS) {
 appKey = "填写自己iOS项目的appKey";
 appSecret = "填写自己iOS项目的appSecret";
} else {
 appKey = "";
 appSecret = "";
}

_aliyunPush.initPush(appKey: appKey, appSecret: appSecret)
        .then((initResult) {
var code = initResult['code'];
if (code == kAliyunPushSuccessCode) {
 print('Init Aliyun Push successfully');
 } else {
 String errorMsg = initResult['errorMsg'];
 print('Aliyun Push init failed, errorMsg is: $errorMsg);
}
```

### `initAliyunThirdPush`

`Future<Map<dynamic, dynamic>> initAndroidThirdPush() async`

**注意：**该方法只支持 Android 平台

初始化辅助通道

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.initAndroidThirdPush().then((initResult) {
      var code = initResult['code'];
      if (code == kAliyunPushSuccessCode) {
        print("Init Aliyun Third Push successfully");
      } else {
        print( 'Aliyun Third Push init failed, errorMsg is: $errorMsg');
      }
    });
```

### `addMessageReceiver`

```dart
void addMessageReceiver(
      {PushCallback? onNotification,
      PushCallback? onMessage,
      PushCallback? onNotificationOpened,
      PushCallback? onNotificationRemoved,
      PushCallback? onAndroidNotificationReceivedInApp,
      PushCallback? onAndroidNotificationClickedWithNoAction,
      PushCallback? onIOSChannelOpened,
      PushCallback? onIOSRegisterDeviceTokenSuccess,
      PushCallback? onIOSRegisterDeviceTokenFailed})
```

注册推送相关的回调

参数:

| 参数名                                   | 类型         | 是否必须 | 支持平台    | 功能                                                                                                                                                 |
| ---------------------------------------- | ------------ | -------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| onNotification                           | PushCallback | 可选参数 | Android/iOS | 收到通知的回调                                                                                                                                       |
| onMessage                                | PushCallback | 可选参数 | Android/iOS | 收到消息的回调                                                                                                                                       |
| onNotificationOpened                     | PushCallback | 可选参数 | Android/iOS | 从通知栏打开通知的扩展处理                                                                                                                           |
| onNotificationRemoved                    | PushCallback | 可选参数 | Android/iOS | 通知删除回调                                                                                                                                         |
| onAndroidNotificationReceivedInApp       | PushCallback | 可选参数 | Android     | 应用处于前台时通知到达回调                                                                                                                           |
| onAndroidNotificationClickedWithNoAction | PushCallback | 可选参数 | Android     | 无动作通知点击回调。当在后台或阿里云控制台指定的通知动作为无逻辑跳转时, 通知点击回调为 onNotificationClickedWithNoAction 而不是 onNotificationOpened |
| onIOSChannelOpened                       | PushCallback | 可选参数 | iOS         | 通道 channel 打开的回调                                                                                                                              |
| onIOSRegisterDeviceTokenSuccess          | PushCallback | 可选参数 | iOS         | 注册 APNs token 成功回调                                                                                                                             |
| onIOSRegisterDeviceTokenFailed           | PushCallback | 可选参数 | iOS         | 注册 APNs token 失败回调                                                                                                                             |

代码示例：

```dart
_aliyunPush.addMessageReceiver(
        onNotification: _onNotification,
        onNotificationOpened: _onNotificationOpened,
        onNotificationRemoved: _onNotificationRemoved,
        onMessage: _onMessage,
        onAndroidNotificationReceivedInApp: _onAndroidNotificationReceivedInApp,
        onAndroidNotificationClickedWithNoAction:
            _onAndroidNotificationClickedWithNoAction,
        onIOSChannelOpened: _onIOSChannelOpened,
        onIOSRegisterDeviceTokenSuccess: _onIOSRegisterDeviceTokenSuccess,
        onIOSRegisterDeviceTokenFailed: _onIOSRegisterDeviceTokenFailed);
```

### getDeviceId

`Future<String> getDeviceId()`

获取设备 Id

返回值：

`String` - 设备 Id

代码示例：

```dart
_aliyunPush.getDeviceId().then((deviceId) {
});
```

### bindAccount

`Future<Map<dynamic, dynamic>> bindAccount(String account) async`

绑定账号

参数:

| 参数名  | 类型   | 是否必须 | 含义         |
| ------- | ------ | -------- | ------------ |
| account | String | 必须参数 | 要绑定的账号 |

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码实例:

```dart
_pushPlugin.bindAccount(account).then((bindResult) {
    var code = bindResult['code'];
    if (code == kAliyunPushSuccessCode) {
    } else {
    }
});
```

### unbindAccount

`Future<Map<dynamic, dynamic>> unbindAccount(String account) async`

解绑账号

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码实例:

```dart
_pushPlugin.unbindAccount(account).then((unbindResult) {
    var code = unbindResult['code'];
    if (code == kAliyunPushSuccessCode) {
    } else {
    }
});
```

### `addAlias`

`Future<Map<dynamic, dynamic>> addAlias(String alias) async`

添加别名

参数:

| 参数名 | 类型   | 是否必须 | 含义         |
| ------ | ------ | -------- | ------------ |
| alias  | String | 必须参数 | 要添加的别名 |

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart
_pushPlugin.addAlias(account).then((addResult) {
    var code = addResult['code'];
    if (code == kAliyunPushSuccessCode) {
    } else {
    }
});

```

### `removeAlias`

`Future<Map<dynamic, dynamic>> removeAlias(String alias) async`

移除别名

参数:

| 参数名 | 类型   | 是否必须 | 含义         |
| ------ | ------ | -------- | ------------ |
| alias  | String | 必须参数 | 要移除的别名 |

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart
_pushPlugin.removeAlias(account).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
    } else {
    }
});

```

### `listAlias`

`Future<Map<dynamic, dynamic>> listAlias() async`

查询别名

返回值：

`Map<dynamic, dynamic>`

map 中包含三个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息
- `aliasList`: 别名列表

代码示例：

```dart
_pushPlugin.listAlias(account).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
    var aliasList = result['aliasList'];
    } else {
    }
});
```

### `bindTag`

`Future<Map<dynamic, dynamic>> bindTag(List<String> tags,{int target = kAliyunTargetDevice, String? alias}) async`

添加标签

参数:

| 参数名 | 类型          | 是否必须 | 含义                                                       |
| ------ | ------------- | -------- | ---------------------------------------------------------- |
| tags   | List\<String> | 必须参数 | 要绑定的标签列表                                           |
| target | int           | 可选参数 | 目标类型，1: 本设备 2: 本设备绑定账号 3: 别名</br>默认是 1 |
| alias  | String        | 可选参数 | 别名（仅当 target = 3 时生效）                             |

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码实例:

```dart
_pushPlugin.bindTag(tags).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
    } else {
    }
});
```

### `unbindTag`

`Future<Map<dynamic, dynamic>> unbindTag(List<String> tags, {int target = kAliyunTargetDevice, String? alias}) async`

移除标签

参数:

| 参数名 | 类型           | 是否必须 | 含义                                                       |
| ------ | -------------- | -------- | ---------------------------------------------------------- |
| tags   | List\<String\> | 必须参数 | 要移除的标签列表                                           |
| target | int            | 可选参数 | 目标类型，1: 本设备 2: 本设备绑定账号 3: 别名</br>默认是 1 |
| alias  | String         | 可选参数 | 别名（仅当 target = 3 时生效）                             |

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码实例:

```dart
_pushPlugin.unbindTag(tags).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
    } else {
    }
});
```

### `listTags`

`Future<Map<dynamic, dynamic>> listTags`

查询标签列表

返回值：

`Map<dynamic, dynamic>`

map 中包含三个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息
- `tagsList`: 标签列表

代码示例：

```dart
 _pushPlugin.listTags(account).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
        var tagsList = listTagsResult['tagsList'];
    } else {
    }
});
```

### closeAndroidPushLog

`Future<Map<dynamic, dynamic>> closeAndroidPushLog() async`

关闭 Android 推送 SDK 的 Log

> **注意：只支持 Android 平台**

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.closeAndroidPushLog().then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
    }
});
```

### setAndroidLogLevel

`Future<Map<dynamic, dynamic>> setAndroidLogLevel(int level) async`

设置 Android 推送 SDK 输出日志的级别

> **注意：只支持 Android 平台**

参数:

| 参数名 | 类型 | 是否必须 | 含义                                                 |
| ------ | ---- | -------- | ---------------------------------------------------- |
| level  | int  | 必须参数 | 日志级别</br>0 - Error </br> 1 - Info </br> 2- Debug |

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart

_aliyunPush.setAndroidLogLevel(logLevel).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {

    } else {
        var errorCode = result['code'];
        var errorMsg = result['errorMsg'];
    }
});
```

### bindPhoneNumber

`Future<Map<dynamic, dynamic>> bindPhoneNumber(String phone) async`

绑定手机号码

> **注意：只支持 Android 平台**

参数:

| 参数名 | 类型   | 是否必须 | 含义             |
| ------ | ------ | -------- | ---------------- |
| phone  | string | 必须参数 | 要绑定的电话号码 |

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例:

```dart
_aliyunPush.bindPhoneNumber(phone).then((bindResult) {
    var code = bindResult['code'];
    if (code == kAliyunPushSuccessCode) {

    } else {
        var errorCode = bindResult['code'];
        var errorMsg = bindResult['errorMsg'];
    }
});
```

### unbindPhoneNumber

`Future<Map<dynamic, dynamic>> unbindPhoneNumber() async`

解绑手机号码

> **注意：只支持 Android 平台**

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例:

```dart
_aliyunPush.unbindPhoneNumber().then((unbindResult) {
    var code = unbindResult['code'];
    if (code == kAliyunPushSuccessCode) {

    } else {
        var errorCode = unbindResult['code'];
        var errorMsg = unbindResult['errorMsg'];
    }
});
```

### setNotificationInGroup

`Future<Map<dynamic, dynamic>> setNotificationInGroup(bool inGroup) async`

设置通知分组展示

> **注意：只支持 Android 平台**

参数:

| 参数名  | 类型 | 是否必须 | 含义                         |
| ------- | ---- | -------- | ---------------------------- |
| inGroup | bool | 必须参数 | true-开启分组;false-关闭分组 |

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.setNotificationInGroup(true).then((result){
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
        print('开启通知分组展示成功');
     }
});

_aliyunPush.setNotificationInGroup(false).then((result){
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
        print('关闭通知分组展示成功');
     }
});
```

### clearNotifications

`Future<Map<dynamic, dynamic>> clearNotifications() async`

清除所有通知

> **注意：只支持 Android 平台**

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例:

```dart
_aliyunPush.clearNotifications().then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
    }
});
```

### createAndroidChannel

`Future<Map<dynamic, dynamic>> createAndroidChannel(
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
      List<int>? vibrationPatterns})`

创建 Android 平台的 NotificationChannel

> **注意：只支持 Android 平台**

参数:

| 参数名            | 类型       | 是否必须 | 含义            |
| ----------------- | ---------- | -------- | --------------- |
| id                | String     | 必须参数 | 通道 id         |
| name              | String     | 必须参数 | 通道 name       |
| importance        | int        | 必须参数 | 通道 importance |
| desc              | String     | 必须参数 | 通道描述        |
| groupId           | String     | 可选参数 | -               |
| allowBubbles      | bool       | 可选参数 | -               |
| light             | bool       | 可选参数 | -               |
| lightColor        | int        | 可选参数 | -               |
| showBadge         | bool       | 可选参数 | -               |
| soundPath         | String     | 可选参数 | -               |
| soundUsage        | int        | 可选参数 | -               |
| soundContentType  | int        | 可选参数 | -               |
| soundFlag         | int        | 可选参数 | -               |
| vibration         | bool       | 可选参数 | -               |
| vibrationPatterns | List\<int> | 可选参数 | -               |

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart

_aliyunPush.createAndroidChannel(_channelController.text, '测试通道A', 3, '测试创建通知通道')
    .then((createResult) {
        var code = createResult['code'];
        if (code == kAliyunPushSuccessCode) {
            Fluttertoast.showToast(
                msg: '创建$channel通道成功', gravity: ToastGravity.CENTER);
        } else {
            var errorCode = createResult['code'];
            var errorMsg = createResult['errorMsg'];
            Fluttertoast.showToast(
                msg: '创建$channel通道失败, $errorCode - $errorMsg',
                gravity: ToastGravity.CENTER);
            }
        });
```

### createAndroidChannelGroup

`Future<Map<dynamic, dynamic>> createAndroidChannelGroup(String id, String name, String desc) async`

创建通知通道的分组

> **注意：只支持 Android 平台**

参数:

| 参数名 | 类型   | 是否必须 | 含义      |
| ------ | ------ | -------- | --------- |
| id     | String | 必须参数 | 通道 id   |
| name   | String | 必须参数 | 通道 name |
| desc   | String | 必须参数 | 通道描述  |

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

### isAndroidNotificationEnabled

`Future<bool> isAndroidNotificationEnabled({String? id}) async`

检查通知状态

> **注意：只支持 Android 平台**

参数:

| 参数名 | 类型   | 是否必须 | 含义    |
| ------ | ------ | -------- | ------- |
| id     | String | 可选参数 | 通道 id |

返回值：

`bool` - true: 已打开; false：未打开

代码示例：

```dart
bool isEnabled = await _aliyunPush.isAndroidNotificationEnabled(
                id: 'xxx');
```

### jumpToAndroidNotificationSettings

`void jumpToAndroidNotificationSettings({String? id})`

跳转到通知设置页面

> **注意：只支持 Android 平台**

代码示例:

```dart
_aliyunPush.jumpToAndroidNotificationSettings();
```

### turnOnIOSDebug

`Future<Map<dynamic, dynamic>> turnOnIOSDebug() async`

打开 iOS 推送 SDK 的日志

> **注意：只支持 iOS 平台**

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.turnOnIOSDebug().then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
    }
});
```

### showIOSNoticeWhenForeground

`Future<Map<dynamic, dynamic>> showIOSNoticeWhenForeground(bool enable) async`

App 处于前台时显示通知

> **注意：只支持 iOS 平台**

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.showIOSNoticeWhenForeground(true).then((result) {
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
        Fluttertoast.showToast(
            msg: '设置前台显示通知成功', gravity: ToastGravity.CENTER);
    }
});
```

### setIOSBadgeNum

`Future<Map<dynamic, dynamic>> setIOSBadgeNum(int num) async`

设置角标数

> **注意：只支持 iOS 平台**

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.setIOSBadgeNum(badgeNum).then((result) {
    var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
            Fluttertoast.showToast(
                    msg: '设置角标个数$badgeNum成功', gravity: ToastGravity.CENTER);
        }
    });
```

### syncIOSBadgeNum

`Future<Map<dynamic, dynamic>> syncIOSBadgeNum(int num) async`

同步角标数

> **注意：只支持 iOS 平台**

返回值：

`Map<dynamic, dynamic>`

map 中包含两个 key 值:

- `code`: 错误码
- `errorMsg`: 错误信息

代码示例：

```dart
_aliyunPush.syncIOSBadgeNum(badgeNum).then((result) {
    var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
            Fluttertoast.showToast(
                    msg: '同步角标个数$badgeNum成功', gravity: ToastGravity.CENTER);
        }
    });
```

### getApnsDeviceToken

`Future<String> getApnsDeviceToken() async`

获取 APNs Token

> **注意：只支持 iOS 平台**

返回值：

`String` - APNs Token

代码示例：

```dart
_aliyunPush.getApnsDeviceToken().then((token) {
});
```

### isIOSChannelOpened

`Future<bool> isIOSChannelOpened() async`

通知通道是否已打开

> **注意：只支持 iOS 平台**

返回值：

`bool` - true: 已打开; false：未打开

代码示例：

```dart
_aliyunPush.isIOSChannelOpened().then((opened) {
 if (opened) {
 } else {
 }
});
```

### setPluginLogEnabled

`void setPluginLogEnabled(bool enabled)`

设置插件的日志是否开启

代码示例:

```dart
_aliyunPush.setPluginLogEnabled(true);
```

## 五、错误码

| 名称                   | 值      | 含义                                                            |
| ---------------------- | ------- | --------------------------------------------------------------- |
| kAliyunPushSuccessCode | "10000" | 成功                                                            |
| kAliyunPushFailedCode  | "10001" | 通用失败码                                                      |
| kAliyunPushOnlyAndroid | "10002" | 方法只支持 Android 平台                                         |
| kAliyunPushOnlyIOS     | "10003" | 方法只支持 iOS 平台                                             |
| kAliyunPushNotSupport  | "10004" | 平台不支持，比如 Android 创建 group 只支持 Android 8.0 以上版本 |
