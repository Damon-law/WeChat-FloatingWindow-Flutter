import 'package:flutter/material.dart';
import 'FloatingWindow.dart';

/// [FloatingWindowOverlayEntry] 悬浮窗浮层显示
class FloatingWindowOverlayEntry{
  /// [_overlayEntry] 悬浮窗浮层
  static OverlayEntry _overlayEntry;
  /// [_overlayEntry] 悬浮窗
  static FloatingWindow _floatingWindow;

  /// 添加条项
  static void add(BuildContext context,{Map<String,String> element}){
    /// 如果没有浮层则初始化
    if(_overlayEntry == null){
      _floatingWindow = new FloatingWindow();
      _overlayEntry = OverlayEntry(
        builder: (BuildContext context) {
          return _floatingWindow;
        }
      );
      Overlay.of(context,rootOverlay: true).insert(_overlayEntry);
    }
    /// 存在浮层
    else{
      /// 如果列表项为空，则清除原先浮层，然后新建浮层插入。
      if(FloatingWindow.isEmpty()){
        /// 清除原先浮层
        _overlayEntry.remove();
        _floatingWindow = new FloatingWindow();
        /// 新建浮层
        _overlayEntry = OverlayEntry(
          builder: (BuildContext context){
            return _floatingWindow;
          }
        );
        /// 插入浮层
        Overlay.of(context,rootOverlay: true).insert(_overlayEntry);
      }
    }
    /// 添加列表项数据
    FloatingWindow.add(element);
    /// 标记脏值刷新
    _overlayEntry.markNeedsBuild();
  }
}