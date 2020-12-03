import 'package:flutter/material.dart';
import 'components/FloatingButton.dart';
import 'components/FloatingItem.dart';
import 'components/FloatingItems.dart';
import 'widgets/FloatingWindowSharedDataWidget.dart';
import 'models/FloatingWindowModel.dart';
import 'models/ClickNotification.dart';

/// [FloatingWindow] 悬浮窗
class FloatingWindow extends StatefulWidget {


  @override
  _FloatingWindowState createState() => _FloatingWindowState();

  /// 添加列表项数据
  static void add(Map<String,String> element){
    _FloatingWindowState.ls.add(element);
  }

  /// 判断列表项是否为空
  static bool isEmpty(){
    return _FloatingWindowState.windowModel.isEmpty;
  }

}

class _FloatingWindowState extends State<FloatingWindow> {

  static List<Map<String,String>> ls = [];


  /// 悬浮窗共享数据
  static FloatingWindowModel windowModel;
  /// [isEntering] 列表项是否拥有进场动画
  bool isEntering = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    windowModel = new FloatingWindowModel(dataList: ls,isLeft: true);
    isEntering = true;
  }
  @override
  Widget build(BuildContext context) {
    return FloatingWindowSharedDataWidget(
      data: windowModel,
      child: windowModel.isEmpty ? Container() : Stack(
        fit: StackFit.expand,
        children: [
          /// 列表项遮盖层，增加淡化切换动画
          AnimatedSwitcher(
            duration: Duration(milliseconds: 100),
            child: windowModel.isButton ? Container() : GestureDetector(
              onTap: (){
                FloatingItem.reverse();
                Future.delayed(Duration(milliseconds: 110),(){
                  setState(() {
                    windowModel.isButton = true;
                    windowModel.itemTop = -1.0;
                  });
                });
              },
              child: Container(
                decoration: BoxDecoration(color: Color.fromRGBO(0xEF, 0xEF, 0xEF, 0.9)),
              ),
            ),
          ),
          NotificationListener<ClickNotification>(
            onNotification: (notification){
              /// 列表项关闭事件
              if(notification.deletedIndex != -1){
                windowModel.deleteIndex = notification.deletedIndex;
                setState(() {
                  FloatingItem.resetList();
                  windowModel.dataList.removeAt(notification.deletedIndex);
                  isEntering = false;
                });
              }

              /// 列表点击事件
              if(notification.clickIndex != -1){
                print(notification.clickIndex);
              }

              /// 悬浮按钮点击Widget改变事件
              if(notification.changeWidget){
                setState(() {
                  /// 释放列表进出场动画资源
                  FloatingItem.resetList();
                  windowModel.isButton = false;
                  isEntering = true;
                });
              }

              return false;
            },
            child: windowModel.isButton ? FloatingButton():FloatingItems(isEntering: isEntering,),
          )
        ],
    ),
    );
  }
}
