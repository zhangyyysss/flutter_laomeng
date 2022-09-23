import 'dart:math';

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
        title: const Text('12-14 模仿点赞功能'),
      ),
      body: Center(
        child: ViewPage(),
      ),
    );
  }
}

class ViewPage extends StatefulWidget {
  var like;

  ViewPage({Key? key, this.like = false}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconAnimation;
  late Animation<double> _circleAnimation;

  ///
  /// 未点赞icon
  ///
  static const Icon _unLikeIcon = Icon(
    IconData(0xe8ad, fontFamily: 'appIconFonts'),
  );

  ///
  /// 点赞icon
  ///
  static const Icon _likeIcon = Icon(
    IconData(0xe8c3, fontFamily: 'appIconFonts'),
    color: Color(0xFF1afa29),
  );

  @override
  initState() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    _iconAnimation = Tween(begin: 1.0, end: 1.3).animate(_animationController);

    // TweenSequence 队列? 装载这两个以上TweenSequenceItem可以实现一次性走完的动画?
    // 所以我们每一次点击就会先变大后变小
    _iconAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_animationController);

    _circleAnimation =
        Tween(begin: 1.0, end: 0.0).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return _buildLikeIcon();
  }

  _buildLikeIcon() {
    return ScaleTransition(
      scale: _iconAnimation,
      child: _buildCircle(),
    );
  }

  _clickIcon() {
    // 如果在动画过程中我们直接终止
    if (_iconAnimation.status == AnimationStatus.forward ||
        _iconAnimation.status == AnimationStatus.reverse) {
      return;
    }
    setState(() {
      widget.like = !widget.like;
    });
    // 如果动画状态为dismissed(起始态)我们动画向前!
    // 如果动画状态为completed(结束态)我们动画反转!
    if (_iconAnimation.status == AnimationStatus.dismissed) {
      _animationController.forward();
    } else if (_iconAnimation.status == AnimationStatus.completed) {
      _animationController.reverse();
    }
  }

  _buildCircle() {
    return !widget.like
        ? IconButton(
            padding: const EdgeInsets.all(0),
            icon: _unLikeIcon,
            onPressed: () {
              _clickIcon();
            },
          )
        : AnimatedBuilder(
            animation: _circleAnimation,
            builder: (BuildContext context, Widget? child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF5FA0EC)
                          .withOpacity(_circleAnimation.value),
                      width: _circleAnimation.value * 8),
                ),
                // child: IconButton(
                //   padding: const EdgeInsets.all(0),
                //   icon: _likeIcon,
                //   onPressed: () {
                //     _clickIcon();
                //   },
                // ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      _buildCirclePoints(),
                      Center(
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: _likeIcon,
                          onPressed: () {
                            _clickIcon();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
  }

  _buildCirclePoint(double radius, Color color) {
    return !widget.like
        ? Container()
        : AnimatedBuilder(
            animation: _circleAnimation,
            builder: (BuildContext context, Widget? child) {
              return Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(_circleAnimation.value)),
              );
            },
          );
  }

  _buildCirclePoints() {
    return Flow(
      delegate: CirclePointFlowDelegate(),
      children: <Widget>[
        _buildCirclePoint(2, const Color(0xFF97B1CE)),
        _buildCirclePoint(5, const Color(0xFF4AC6B7)),
        _buildCirclePoint(2, const Color(0xFF97B1CE)),
        _buildCirclePoint(5, const Color(0xFF4AC6B7)),
        _buildCirclePoint(2, const Color(0xFF97B1CE)),
        _buildCirclePoint(5, const Color(0xFF4AC6B7)),
        _buildCirclePoint(2, const Color(0xFF97B1CE)),
        _buildCirclePoint(5, const Color(0xFF4AC6B7)),
        _buildCirclePoint(2, const Color(0xFF97B1CE)),
        _buildCirclePoint(5, const Color(0xFF4AC6B7)),
        _buildCirclePoint(2, const Color(0xFF97B1CE)),
        _buildCirclePoint(5, const Color(0xFF4AC6B7)),
        _buildCirclePoint(2, const Color(0xFF97B1CE)),
        _buildCirclePoint(5, const Color(0xFF4AC6B7)),
        _buildCirclePoint(2, const Color(0xFF97B1CE)),
        _buildCirclePoint(5, const Color(0xFF4AC6B7)),
      ],
    );
  }
}

class CirclePointFlowDelegate extends FlowDelegate {
  CirclePointFlowDelegate();

  @override
  void paintChildren(FlowPaintingContext context) {
    var radius = min(context.size.width, context.size.height) / 2.0;
    //中心点
    double rx = radius;
    double ry = radius;
    for (int i = 0; i < context.childCount; i++) {
      if (i % 2 == 0) {
        double x =
            rx + (radius - 5) * cos(i * 2 * pi / (context.childCount - 1));
        double y =
            ry + (radius - 5) * sin(i * 2 * pi / (context.childCount - 1));
        context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
      } else {
        double x = rx +
            (radius - 5) *
                cos((i - 1) * 2 * pi / (context.childCount - 1) +
                    2 * pi / ((context.childCount - 1) * 3));
        double y = ry +
            (radius - 5) *
                sin((i - 1) * 2 * pi / (context.childCount - 1) +
                    2 * pi / ((context.childCount - 1) * 3));
        context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
      }
    }
  }

  @override
  bool shouldRepaint(FlowDelegate oldDelegate) => true;
}
