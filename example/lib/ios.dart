import 'package:flutter/material.dart';
import 'package:aliyun_push_flutter/aliyun_push_flutter.dart';

import 'base_state.dart';
import 'common_widget.dart';

class IOSPage extends StatefulWidget {
  const IOSPage({super.key});

  @override
  State<IOSPage> createState() => _IOSPageState();
}

class _IOSPageState extends BaseState<IOSPage> {
  final _aliyunPush = AliyunPushFlutter();

  final TextEditingController _badgeController = TextEditingController();

  String _apnsToken = "";

  @override
  void dispose() {
    super.dispose();

    _badgeController.dispose();
  }

  Widget _setDebugLogBuilder() {
    final List<Widget> children = [];

    children.add(titleBuilder('通知日志设置'));
    children.add(const SizedBox(height: 20));

    children.add(FilledButton(
      onPressed: () async {
        var result = await _aliyunPush.turnOnIOSDebug();
        var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
          showOkDialog('打开Debug日志成功');
        } else {
          showErrorDialog('打开Debug日志失败');
        }
      },
      child: const Text('打开debug日志'),
    ));

    children.add(FilledButton(
      onPressed: () async {
        var result = await _aliyunPush.getApnsDeviceToken();
        setState(() {
          _apnsToken = result;
        });
      },
      child: const Text('查询ApnsToken'),
    ));

    if (_apnsToken.isNotEmpty) {
      children.add(Text('ApnsToken: $_apnsToken'));
    }

    children.add(FilledButton(
      onPressed: () async {
        var opened = await _aliyunPush.isIOSChannelOpened();
        if (opened) {
          showOkDialog('通知通道已打开');
        } else {
          showErrorDialog('通知通道未打开');
        }
      },
      child: const Text('通知通道是否已打开'),
    ));

    return cardBuilder(Column(children: children));
  }

  Widget _setNoticeWhenForegroundBuilder() {
    final List<Widget> children = [];

    children.add(titleBuilder('设置前台显示通知'));
    children.add(const SizedBox(height: 20));

    children.add(FilledButton(
      onPressed: () async {
        var result = await _aliyunPush.showIOSNoticeWhenForeground(true);
        var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
          showOkDialog('设置前台显示通知成功');
        } else {
          showErrorDialog('设置前台显示通知失败');
        }
      },
      child: const Text('前台显示通知'),
    ));

    children.add(FilledButton(
      onPressed: () async {
        var result = await _aliyunPush.showIOSNoticeWhenForeground(false);
        var code = result['code'];
        if (code == kAliyunPushSuccessCode) {
          showOkDialog('设置前台不显示通知成功');
        } else {
          showErrorDialog('设置前台不显示通知失败');
        }
      },
      child: const Text('前台不显示通知'),
    ));

    return cardBuilder(Column(children: children));
  }

  Widget _setBadgeBuilder() {
    final List<Widget> children = [];

    children.add(titleBuilder('设置角标'));
    children.add(const SizedBox(height: 20));

    children.add(TextField(
      autofocus: false,
      decoration: const InputDecoration(
        labelText: '角标数量',
        hintText: '角标数量',
      ),
      controller: _badgeController,
    ));

    children.add(FilledButton(
      onPressed: () async {
        var badge = _badgeController.text;

        if (badge.isNotEmpty) {
          int badgeNum = int.parse(badge);
          var result = await _aliyunPush.setIOSBadgeNum(badgeNum);
          var code = result['code'];
          if (code == kAliyunPushSuccessCode) {
            showOkDialog('设置角标数量$badgeNum成功');
          } else {
            showErrorDialog('设置角标失败');
          }
        } else {
          showWarningDialog('请填写角标数量');
        }
      },
      child: const Text('设置角标数量'),
    ));

    children.add(FilledButton(
      onPressed: () async {
        var badge = _badgeController.text;

        if (badge.isNotEmpty) {
          int badgeNum = int.parse(badge);
          var result = await _aliyunPush.syncIOSBadgeNum(badgeNum);
          var code = result['code'];
          if (code == kAliyunPushSuccessCode) {
            showOkDialog('同步角标数量$badgeNum成功');
          } else {
            showErrorDialog('同步角标失败');
          }
        } else {
          showWarningDialog('请填写角标数量');
        }
      },
      child: const Text('同步角标数量'),
    ));

    return cardBuilder(Column(children: children));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('iOS平台方法')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            _setDebugLogBuilder(),
            _setNoticeWhenForegroundBuilder(),
            _setBadgeBuilder(),
          ],
        ),
      ),
    );
  }
}
