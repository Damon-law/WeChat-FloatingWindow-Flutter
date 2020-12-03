import 'package:flutter/material.dart';
import 'package:floating_window/FloatingWindow/widgets/FloatingItemAnimatedWidget.dart';
import 'package:floating_window/FloatingWindow/widgets/FloatingWindowSharedDataWidget.dart';


/// [FloatingItems] 列表
class FloatingItems extends StatefulWidget {
  FloatingItems({
    Key key,
    @required this.isEntering
  }):super(key:key);
  @override
  _FloatingItemsState createState() => _FloatingItemsState();

  ///[isEntering] 是否具有进场动画
  bool isEntering = true;

}

class _FloatingItemsState extends State<FloatingItems> with TickerProviderStateMixin{


  /// [_controller] 列表项动画的控制器
  AnimationController _controller;


  /// 动态生成列表
  /// 其中一项触发关闭事件后，索引在该项后的列表项执行向上平移的动画。
  List<Widget> getItems(BuildContext context){
    /// 释放和申请新的动画资源
    if(_controller != null){
      _controller.dispose();
      _controller = new AnimationController(vsync: this,duration:  new Duration(milliseconds: 100));
    }
    /// widget列表
    List<Widget>widgetList = [];
    /// 获取共享数据
    var data = FloatingWindowSharedDataWidget.of(context).data;
    /// 列表数据
    var dataList = data.dataList;

    /// 确定列表项位置
    double top = data.top + 70.0;
    if(data.itemTop >= 0){
      top = data.itemTop;
    }else{
      if(data.top + 70.0 * (dataList.length  + 1)> MediaQuery.of(context).size.height - 20.0){
        top = data.top - 70.0 * (dataList.length  + 1);
        data.itemTop = top;
      }
    }
    /// 遍历数据生成列表项
    for(int i = 0; i < dataList.length; ++i){
      /// 在触发关闭事件列表项的索引之后的列表项传入向上平移动画
      if(data.deleteIndex != - 1 && i >= data.deleteIndex){
        Animation animation;
        animation = new Tween<double>(begin: top + (70.0 * (i + 1)),end: top + 70.0 * (i)).animate(_controller);
        widgetList.add(FloatingItemAnimatedWidget(upAnimation: animation,index: i,isEntering: widget.isEntering,));
      }
      /// 在触发关闭事件列表项的索引之前的列表项则位置固定
      else{
        Animation animation;
        animation = new Tween<double>(begin: top + (70.0 * (i)),end: top + 70.0 * (i)).animate(_controller);
        widgetList.add(FloatingItemAnimatedWidget(upAnimation: animation,index: i,isEntering: widget.isEntering,));
      }
    }

    /// 重置deletedIndex
    if(data.deleteIndex != -1){
      data.deleteIndex = -1;
    }
    /// 执行动画
    if(_controller != null)
      _controller.forward();
    /// 返回列表
    return widgetList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new AnimationController(vsync: this,duration: new Duration(milliseconds: 100));
  }


  @override
  Widget build(BuildContext context) {
    return Stack(children: getItems(context),);
  }
}