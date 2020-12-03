/// [FloatingWindowModel] 表示悬浮窗共享的数据
class FloatingWindowModel {

  FloatingWindowModel({
    this.isLeft = true,
    this.top = 100.0,
    this.itemTop = -1.0,
    List<Map<String,String>> dataList,
  }) : dataList = dataList;


  /// [isEmpty] 列表是非为空
  get isEmpty =>  dataList.length == 0;

  /// [isLeft]：悬浮窗位于屏幕左侧/右侧
  bool isLeft;
  /// [isEdge] 悬浮窗是否在边缘
  bool isEdge = true;
  /// [isButton]
  bool isButton = true;

  /// [top] 悬浮窗纵坐标
  double top;
  /// [itemTop] 悬浮列表的纵坐标
  double itemTop;
  /// [left] 悬浮窗横坐标
  double left = 0.0;

  /// [dataList] 列表数据
  List<Map<String,String>>dataList;
  /// 删除的列表项索引
  int deleteIndex = -1;
}