import 'package:flutter/material.dart';

/// [ClickNotification]列表项点击事件通知类
class ClickNotification extends Notification {
  ClickNotification({this.deletedIndex = -1,this.clickIndex = -1,this.changeWidget = false});
  /// 触发了关闭事件的列表项索引
  int deletedIndex = -1;
  /// 触发了点击事件的列表项索引
  int clickIndex = -1;
  /// 是否触发了改变形态的操作
  bool changeWidget = false;
}