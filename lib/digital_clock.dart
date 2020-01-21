// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'package:flutter_gifimage/flutter_gifimage.dart';



enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.blue,
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.lightGreenAccent,
  _Element.shadow: Color(0xFF174EA6),
};

final radiansPerTick = radians(360 / 60);
final radiansPerHour = radians(360 / 12);

final AnimationController animation = AnimationController(
  duration: const Duration(milliseconds: 1800),
  vsync: const NonStopVSync(),
)..repeat();

final Tween tween = Tween(begin: 0.0, end: math.pi);

var square = Container(
  width: 100,
  height: 100,
  transform: Matrix4.identity(),
  color: Colors.amber,
);

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> with TickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  AnimationController animationController;
  Animation<double> animation;
//  GifController controller1 = GifController(vsync: );

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    animation = Tween<double>(
      begin: 0,
      end: 12.5664
    ).animate(animationController);

    animationController.forward();
    animation.addStatusListener((status){
      if(status == AnimationStatus.completed){
        animationController.repeat();
      }
    });
//    controller1 = GifController(vsync: this);
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
//      _timer = Timer(
//        Duration(minutes: 1) -
//            Duration(seconds: _dateTime.second) -
//            Duration(milliseconds: _dateTime.millisecond),
//        _updateTime,
//      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
       _timer = Timer(
         Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
         _updateTime,
       );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 50;
//    final offset = -fontSize / 7;
    final defaultStyle = TextStyle(
//      color: colors[_Element.text],
      color: Colors.lime,
      fontSize: fontSize,
    );
    final temp = widget.model.temperatureString;
    final weatherCondition = widget.model.weatherString;

    AssetImage gifChoose(){
      if(DateTime.now().minute == 05 && DateTime.now().second== 58) {
        return AssetImage("assets/inkman-hour-tick.gif");
      }
      return AssetImage("assets/inkman-sit-idle.gif");
    }

//    animation.addListener((){
//      square.transform = Matrix4.rotationZ(tween.evaluate(animation));
//    });


    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
            image: new AssetImage("assets/background.jpg")
        )
      ),
      child: Stack(
        children: <Widget>[
          Image(
            image: AssetImage("assets/clock_face.png"),
          ),
          // Hour handle
          Transform.rotate(
            angle: DateTime.now().hour * radiansPerHour * -1
              + (DateTime.now().minute / 60) * radiansPerHour,
            child: Image(
              image: AssetImage("assets/hour_handle.png"),
            ),
          ),
          Transform.rotate(
            angle: DateTime.now().minute * radiansPerTick * -1,
            child: Image(
              image: AssetImage("assets/minute_handle.png"),
            ),
          ),
          Image(
            image: AssetImage("assets/deck.png"),
          ),
          Image(
            image: AssetImage("assets/overlay_shadow.png"),
          ),
          // Big clock
          // Gear small top
          Positioned(
            top: -200, left: -400,
            child: Transform.scale(
              scale: 0.3,
//              child: Transform.rotate(
//                angle: double.parse(second) * -300,
                child: Image.asset("assets/cog_small.png")
//              )
            ),
          ),
          Positioned(
            top: -550, left: -500,
            child: Transform.scale(
              scale: 0.3,
//              child: Transform.rotate(
//                angle: double.parse(second) * 3,
                child: Image.asset("assets/cog_large.png")
//              ),
            )
          ),
//           Pendilum
          Positioned(
            top: 0, right: 0,
            child: Transform.scale(
              scale: 1,
              child: Image.asset("assets/pendilum.png"),
            ),

          ),
          // Composition
//          Image(
//            image: AssetImage("assets/composition.jpg"),
//          ),
          // Gears center
          Positioned(
              top: 430, left: 200,
              child: Container(
                height: 130, width: 650,
//                color: Colors.blue,
                child: Stack(
                  children: <Widget>[
                    // Gear 1st
                    Positioned(
                        top: 60, left: 0,
                        child: Transform.scale(
                          scale: 1,
//                          child: Transform.rotate(
//                              angle: double.parse(second) * 3,
                              child: Image.asset("assets/cog_small_200.png")
//                          ),
                        )
                    ),
                    // Gear 2nd
                    Positioned(
                        top: -35,
                        left: 100,
                        child: Transform.scale(
                          scale: 0.7,
//                          child: Transform.rotate(
//                              angle: double.parse(second) * 3,
                              child: Image.asset("assets/cog_large_350.png")
//                          ),
                        )
                    ),
                    // Gear 3rd
                    Positioned(
                        top: 35, left: 335,
                        child: Transform.scale(
                          scale: 0.85,
//                          child: Transform.rotate(
//                              angle: double.parse(second) * -3,
                              child: Image.asset("assets/cog_small_200.png")
//                          ),
                        )
                    ),
                    // Gear 4th
                    Positioned(
                        top: 25, left: 460,
                        child: Transform.scale(
                          scale: 0.5,
//                          child: Transform.rotate(
//                              angle: double.parse(second) * -3,
                              child: Image.asset("assets/cog_small_200.png")
//                          ),
                        )
                    ),
                  ],
                ),
              )
          ),
          Image(
            image: AssetImage("assets/props.png"),
          ),
          // Inkman animation
          GifImage(
            controller: GifController(vsync: this),
            image: AssetImage("assets/inkman-hour-tick.gif"),
          ),
          // Weather display
          Positioned(
            bottom: 210,
            right: 50,
            child: Container(
              width: 90,
              height: 60,
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          '$temp',
                          style: TextStyle(
                              color: _darkTheme[_Element.text]
                          )
                      ),
                      Text(
                        '$weatherCondition',
                        style: TextStyle(
                            color: _darkTheme[_Element.text]
                        ),
                      ),
                    ],
                  )
              ),
            ),
          ),
          // Analog clock
          Positioned(
            bottom: 130, right: 25,
            child: Container(
              width: 140,
              height: 55,
              child: Center(
                child: DefaultTextStyle(
                  style: defaultStyle,
                  child: Text(
                      '$hour:$minute:$second'
                  ),
                ),
              ),
            ),
          ),
          InfiniteAnimation(
            durationInSeconds: 2,
            child: Icon(
              Icons.expand_more,
              size: 40,
              color: Colors.lightGreenAccent
            ),
          )
        ],
      ),
    );
  }
}

class NonStopVSync implements TickerProvider {
  const NonStopVSync();
  @override
  Ticker createTicker(onTick) {
    Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
  }
}

class InfiniteAnimation extends StatefulWidget {
  final Widget child;
  final int durationInSeconds;

  InfiniteAnimation({@required this.child, this.durationInSeconds = 2});

  @override
  _DigitalClockState createState() => _DigitalClockState();

}
