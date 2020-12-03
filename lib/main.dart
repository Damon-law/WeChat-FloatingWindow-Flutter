import 'package:flutter/material.dart';
import 'FloatingWindow/FloatingWindow.dart';
import 'FloatingWindow/FloatingWindowOverlayEntry.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:new Scaffold(
        body: Stack(
          children: [
            /// 用于测试遮盖层是否生效
            Positioned(
              left: 250,
              top: 250,
              child: Container(width: 50,height: 100,color: Colors.red,),
            ),
            Positioned(
              left: 250,
              top: 50,
              child:TestWidget()
            ),
          ],
      ),
      ),
    );
  }
}

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RaisedButton(
          child: Text('show'),
        ),
        RaisedButton(
          onPressed: () => FloatingWindowOverlayEntry.add(context,element: {'title': "微信悬浮窗","imageUrl":"assets/Images/vnote.png"}),
          child: Text('add'),
        )
      ],
    );
  }
}
