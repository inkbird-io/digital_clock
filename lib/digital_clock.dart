// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.blue,
  _Element.text: Colors.limeAccent,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.lightGreenAccent,
};

final radiansPerTick = radians(360 / 60);
final radiansPerHour = radians(360 / 12);

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
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  List<int> minutes = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

  AssetImage clockOutsideAnimation(){
    if(_dateTime.minute == 0 && _dateTime.second > 0 && _dateTime.second < 18) {
      // he is outside playing trumpet
      // 5400 mls
      return AssetImage("assets/inkman-hour-announcement-trumpet.gif");
    }
    return AssetImage("assets/clock_outside.png");
  }

  AssetImage insideAnimation(){
    if(minutes.contains(_dateTime.minute) && _dateTime.second < 8) {
      // every other five minutes he checks clock
      return AssetImage("assets/inkman-look-clock.gif");
    } else if (_dateTime.minute == 59 && _dateTime.second > 45 && _dateTime.second < 59){
      // when hour hits sharp he goes out
      // 8680 mls
      return AssetImage("assets/inkman-hour-tick.gif");
    } else if (_dateTime.minute == 0 && _dateTime.second > 0 && _dateTime.second < 18){
      // once the clockoutsideanimation finishes, he will be back
      return AssetImage("assets/props.png");
    } else if (_dateTime.minute == 0 && _dateTime.second < 19 && _dateTime.second < 24) {
      // the man comes back in
      // 3160 mls
      return AssetImage("assets/inkman-come-in.gif");
    }
    // otherwise he just sits and enjoys the newspaper
    return AssetImage("assets/inkman-sit-idle-blink-2.gif");
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
    final fontSize = MediaQuery.of(context).size.width / 40;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'VT323',
      fontSize: fontSize,
    );
    final smallTextStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'VT323',
      fontSize: 20
    );
    final temp = widget.model.temperatureString;
    final weatherCondition = widget.model.weatherString;

    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
            image: new AssetImage("assets/background.jpg")
        )
      ),
      child: Stack(
        children: <Widget>[
          // Clock outside animation when the clock hits hour
          Image(
            image: clockOutsideAnimation(),
          ),
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
          // Gear big top
          Positioned(
            top: -180, left: -180,
            child: Transform.scale(
              scale: 1.2,
                child: Image.asset("assets/cog_large_lighter_350.png")
            )
          ),
          // Gear small top
          Positioned(
            top: 100, left: -100,
            child: Transform.scale(
                scale: 1.2,
              child: Transform.rotate(
                angle: double.parse(second) * -300,
                child: Image.asset("assets/cog_small_lighter_200.png")
              )
            ),
          ),
          // Pendilum
          Positioned(
            top: -270, right: -474,
            child: Transform.scale(
              scale: 0.5,
              child: Image.asset("assets/pendilum.gif"),
            ),
          ),
          Image(
            image: AssetImage("assets/overlay_shadow.png"),
          ),
          // Gears center
          Positioned(
              top: 430, left: 200,
              child: Container(
                height: 130, width: 650,
                child: Stack(
                  children: <Widget>[
                    // Gear 1st
                    Positioned(
                        top: 60, left: 0,
                        child: Transform.scale(
                          scale: 1,
                          child: AnimatedBuilder(
                            animation: animationController,
                            builder: (context, child) => Transform.rotate(
                              angle: animation.value,
                              child: Image.asset("assets/cog_small_200.png")
                            ),
                          )
                        )
                    ),
                    // Gear 2nd
                    Positioned(
                        top: -35,
                        left: 100,
                        child: Transform.scale(
                          scale: 0.7,
                          child: AnimatedBuilder(
                            animation: animationController,
                            builder: (context, child) => Transform.rotate(
                                angle: animation.value / 4,
                                child: Image.asset("assets/cog_large_350.png")
                            ),
                          )
                        )
                    ),
                    // Gear 3rd
                    Positioned(
                        top: 35, left: 335,
                        child: Transform.scale(
                          scale: 0.85,
                          child: AnimatedBuilder(
                            animation: animationController,
                            builder: (context, child) => Transform.rotate(
                                angle: animation.value / 2,
                                child: Image.asset("assets/cog_small_200.png")
                            ),
                          )
                        )
                    ),
                    // Gear 4th
                    Positioned(
                        top: 25, left: 460,
                        child: Transform.scale(
                          scale: 0.5,
                          child: AnimatedBuilder(
                            animation: animationController,
                            builder: (context, child) => Transform.rotate(
                                angle: animation.value / 0.5,
                                child: Image.asset("assets/cog_small_200.png")
                            ),
                          )
                        )
                    ),
                  ],
                ),
              )
          ),
          Image(
            image: AssetImage("assets/props.png"),
          ),
          Image(
            image: insideAnimation(),
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
                      DefaultTextStyle(
                        style: smallTextStyle,
                        child: Text(
                          '$temp',
                        ),
                      ),
                      DefaultTextStyle(
                        style: smallTextStyle,
                        child: Text(
                          '$weatherCondition',
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
                    '$hour:$minute:$second',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

