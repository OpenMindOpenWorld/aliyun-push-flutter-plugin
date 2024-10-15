import 'dart:async';
import 'dart:io';

import 'package:aliyun_push_flutter/aliyun_push_flutter.dart';
import 'package:flutter/material.dart';

import 'android.dart';
import 'base_state.dart';
import 'common_api.dart';
import 'ios.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BaseState<HomePage> {
  final _aliyunPush = AliyunPushFlutter();
  var _deviceId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AliyunPush example app')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          FilledButton(
            onPressed: _initAliyunPush,
            child: const Text('初始化AliyunPush'),
          ),
          if (Platform.isAndroid)
            FilledButton(
              onPressed: _initAliyunThirdPush,
              child: const Text('初始化厂商通道'),
            ),
          FilledButton(
            onPressed: _getDeviceId,
            child: const Text('查询deviceId'),
          ),
          if (_deviceId.isNotEmpty) Text('deviceId: $_deviceId'),
          FilledButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const CommonApiPage();
              }));
            },
            child: const Text('账号/别名/标签'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AndroidPage();
              }));
            },
            child: const Text('Android特定方法'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const IOSPage();
              }));
            },
            child: const Text('iOS特定方法'),
          ),
          FilledButton(
            onPressed: () {
              _aliyunPush.setPluginLogEnabled(true);
            },
            child: const Text('开启插件日志'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      _aliyunPush.createAndroidChannel('8.0up', '测试通道A', 3, '测试创建通知通道');
    }

    _addPushCallback();
  }

  void _addPushCallback() {
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
      onIOSRegisterDeviceTokenFailed: _onIOSRegisterDeviceTokenFailed,
    );
  }

  Future<void> _getDeviceId() async {
    var deviceId = await _aliyunPush.getDeviceId();
    setState(() {
      _deviceId = deviceId;
    });
  }

  Future<void> _initAliyunPush() async {
    String appKey;
    String appSecret;

    if (Platform.isIOS) {
      appKey = 'iOS_appKey';
      appSecret = 'iOS_appSecret';
    } else {
      appKey = "";
      appSecret = "";
    }

    var result =
        await _aliyunPush.initPush(appKey: appKey, appSecret: appSecret);
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
      showOkDialog('初始化成功');
    } else {
      var errorMsg = result['errorMsg'];
      showErrorDialog('初始化推送失败: $code - $errorMsg');
    }
  }

  Future<void> _initAliyunThirdPush() async {
    var result = await _aliyunPush.initAndroidThirdPush();
    var code = result['code'];
    if (code == kAliyunPushSuccessCode) {
      showOkDialog('初始化辅助通道成功');
    } else {
      var errorMsg = result['errorMsg'];
      showErrorDialog('初始化辅助通道失败: $code - $errorMsg');
    }
  }

  Future<void> _onAndroidNotificationClickedWithNoAction(
      Map<dynamic, dynamic> message) async {
    showOkDialog('onAndroidNotificationClickedWithNoAction ====> $message');
  }

  Future<void> _onAndroidNotificationReceivedInApp(
      Map<dynamic, dynamic> message) async {
    showOkDialog('onAndroidNotificationReceivedInApp ====> $message');
  }

  Future<void> _onMessage(Map<dynamic, dynamic> message) async {
    showOkDialog('onMessage ====> $message');
  }

  Future<void> _onNotification(Map<dynamic, dynamic> message) async {
    showOkDialog('onNotification ====> $message');
  }

  Future<void> _onNotificationOpened(Map<dynamic, dynamic> message) async {
    showOkDialog('onNotificationOpened ====> $message');
  }

  Future<void> _onNotificationRemoved(Map<dynamic, dynamic> message) async {
    showOkDialog('onNotificationRemoved ====> $message');
  }

  Future<void> _onIOSChannelOpened(Map<dynamic, dynamic> message) async {
    showOkDialog('onIOSChannelOpened ====> $message');
  }

  Future<void> _onIOSRegisterDeviceTokenSuccess(
      Map<dynamic, dynamic> message) async {
    showOkDialog('onIOSRegisterDeviceTokenSuccess ====> $message');
  }

  Future<void> _onIOSRegisterDeviceTokenFailed(
      Map<dynamic, dynamic> message) async {
    showOkDialog('onIOSRegisterDeviceTokenFailed====> $message');
  }
}
