import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('7.6自定义滚动条'),
      ),
      body: const ViewPage(),
    );
  }
}

class ViewPage extends StatefulWidget {
  const ViewPage({Key? key}) : super(key: key);

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  double _alignmentY = -1.0;

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    // print('滚动组件最大滚动距离:${metrics.maxScrollExtent}');
    // print('当前滚动位置:${metrics.pixels}');
    setState(() {
      _alignmentY = -1 + (metrics.pixels / metrics.maxScrollExtent) * 2;
    });

    // print(_alignmentY);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          ListView.builder(
            reverse: false,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  child: Text('$index'),
                ),
              );
            },
            itemCount: 30,
            itemExtent: 50,
          ),
          //滚动条
          Container(
            alignment: Alignment(1, _alignmentY),
            padding: const EdgeInsets.only(right: 5),
            child: _ScrollBar(),
          )
        ],
      ),
    );
  }
}

class _ScrollBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 60,
      decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.blue),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Icon(
            Icons.arrow_drop_up,
            size: 18,
          ),
          Icon(
            Icons.arrow_drop_down,
            size: 18,
          ),
        ],
      ),
    );
  }
}
