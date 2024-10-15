import 'package:aliyun_push_flutter/aliyun_push_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'base_state.dart';
import 'common_widget.dart';

class AndroidPage extends StatefulWidget {
  const AndroidPage({super.key});

  @override
  State<AndroidPage> createState() => _AndroidPageState();
}

class _AndroidPageState extends BaseState<AndroidPage> {
  final _aliyunPush = AliyunPushFlutter();

  final TextEditingController _addPhoneController = TextEditingController();
  final TextEditingController _channelController = TextEditingController();

  String _boundPhone = "";

  final List<String> _logLevelList = ['ERROR', 'INFO', 'DEBUG'];
  String? _selectedLogLevel = "DEBUG";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Android平台方法')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            _setLogBuilder(),
            _bindPhoneBuilder(),
            _setNotificationBuilder(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _addPhoneController.dispose();
    _channelController.dispose();
  }

  Widget _bindPhoneBuilder() {
    final List<Widget> children = [];

    children.add(titleBuilder('手机号码绑定/解绑'));
    children.add(const SizedBox(height: 20));

    children.add(TextField(
      autofocus: false,
      decoration: const InputDecoration(
        labelText: '绑定手机号码',
        hintText: '绑定手机号码',
      ),
      controller: _addPhoneController,
    ));

    children.add(FilledButton(
      onPressed: () async {
        var phone = _addPhoneController.text;
        if (phone.isNotEmpty) {
          var result = await _aliyunPush.bindPhoneNumber(phone);
          var code = result['code'];
          if (code == kAliyunPushSuccessCode) {
            setState(() {
              _boundPhone = phone;
            });
            _addPhoneController.clear();
            showOkDialog('绑定手机号码$phone成功');
          } else {
            var errorCode = result['code'];
            var errorMsg = result['errorMsg'];
            showErrorDialog('绑定手机号码$phone失败: $errorCode - $errorMsg');
          }
        } else {
          showWarningDialog('请输入要绑定的手机号码');
        }
      },
      child: const Text('绑定手机号码'),
    ));

    if (_boundPhone.isNotEmpty) {
      children.add(Text('已绑定手机号码: $_boundPhone'));
    }

    children.add(FilledButton(
      onPressed: () async {
        var result = await _aliyunPush.unbindPhoneNumber();
        var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
          setState(() {
            _boundPhone = "";
          });
          showOkDialog('解绑手机号码成功');
        } else {
          var errorCode = result['code'];
          var errorMsg = result['errorMsg'];
          showErrorDialog('解绑手机号码失败: $errorCode - $errorMsg');
        }
      },
      child: const Text('解绑手机号码'),
    ));

    return cardBuilder(Column(children: children));
  }

  Widget _setLogBuilder() {
    final List<Widget> children = [];

    children.add(titleBuilder('通知日志设置'));
    children.add(const SizedBox(height: 20));

    children.add(const SizedBox(height: 10));

    children.add(Material(
      color: Colors.grey.shade300,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          hint: const Text('选择LogLevel'),
          items: _logLevelList
              .map((item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)))
              .toList(),
          value: _selectedLogLevel,
          onChanged: (value) {
            setState(() {
              _selectedLogLevel = value as String;
            });
          },
        ),
      ),
    ));

    children.add(const SizedBox(height: 10));

    children.add(FilledButton(
      onPressed: () async {
        int logLevel;
        if (_selectedLogLevel == 'ERROR') {
          logLevel = kAliyunPushLogLevelError;
        } else if (_selectedLogLevel == 'INFO') {
          logLevel = kAliyunPushLogLevelInfo;
        } else {
          logLevel = kAliyunPushLogLevelDebug;
        }

        var result = await _aliyunPush.setAndroidLogLevel(logLevel);
        var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
          showOkDialog('设置LogLevel $_selectedLogLevel 成功');
        } else {
          var errorCode = result['code'];
          var errorMsg = result['errorMsg'];
          showErrorDialog('设置LogLevel失败: $errorCode - $errorMsg');
        }
      },
      child: Text('设置Log Level为 $_selectedLogLevel'),
    ));

    children.add(FilledButton(
      onPressed: () async {
        var result = await _aliyunPush.closeAndroidPushLog();
        var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
          showOkDialog('关闭 Push Log 成功');
        } else {
          showErrorDialog('关闭 Push Log 失败');
        }
      },
      child: const Text('关闭 Push Log'),
    ));

    return cardBuilder(Column(children: children));
  }

  Widget _setNotificationBuilder() {
    final List<Widget> children = [];

    children.add(titleBuilder('通知设置'));
    children.add(const SizedBox(height: 20));

    children.add(FilledButton(
      onPressed: () async {
        var result = await _aliyunPush.setNotificationInGroup(true);
        var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
          showOkDialog('开启通知分组展示成功');
        } else {
          showErrorDialog('开启通知分组展示失败');
        }
      },
      child: const Text('开启通知分组展示'),
    ));

    children.add(FilledButton(
      onPressed: () async {
        var result = await _aliyunPush.setNotificationInGroup(false);
        var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
          showOkDialog('关闭通知分组展示成功');
        } else {
          showErrorDialog('关闭通知分组展示失败');
        }
      },
      child: const Text('关闭通知分组展示'),
    ));

    children.add(FilledButton(
      onPressed: () async {
        var result = await _aliyunPush.clearNotifications();
        var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
          showOkDialog('清除所有通知成功');
        } else {
          showErrorDialog('清除所有通知失败');
        }
      },
      child: const Text('清除所有通知'),
    ));

    children.add(TextField(
      autofocus: false,
      decoration: const InputDecoration(
        labelText: "通道名称",
        hintText: "通道名称",
      ),
      controller: _channelController,
    ));

    children.add(FilledButton(
      onPressed: () async {
        var channel = _channelController.text;

        if (channel.isNotEmpty) {
          var result = await _aliyunPush.createAndroidChannel(
              channel, '测试通道A', 3, '测试创建通知通道');

          var code = result['code'];
          if (code == kAliyunPushSuccessCode) {
            showOkDialog('创建$channel通道成功');
          } else {
            var errorCode = result['code'];
            var errorMsg = result['errorMsg'];
            showErrorDialog('创建$channel通道失败, $errorCode - $errorMsg');
          }
        } else {
          showWarningDialog('通道名称不能为空');
        }
      },
      child: const Text('创建通知通道'),
    ));

    children.add(FilledButton(
      onPressed: () async {
        bool isEnabled = await _aliyunPush.isAndroidNotificationEnabled();
        showOkDialog('通知状态: $isEnabled');
      },
      child: const Text('检查通知状态'),
    ));

    children.add(FilledButton(
      onPressed: () async {
        var channel = _channelController.text;
        if (channel.isNotEmpty) {
          bool isEnabled =
              await _aliyunPush.isAndroidNotificationEnabled(id: channel);
          showOkDialog('通知状态: $isEnabled');
        } else {
          showWarningDialog('填写通道名称');
        }
      },
      child: const Text('检查通知通道状态'),
    ));

    children.add(FilledButton(
      onPressed: () {
        _aliyunPush.jumpToAndroidNotificationSettings();
      },
      child: const Text('跳转通知设置界面'),
    ));

    children.add(FilledButton(
      onPressed: () {
        var channel = _channelController.text;
        _aliyunPush.jumpToAndroidNotificationSettings(id: channel);
      },
      child: const Text('跳转通知通道设置界面'),
    ));

    return cardBuilder(Column(children: children));
  }
}
