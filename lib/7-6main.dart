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
        title: const Text('7.6自定义轮播图'),
      ),
      body: Center(
        child: ViewPage(),
      ),
    );
  }
}

class ViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  var imgList = [
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.jj20.com%2Fup%2Fallimg%2Ftp09%2F210F2130512J47-0-lp.jpg&refer=http%3A%2F%2Fimg.jj20.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1663485372&t=847c1d129d0112b666d0241a2ad69476',
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.jj20.com%2Fup%2Fallimg%2Ftp09%2F21031FKU44S6-0-lp.jpg&refer=http%3A%2F%2Fimg.jj20.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1663485383&t=b09aa278880d7d180eeda0774080123b'
  ];
  late PageController _pageController;

  var _currPageValue = 0.0;

  //缩放系数
  final double _scaleFactor = .8;

  //view page height
  final double _height = 230.0;

  @override
  void initState() {
    super.initState();
    // 控制每一个Page不占满，
    _pageController = PageController(viewportFraction: 0.9);
    // 监控pageView的滚动~setState设置_currPageValue的值
    _pageController.addListener(() {
      setState(() {
        _currPageValue = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: _height,
        child: PageView.builder(
          itemBuilder: (context, index) => _buildPageItem(index),
          itemCount: 10,
          controller: _pageController,
        ));
  }

  // 1.思路, 左边右边缩小到的比例是一致的,我们还需要上下移动,因为缩小了就定格排列,而不是居中,所以在移动的过程中也需要上下移动配合
  _buildPageItem(int index) {
    // 初始化Matrix4.identity()
    Matrix4 matrix4 = Matrix4.identity();
    // 注意: _currPageValue 这个值在pageView中只需要过一半就可以变为下一个值,例子: 0 移动到 0.5 就已经变为 1了
    // 所以我们需要使用_currPageValue.floor()去处理
    if (index == _currPageValue.floor()) {
      //当前的item(静止)
      // currScale: 1.0
      // currTrans:  0.0

      // 移动过程中,_currPageValue是一个一直变动的值,例如: 0.1111 -> 0.899999
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      // Matrix4.diagonal3Values(1.0, 1.0, 1.0)所以不需要在垂直方向上压缩,
      // ..setTranslationRaw(0.0, 0.0, 0.0)且设置此齐次变换矩阵中的平移向量。
      matrix4 = Matrix4.diagonal3Values(1.0, currScale, 1.0)
        ..setTranslationRaw(0.0, currTrans, 0.0);
    } else if (index == _currPageValue.floor() + 1) {
      //右边的item
      // currScale: 0.8
      // currTrans: 230 * (1 - 0.8) / 2 = 23
      var currScale =
          _scaleFactor + (_currPageValue - index + 1) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;

      // Matrix4.diagonal3Values(1.0, 0.8, 1.0) 垂直方向上(y轴)压缩了为0.8
      // ..setTranslationRaw(0.0, 23, 0.0)且设置此齐次变换矩阵中的平移向量23
      matrix4 = Matrix4.diagonal3Values(1.0, currScale, 1.0)
        ..setTranslationRaw(0.0, currTrans, 0.0);
    } else if (index == _currPageValue.floor() - 1) {
      //左边
      // currScale: 0.8
      // currTrans: 230 * (1 - 0.8) / 2 = 23
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;

      // Matrix4.diagonal3Values(1.0, 0.8, 1.0) 垂直方向上(y轴)压缩了为0.8
      // ..setTranslationRaw(0.0, 23, 0.0)且设置此齐次变换矩阵中的平移向量23
      matrix4 = Matrix4.diagonal3Values(1.0, currScale, 1.0)
        ..setTranslationRaw(0.0, currTrans, 0.0);
    } else {
      //其他，不在屏幕显示的item
      matrix4 = Matrix4.diagonal3Values(1.0, _scaleFactor, 1.0)
        ..setTranslationRaw(0.0, _height * (1 - _scaleFactor) / 2, 0.0);
    }

    // 套一个Transform 这个widget,使用transform: matrix4
    return Transform(
      transform: matrix4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
                image: NetworkImage(imgList[index % 2]), fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }
}
