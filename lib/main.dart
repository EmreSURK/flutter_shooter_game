import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class Bullet extends GameObject {
  Bullet.fire(Player player)
      : super(
          width: 10.0.obs,
          height: 10.0.obs,
          top: RxDouble(player.centerTop),
          left: RxDouble(player.centerLeft),
          // TODO - that is wrong.
          horizontalSpeed: cos(player.playerDegree.value * pi / 4) * 0.5,
          verticalSpeed: sin(player.playerDegree.value * pi / 4) * 0.5,
          child: Container(
            color: Colors.deepOrange,
            width: 10,
            height: 10,
            alignment: Alignment.center,
            child: const Text(
              'O',
            ),
          ),
        );
}

class Player extends GameObject {
  Player()
      : super(
          width: 100.0.obs,
          height: 100.0.obs,
          top: 100.0.obs,
          left: 100.0.obs,
          child: Container(
            color: Colors.greenAccent,
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: const Text(
              'Player',
            ),
          ),
        );

  double maxSpeed = 1.0;

  // TODO spawn game object - bullet
  void fire() {
    //
    final b = Bullet.fire(this);
    gameObjects.add(b);
  }

  void speedIncrease({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    // print("speed : $horizontalSpeed $verticalSpeed");

    //horizontalSpeed += horizontal;
    //verticalSpeed += vertical;
    if (horizontal != 0.0) {
      horizontalSpeed += horizontal;
    } else {
      horizontalSpeed = 0;
    }

    if (vertical != 0.0) {
      verticalSpeed += vertical;
    } else {
      verticalSpeed = 0;
    }

    if (verticalSpeed < -1 * maxSpeed) verticalSpeed = -1 * maxSpeed;
    if (verticalSpeed > maxSpeed) verticalSpeed = maxSpeed;

    if (horizontalSpeed < -1 * maxSpeed) horizontalSpeed = -1 * maxSpeed;
    if (horizontalSpeed > maxSpeed) horizontalSpeed = maxSpeed;

    // TODO set max.
  }
}

class GameObject {
  double get centerLeft => left.value + width / 2;
  double get centerTop => top.value + height / 2;

  late double acc;

  late RxDouble width;
  late RxDouble height;

  late RxDouble left;
  late RxDouble top;

  late double horizontalSpeed;
  late double verticalSpeed;

  var playerDegree = 0.0.obs;

  final playerKey = GlobalKey();

  late final child;

  GameObject({
    required this.width,
    required this.height,
    required this.top,
    required this.left,
    required this.child,
    this.horizontalSpeed = 0.0,
    this.verticalSpeed = 0.0,
    this.acc = 0.01,
  });

  Widget renderedWidget() {
    return Positioned(
      left: left.value,
      top: top.value,
      child: Transform.rotate(
        angle: playerDegree.value,
        child: child,
      ),
    );
  }

  void lookAt(GameObject toGameObject) {
    // TODO
  }

  void tick() {
    top.value = top.value + verticalSpeed;
    left.value = left.value + horizontalSpeed;
    // TODO
  }
}

final gameObjects = <GameObject>[];

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    addPlayer();
    Timer.periodic(Duration(milliseconds: 1), (timer) {
      timerTick();
    });
  }

  var wUp = false;
  var aUp = false;
  var sUp = false;
  var dUp = false;

  double get playerCenterLeft => playerLeft + 25;
  double get playerCenterTop => playerTop + 25;

  var playerLeft = 10.0;
  var playerTop = 10.0;
  var playerDegree = 0.0.obs;
  final playerKey = GlobalKey();

  void timerTick() {
    var verticalMove = 0.0;
    var horizontalMove = 0.0;
    if (wUp) verticalMove = -1;
    if (sUp) verticalMove = 1;
    if (aUp) horizontalMove = -1;
    if (dUp) horizontalMove = 1;

    // playerLeft = playerLeft + horizontalMove * 0.3;
    // playerTop = playerTop + verticalMove * 0.3;
    horizontalMove = horizontalMove * player.acc;
    verticalMove = verticalMove * player.acc;

    player.speedIncrease(horizontal: horizontalMove, vertical: verticalMove);

    gameObjects.forEach((element) {
      element.tick();
    });
    // setState(() {});
  }

  final player = Player();

  void mouseMoved(PointerHoverEvent event) {
    final xdif = (player.centerLeft + 25) - event.localPosition.dx;
    final ydif = (player.centerTop + 25) - event.localPosition.dy;
    final sinx = ydif / xdif;

    var d = atan(sinx);
    // print("sinx : $d \t $xdif \t $ydif");
    if (xdif > 0) {
      d = d - pi;
    }

    player.playerDegree.value = d;

    // playerDegree.value = d;
  }

  void addPlayer() {
    gameObjects.add(player);
  }

  final listenerfocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Focus(
        onKey: (FocusNode node, RawKeyEvent event) => KeyEventResult.handled,
        child: KeyboardListener(
          focusNode: listenerfocusNode,
          autofocus: true,
          onKeyEvent: (event) {
            final char = event.physicalKey.debugName?.replaceAll('Key ', '').toLowerCase();
            if (event is KeyDownEvent) {
              if (char == 'w') wUp = true;
              if (char == 's') sUp = true;
              if (char == 'a') aUp = true;
              if (char == 'd') dUp = true;
            }

            if (event is KeyUpEvent) {
              if (char == 'w') wUp = false;
              if (char == 's') sUp = false;
              if (char == 'a') aUp = false;
              if (char == 'd') dUp = false;
            }
            final key = event.character;

            // print(event);
          },
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Obx(() {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ...gameObjects.map((e) => e.renderedWidget()).toList(),
                /* Positioned(
                    left: playerLeft,
                    top: playerTop,
                    child: Obx(() {
                      return Transform.rotate(
                        angle: playerDegree.value,
                        child: Container(
                          color: Colors.greenAccent,
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          child: const Text(
                            'Player',
                          ),
                        ),
                      );
                    }),
                  ),*/
                MouseRegion(
                  onHover: (event) {
                    mouseMoved(event);
                  },
                  child: InkWell(
                    onTap: player.fire,
                    child: Container(
                      constraints: BoxConstraints.expand(),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}
