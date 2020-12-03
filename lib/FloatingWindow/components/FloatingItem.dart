import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';
import 'package:floating_window/FloatingWindow/models/ClickNotification.dart';

/// [FloatingItem]一个单独功能完善的列表项类
class FloatingItem extends StatefulWidget {

  FloatingItem({
    @required this.top,
    @required this.isLeft,
    @required this.title,
    @required this.imageProvider,
    @required this.index,
    @required this.left,
    @required this.isEntering,
    this.width,
    Key key
  });
  /// [index] 列表项的索引值
  int index;

  /// [top]列表项的y坐标值
  double top;
  /// [left]列表项的x坐标值
  double left;

  ///[isLeft] 列表项是否在左侧，否则是右侧
  bool isLeft;
  /// [title] 列表项的文字说明
  String title;
  ///[imageProvider] 列表项Logo的imageProvider
  ImageProvider imageProvider;
  ///[width] 屏幕宽度的 1 / 2
  double width;

  ///[isEntering] 列表项是否触发进场动画
  bool isEntering;

  @override
  _FloatingItemState createState() => _FloatingItemState();

  /// 全部列表项执行退场动画
  static void reverse(){
    for(int i = 0; i < _FloatingItemState.animationControllers.length; ++i) {
      if(!_FloatingItemState.animationControllers[i].toString().contains('DISPOSED'))
        _FloatingItemState.animationControllers[i].reverse();
    }
  }

  /// 全部列表项执行进场动画
  static void forward(){
    for(int i = 0; i < _FloatingItemState.animationControllers.length; ++i) {
      if(!_FloatingItemState.animationControllers[i].toString().contains('DISPOSED'))
        _FloatingItemState.animationControllers[i].forward();
    }
  }

  /// 每次更新时释放所有动画资源，清空动画控制器列表
  static void resetList(){
    for(int i = 0; i < _FloatingItemState.animationControllers.length;++i){
      if(!_FloatingItemState.animationControllers[i].toString().contains('DISPOSED')){
        _FloatingItemState.animationControllers[i].dispose();
      }
    }
    _FloatingItemState.animationControllers.clear();
    _FloatingItemState.animationControllers = [];
  }

}

class _FloatingItemState extends State<FloatingItem> with TickerProviderStateMixin{

  /// [isPress] 列表项是否被按下
  bool isPress = false;

  ///[image] 列表项Logo的[ui.Image]对象，用于绘制Logo
  ui.Image image;

  /// [animationController] 列表关闭动画的控制器
  AnimationController animationController;

  /// [animationController] 所有列表项的动画控制器列表
  static List<AnimationController> animationControllers = [];

  /// [animation] 列表项的关闭动画
  Animation animation;


  @override
  void initState() {
    // TODO: implement initState
    isPress = false;
    /// 获取Logo的ui.Image对象
    loadImageByProvider(widget.imageProvider).then((value) {
      setState(() {
        image = value;
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.left,
        top: widget.top,
        child: GestureDetector(
          /// 监听按下事件，在点击区域内则将[isPress]设为true，若在关闭区域内则不做任何操作
            onPanDown: (details) {
              if (widget.isLeft) {
                /// 点击区域内
                if (details.globalPosition.dx < widget.width) {
                  setState(() {
                    isPress = true;
                  });
                }
              }
              else{
                /// 点击区域内
                if(details.globalPosition.dx < widget.width * 2 - 50){
                  setState(() {
                    isPress = true;
                  });
                }
              }
            },
            /// 监听抬起事件
            onTapUp: (details) async {
              /// 通过左右列表项来决定关闭的区域，以及选中区域，触发相应的关闭或选中事件
              if(widget.isLeft){
                /// 位于关闭区域
                if(details.globalPosition.dx >= widget.width && !isPress){
                  /// 等待关闭动画执行完毕
                  await animationController.reverse();
                  /// 通知父级触发关闭事件
                  ClickNotification(deletedIndex: widget.index).dispatch(context);
                }
                else{
                  /// 通知父级触发相应的点击事件
                  ClickNotification(clickIndex: widget.index).dispatch(context);
                }
              }
              else{
                /// 位于关闭区域
                if(details.globalPosition.dx >= widget.width * 2 - 50.0 && !isPress){
                  /// 设置从中间返回至边缘的关闭动画
                  await animationController.reverse();
                  /// 通知父级触发关闭事件
                  ClickNotification(deletedIndex: widget.index).dispatch(context);
                }
                else{
                  /// 通知父级触发选中事件
                  ClickNotification(clickIndex: widget.index).dispatch(context);
                }
              }
              /// 抬起后取消选中
              setState(() {
                isPress = false;
              });
            },
            onTapCancel: (){
              /// 超出范围取消选中
              setState(() {
                isPress = false;
              });
            },
            child: CustomPaint(
                size: new Size(widget.width + 50.0,50.0),
                painter: FloatingItemPainter(
                  title: widget.title,
                  isLeft: widget.isLeft,
                  isPress: isPress,
                  image: image,
                )
            )
        )
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

  @override
  void didUpdateWidget(FloatingItem oldWidget) {
    // TODO: implement didUpdateWidget
    animationController = new AnimationController(vsync: this,duration: new Duration(milliseconds: 100));
    /// 初始化进场动画
    if(widget.isLeft){
      animation = new Tween<double>(begin: -(widget.width + 50.0),end: 0.0).animate(animationController)
        ..addListener(() {
          setState(() {
            widget.left = animation.value;
          });
        });
    }
    else{
      animation = new Tween<double>(begin: widget.width * 2,end: widget.width -50.0).animate(animationController)
        ..addListener(() {
          setState(() {
            widget.left = animation.value;
          });
        });
    }
    animationControllers.add(animationController);
    /// 执行进场动画
    if(animationController.status == AnimationStatus.dismissed && widget.isEntering){
      animationController.forward();
    }
    /// 无需执行进场动画，将列表项置于动画末尾
    else{
      animationController.forward(from:100.0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    /// 释放动画资源，避免内存泄漏
    if(!animationController.toString().toString().contains('DISPOSED'))
      animationController.dispose();
    super.dispose();
  }
}

/// [FloatingItemPainter]：画笔类，绘制列表项
class FloatingItemPainter extends CustomPainter{

  FloatingItemPainter({
    @required this.title,
    @required this.isLeft,
    @required this.isPress,
    @required this.image
  });

  /// [isLeft] 列表项在左侧/右侧
  bool isLeft = true;
  /// [isPress] 列表项是否被选中，选中则绘制阴影
  bool isPress;
  /// [title] 绘制列表项内容
  String title;
  /// [image] 列表项图标
  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    if(size.width < 50.0){
      return ;
    }
    else{
      if(isLeft){
        paintLeftItem(canvas, size);
        /// 防止传入 null
        if(image != null)
          paintLogo(canvas, size);
        paintParagraph(canvas, size);
        paintCross(canvas, size);
      }else{
        paintRightItem(canvas, size);
        paintParagraph(canvas, size);
        paintCross(canvas, size);
        /// 防止传入null
        if(image != null)
          paintLogo(canvas, size);
      }
    }
  }

  /// 通过传入[Canvas]对象和[Size]对象绘制左侧列表项外边缘，阴影以及内层
  void paintLeftItem(Canvas canvas,Size size){

    /// 外边缘路径
    Path edgePath = new Path() ..moveTo(size.width - 25.0, 0.0);
    edgePath.lineTo(0.0, 0.0);
    edgePath.lineTo(0.0, size.height);
    edgePath.lineTo(size.width - 25.0, size.height);
    edgePath.arcTo(Rect.fromCircle(center: Offset(size.width - 25.0,size.height / 2),radius: 25), pi * 1.5, pi, true);

    /// 绘制背景阴影
    canvas.drawShadow(edgePath, Color.fromRGBO(0xDA, 0xDA, 0xDA, 0.3), 3, true);

    var paint = new Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    /// 通过填充去除列表项内部多余的阴影
    canvas.drawPath(edgePath, paint);

    paint = new Paint()
      ..isAntiAlias = true  // 抗锯齿
      ..style = PaintingStyle.stroke
      ..color = Color.fromRGBO(0xCF, 0xCF, 0xCF, 1)
      ..strokeWidth = 0.75
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 0.25); //边缘模糊

    /// 绘制列表项外边缘
    canvas.drawPath(edgePath, paint);

    /// [innerPath] 内层路径
    Path innerPath = new Path() ..moveTo(size.width - 25.0, 1.5);
    innerPath.lineTo(0.0, 1.5);
    innerPath.lineTo(0.0, size.height - 1.5);
    innerPath.lineTo(size.width - 25.0, size.height - 1.5);
    innerPath.arcTo(Rect.fromCircle(center: Offset(size.width - 25.0,size.height / 2),radius: 23.5), pi * 1.5, pi, true);

    paint = new Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(0xF3, 0xF3, 0xF3, 1);

    /// 绘制列表项内层
    canvas.drawPath(innerPath, paint);



    /// 绘制选中阴影
    if(isPress)
      canvas.drawShadow(edgePath, Color.fromRGBO(0xDA, 0xDA, 0xDA, 0.3), 0, true);

  }

  /// 通过传入[Canvas]对象和[Size]对象绘制左侧列表项外边缘，阴影以及内层
  void paintRightItem(Canvas canvas,Size size){

    /// 外边缘路径
    Path edgePath = new Path() ..moveTo(25.0, 0.0);
    edgePath.lineTo(size.width, 0.0);
    edgePath.lineTo(size.width, size.height);
    edgePath.lineTo(25.0, size.height);
    edgePath.arcTo(Rect.fromCircle(center: Offset(25.0,size.height / 2),radius: 25), pi * 0.5, pi, true);

    /// 绘制列表项背景阴影
    canvas.drawShadow(edgePath, Color.fromRGBO(0xDA, 0xDA, 0xDA, 0.3), 3, true);

    var paint = new Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    /// 通过填充白色去除列表项内部多余阴影
    canvas.drawPath(edgePath, paint);
    paint = new Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = Color.fromRGBO(0xCF, 0xCF, 0xCF, 1)
      ..strokeWidth = 0.75
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 0.25); //边缘模糊

    /// 绘制列表项外边缘
    canvas.drawPath(edgePath, paint);

    /// 列表项内层路径
    Path innerPath = new Path() ..moveTo(25.0, 1.5);
    innerPath.lineTo(size.width, 1.5);
    innerPath.lineTo(size.width, size.height - 1.5);
    innerPath.lineTo(25.0, size.height - 1.5);
    innerPath.arcTo(Rect.fromCircle(center: Offset(25.0,25.0),radius: 23.5), pi * 0.5, pi, true);

    paint = new Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(0xF3, 0xF3, 0xF3, 1);

    /// 绘制列表项内层
    canvas.drawPath(innerPath, paint);

    /// 条件绘制选中阴影
    if(isPress)
      canvas.drawShadow(edgePath, Color.fromRGBO(0xDA, 0xDA, 0xDA, 0.3), 0, false);
  }

  /// 通过传入[Canvas]对象和[Size]对象以及[image]绘制列表项Logo
  void paintLogo(Canvas canvas,Size size){
    //绘制中间图标
    var paint = new Paint();
    canvas.save(); //剪裁前保存图层
    RRect imageRRect = RRect.fromRectAndRadius(Rect.fromLTWH(25.0  - 17.5,25.0- 17.5, 35, 35),Radius.circular(17.5));
    canvas.clipRRect(imageRRect);//图片为圆形，圆形剪裁
    canvas.drawColor(Colors.white, BlendMode.srcOver); //设置填充颜色为白色
    Rect srcRect = Rect.fromLTWH(0.0, 0.0, image.width.toDouble(), image.height.toDouble());
    Rect dstRect = Rect.fromLTWH(25.0 - 17.5, 25.0 - 17.5, 35, 35);
    canvas.drawImageRect(image, srcRect, dstRect, paint);
    canvas.restore();//图片绘制完毕恢复图层
  }

  /// 通过传入[Canvas]对象和[Size]对象以及[title]绘制列表项的文字说明部分
  void paintParagraph(Canvas canvas,Size size){

    ui.ParagraphBuilder pb  = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: TextAlign.left,//左对齐
        fontWeight: FontWeight.w500,
        fontSize: 14.0, //字体大小
        fontStyle: FontStyle.normal,
        maxLines: 1, //行数限制
        ellipsis: "…" //省略显示
    ));

    pb.pushStyle(ui.TextStyle(color: Color.fromRGBO(61, 61, 61, 1),)); //字体颜色
    double pcLength = size.width - 100.0; //限制绘制字符串宽度
    ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: pcLength);
    pb.addText(title);

    ui.Paragraph paragraph = pb.build() ..layout(pc);

    Offset startOffset = Offset(50.0,18.0); // 字符串显示位置

    /// 绘制字符串
    canvas.drawParagraph(paragraph, startOffset);

  }

  /// 通过传入[Canvas]对象和[Size]对象绘制列表项末尾的交叉部分，
  void paintCross(Canvas canvas,Size size){

    /// ‘x’ 路径
    Path crossPath = new Path()
      ..moveTo(size.width - 28.5, 21.5);
    crossPath.lineTo(size.width - 21.5,28.5);
    crossPath.moveTo(size.width - 28.5, 28.5);
    crossPath.lineTo(size.width - 21.5, 21.5);

    var paint = new Paint()
      ..isAntiAlias = true
      ..color = Color.fromRGBO(61, 61, 61, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.25); // 线段模糊

    /// 绘制交叉路径
    canvas.drawPath(crossPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}