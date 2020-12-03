import 'package:flutter/material.dart';
import 'FloatingWindowSharedDataWidget.dart';
import 'package:floating_window/FloatingWindow/components/FloatingItem.dart';

/// [FloatingItemAnimatedWidget] 列表项进行动画类封装，方便传入平移向上动画
class FloatingItemAnimatedWidget extends AnimatedWidget{

  FloatingItemAnimatedWidget({
    Key key,
    Animation<double> upAnimation,
    this.index,
    this.isEntering
  }):super(key:key,listenable: upAnimation);

  /// [index] 列表项索引
  final int index;

  /// [isEntering] 列表项是否需要执行进场动画
  final bool isEntering;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    /// 获取列表数据
    var data = FloatingWindowSharedDataWidget.of(context).data;
    /// 监听动画
    final Animation<double> animation = listenable;
    /// 获取屏幕信息
    double width = MediaQuery.of(context).size.width / 2;
    double left = 0.0;
    if(data.isLeft){
      if(isEntering)
        left = -(width + 50.0);
      else
        left = 0.0;
    }else{
      if(isEntering)
        left = (width * 2);
      else
        left = width -50.0;
    }
    return FloatingItem(top: animation.value, isLeft: data.isLeft, title: data.dataList[index]['title'],
        imageProvider: AssetImage(data.dataList[index]['imageUrl']), index: index,
        width: width,left: left,isEntering:isEntering);
  }
}