import 'package:flutter/material.dart';
import 'package:floating_window/FloatingWindow/models/FloatingWindowModel.dart';

/// [FloatingWindowSharedDataWidget]悬浮窗数据共享Widget
class FloatingWindowSharedDataWidget extends InheritedWidget{

  FloatingWindowSharedDataWidget({
    @required this.data,
    Widget child
  }) : super(child:child);

  ///[data]悬浮窗共享数据
  final FloatingWindowModel data;

  /// 静态方法[of]方便直接调用获取共享数据
  static FloatingWindowSharedDataWidget of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<FloatingWindowSharedDataWidget>();
  }

  @override
  bool updateShouldNotify(FloatingWindowSharedDataWidget oldWidget) {
    // TODO: implement updateShouldNotify
    /// 数据发生变化则发布通知
    return oldWidget.data != data && data.deleteIndex != -1;
  }
}