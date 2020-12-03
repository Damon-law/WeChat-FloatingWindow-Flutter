import 'package:floating_window/FloatingWindow/models/ClickNotification.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import  'dart:math';
import 'dart:async';
import 'package:floating_window/FloatingWindow/widgets/FloatingWindowSharedDataWidget.dart';

class FloatingButton extends StatefulWidget {

  @override
  _FloatingButtonState createState() => _FloatingButtonState();

}

class _FloatingButtonState extends State<FloatingButton> with TickerProviderStateMixin{

  /// [isPress] 按钮是否被按下
  bool isPress = false;

  /// [_controller] 返回动画控制器
  AnimationController _controller;
  /// [_animation] 返回动画
  Animation _animation;


  @override
  Widget build(BuildContext context) {
    /// 获取悬浮窗共享数据
    var windowModel = FloatingWindowSharedDataWidget.of(context).data;
    return Positioned(
      left: windowModel.left,
      top: windowModel.top,
      child: Listener(
        /// 按下后设[isPress]为true，绘制选中阴影
        onPointerDown: (details){
          setState(() {
            isPress = true;
          });
        },
        /// 按下后设isPress为false，不绘制阴影
        /// 放下后根据当前x坐标与1/2屏幕宽度比较，判断屏幕在屏幕左侧或右侧，设置返回边缘动画
        /// 动画结束后设置isLeft的值，根据值绘制左/右边缘按钮
        onPointerUp: (e) async{
          setState(() {
            isPress = false;
          });
          /// 获取屏幕信息
          var pixelDetails = MediaQuery.of(context).size; //获取屏幕信息

          /// 点击按钮，触发Widget改变事件
          if(windowModel.isLeft && e.position.dx <= 50.0 && windowModel.isEdge){
            ClickNotification(changeWidget: true).dispatch(context);
            return ;
          }
          else if(!windowModel.isLeft && e.position.dx >= pixelDetails.width - 50.0 && windowModel.isEdge){
            ClickNotification(changeWidget: true).dispatch(context);
            return ;
          }

          /// 触发返回动画
          if(e.position.dx <= pixelDetails.width / 2)
          {
            /// 申请动画资源
            _controller = new AnimationController(vsync: this,duration: new Duration(milliseconds: 100)); //0.1s动画
            _animation = new Tween(begin: e.position.dx,end: 0.0).animate(_controller)
              ..addListener(() {setState(() {
                /// 更新x坐标
                windowModel.left = _animation.value;
              });
              });
            /// 等待动画结束
            await _controller.forward();
            _controller.dispose();/// 释放动画资源
            setState(() {
              windowModel.isLeft = true;  /// 按钮在屏幕左侧
            });
          }
          else
          {
            /// 申请动画资源
            _controller = new AnimationController(vsync: this,duration: new Duration(milliseconds: 100)); //0.1动画
            _animation = new Tween(begin: e.position.dx,end: pixelDetails.width - 50).animate(_controller)  //返回右侧坐标需要减去自身宽度及50，因坐标以图形左上角为基点
              ..addListener(() {
                setState(() {
                  windowModel.left = _animation.value; /// 动画更新x坐标
                });
              });
            await _controller.forward(); /// 等待动画结束
            _controller.dispose(); /// 释放动画资源
            setState(() {
              windowModel.isLeft = false; /// 按钮在屏幕右侧
            });
          }

          setState(() {
            windowModel.isEdge = true; /// 按钮返回至边缘，更新按钮状态
          });
        },
        child: GestureDetector(
          /// 拖拽更新
          onPanUpdate: (details){
            var pixelDetails = MediaQuery.of(context).size; /// 获取屏幕信息
            /// 拖拽后更新按钮信息，是否处于边缘
            if(windowModel.left + details.delta.dx > 0 && windowModel.left + details.delta.dx < pixelDetails.width - 50){
              setState(() {
                windowModel.isEdge = false;
              });
            }else{
              setState(() {
                windowModel.isEdge = true;
              });
            }
            /// 拖拽更新坐标
            setState(() {
              windowModel.left += details.delta.dx;
              windowModel.top += details.delta.dy;
            });
          },
          child: FutureBuilder(
            future:  loadImageByProvider(AssetImage(windowModel.dataList[0]['imageUrl'])),
            builder: (context,snapshot) => CustomPaint(
              size: Size(50.0,50.0),
              painter: FloatingButtonPainter(isLeft: windowModel.isLeft, isEdge:windowModel.isEdge,
                  isPress: isPress, buttonImage: snapshot.data),
            ),
          ),
        ),
      ),
    );
  }

  /// 通过ImageProvider获取ui.image
  Future<ui.Image> loadImageByProvider(
      ImageProvider provider, {
        ImageConfiguration config = ImageConfiguration.empty,
      }) async {
    Completer<ui.Image> completer = Completer<ui.Image>(); //完成的回调
    ImageStreamListener listener;
    ImageStream stream = provider.resolve(config); //获取图片流
    listener = ImageStreamListener((ImageInfo frame, bool sync) {
      //监听
      final ui.Image image = frame.image;
      completer.complete(image); //完成
      stream.removeListener(listener); //移除监听
    });
    stream.addListener(listener); //添加监听
    return completer.future; //返回
  }
}

class FloatingButtonPainter extends CustomPainter
{
  FloatingButtonPainter({
    Key key,
    @required this.isLeft,
    @required this.isEdge,
    @required this.isPress,
    @required this.buttonImage
  });

  /// 按钮是否在屏幕左侧，屏幕宽度 / 2
  final bool isLeft;
  /// 按钮是否在屏幕边界，左/右边界
  final bool isEdge;
  /// 按钮是否被按下
  final bool isPress;
  /// 内按钮图片 ui.image
  final ui.Image buttonImage;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    /// 按钮是否在边缘
    if(isEdge){
      /// 按钮在屏幕左边或右边
      if(isLeft)
        paintLeftEdgeButton(canvas, size);/// 绘制左边缘按钮
      else
        paintRightEdgeButton(canvas, size);/// 绘制右边缘按钮
    }
    else{
      paintCenterButton(canvas, size);/// 绘制中心按钮
    }
  }

  ///绘制左边界悬浮按钮
  void paintLeftEdgeButton(Canvas canvas,Size size)
  {
    ///绘制按钮内层
    var paint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(0xF3, 0xF3, 0xF3, 0.9);
    //..color = Color.fromRGBO(0xDA,0xDA,0xDA,0.9);

    /// path : 按钮内边缘路径
    var path = new Path() ..moveTo(size.width / 2 , size.height - 1.5);
    path.lineTo(0.0, size.height - 1.5);
    path.lineTo(0.0, 1.5);
    path.lineTo(size.width / 2 ,1.5);
    Rect rect = Rect.fromCircle(center:Offset(size.width / 2,size.height / 2),radius: 23.5);
    path.arcTo(rect,pi * 1.5,pi,true);
    canvas.drawPath(path, paint);


    /// edgePath: 按钮外边缘路径,黑色线条
    var edgePath = new Path() ..moveTo(size.width / 2, size.height);
    edgePath.lineTo(0.0, size.height);
    edgePath.lineTo(0.0, 0.0);
    edgePath.lineTo(size.width / 2,0.0);
    Rect rect1 = Rect.fromCircle(center:Offset(size.width / 2,size.height / 2),radius: 25);
    edgePath.arcTo(rect1,pi * 1.5,pi,true);

    paint
      ..isAntiAlias = true
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal,0.25) /// 线条模糊
      ..style = PaintingStyle.stroke
      ..color = Color.fromRGBO(0xCF, 0xCF, 0xCF, 1);
    canvas.drawPath(edgePath, paint);

    /// 按下则画阴影，表示选中
    if(isPress) canvas.drawShadow(edgePath, Color.fromRGBO(0xDA, 0xDA, 0xDA, 0.3), 0, false);

    if(buttonImage == null)
      return ;
    /// 绘制中间图标
    paint = new Paint();
    canvas.save(); /// 剪裁前保存图层
    RRect imageRRect = RRect.fromRectAndRadius(Rect.fromLTWH(size.width / 2  - 17.5,size.width / 2 - 17.5, 35, 35),Radius.circular(17.5));
    canvas.clipRRect(imageRRect);/// 图片为圆形，圆形剪裁
    canvas.drawColor(Colors.white, BlendMode.srcOver); /// 设置填充颜色为白色
    Rect srcRect = Rect.fromLTWH(0.0, 0.0, buttonImage.width.toDouble(), buttonImage.height.toDouble());
    Rect dstRect = Rect.fromLTWH(size.width / 2 - 17.5, size.height / 2 - 17.5, 35, 35);
    canvas.drawImageRect(buttonImage, srcRect, dstRect, paint);
    canvas.restore();/// 图片绘制完毕恢复图层
  }

  /// 绘制右边界按钮
  void paintRightEdgeButton(Canvas canvas,Size size){

    var paint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(0xF3, 0xF3, 0xF3, 0.9);

    var path = Path() ..moveTo(size.width / 2, 1.5);
    path.lineTo(size.width,1.5);
    path.lineTo(size.width, size.height - 1.5);
    path.lineTo(size.width / 2, size.height - 1.5);

    Rect rect = Rect.fromCircle(center: Offset(size.width / 2,size.height / 2),radius: 23.5);
    path.arcTo(rect, pi * 0.5, pi, true);

    canvas.drawPath(path, paint);/// 绘制


    /// edgePath: 按钮外边缘路径
    var edgePath = Path() ..moveTo(size.width / 2,0.0);
    edgePath.lineTo(size.width,0.0);
    edgePath.lineTo(size.width, size.height);
    edgePath.lineTo(size.width / 2, size.height);
    Rect edgeRect = Rect.fromCircle(center: Offset(size.width / 2,size.height / 2),radius: 25);
    edgePath.arcTo(edgeRect, pi * 0.5, pi, true);

    paint
      ..isAntiAlias = true
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal,0.25)
      ..style = PaintingStyle.stroke
      ..color = Color.fromRGBO(0xCF, 0xCF, 0xCF, 1);
    canvas.drawPath(edgePath, paint);

    /// 如果按下则绘制阴影
    if(isPress)
      canvas.drawShadow(path, Color.fromRGBO(0xDA, 0xDA, 0xDA, 0.3), 0, false);

    /// 防止传入null
    if(buttonImage == null)
      return ;
    /// 绘制中间图标
    paint = new Paint();
    canvas.save(); /// 剪裁前保存图层
    RRect imageRRect = RRect.fromRectAndRadius(Rect.fromLTWH(size.width / 2  - 17.5,size.width / 2 - 17.5, 35, 35),Radius.circular(17.5));
    canvas.clipRRect(imageRRect);/// 图片为圆形，圆形剪裁
    canvas.drawColor(Colors.white, BlendMode.srcOver); /// 设置填充颜色为白色
    Rect srcRect = Rect.fromLTWH(0.0, 0.0, buttonImage.width.toDouble(), buttonImage.height.toDouble());
    Rect dstRect = Rect.fromLTWH(size.width / 2 - 17.5, size.height / 2 - 17.5, 35, 35);
    canvas.drawImageRect(buttonImage, srcRect, dstRect, paint);
    canvas.restore();/// 图片绘制完毕恢复图层
  }

  /// 绘制中心按钮
  void paintCenterButton(Canvas canvas,Size size)
  {
    /// 绘制按钮内层
    var paint = new Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(0xF3, 0xF3, 0xF3, 0.9);
    canvas.drawCircle(Offset(size.width / 2,size.height / 2), 23.5, paint);

    /// 绘制按钮外层边线
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..maskFilter = MaskFilter.blur(BlurStyle.normal,0.25)
      ..color = Color.fromRGBO(0xCF, 0xCF, 0xCF, 1);
    canvas.drawCircle(Offset(size.width / 2,size.height / 2), 25, paint);

    /// 如果按下则绘制阴影
    if(isPress){
      var circleRect = Rect.fromCircle(center: Offset(size.width / 2,size.height / 2),radius: 25);
      var circlePath = new Path() ..moveTo(size.width / 2, size.height / 2);
      circlePath.arcTo(circleRect, 0, 2 * 3.14, true);
      canvas.drawShadow(circlePath, Color.fromRGBO(0xCF, 0xCF, 0xCF, 0.3), 0.5, false);
    }

    if(buttonImage == null)
      return ;
    /// 绘制中间图标
    paint = new Paint();
    canvas.save(); /// 图片剪裁前保存图层
    RRect imageRRect = RRect.fromRectAndRadius(Rect.fromLTWH(size.width / 2  - 17.5,size.width / 2 - 17.5, 35, 35),Radius.circular(35));
    canvas.clipRRect(imageRRect);/// 图片为圆形，圆形剪裁
    canvas.drawColor(Colors.white, BlendMode.srcOver); /// 设置填充颜色为白色
    Rect srcRect = Rect.fromLTWH(0.0, 0.0, buttonImage.width.toDouble(), buttonImage.height.toDouble());
    Rect dstRect = Rect.fromLTWH(size.width / 2 - 17.5, size.height / 2 - 17.5, 35, 35);
    canvas.drawImageRect(buttonImage, srcRect, dstRect, paint);
    canvas.restore();/// 恢复剪裁前的图层

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

