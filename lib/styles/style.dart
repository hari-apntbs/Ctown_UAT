/*
*  style.dart
*  AMCS-additional-pages
*
*  Created by InstaSoft Inc.
*  Copyright © 2018 InstaSoft Inc. All rights reserved.
    */

import 'package:flutter/material.dart';

// Style Background Color
const Color _backgroundColor = Color.fromARGB(255, 255, 255, 255);

// Style Border
const BorderSide _borderSide = BorderSide(
  color: Color.fromARGB(255, 48, 49, 82),
  width: 0.3,
  style: BorderStyle.solid,
);

// Style Corner Radius
const BorderRadiusGeometry _cornerRadius = BorderRadius.all(Radius.circular(7));


class StyleDecoration extends BoxDecoration {
  const StyleDecoration({
    Color color = _backgroundColor,
    Gradient? gradient,
    Border border = const Border.fromBorderSide(_borderSide),
    BorderRadiusGeometry borderRadius = _cornerRadius,
    List<BoxShadow>? boxShadow,
  }) : super(
    color: color,
    border: border,
    borderRadius: borderRadius,
    boxShadow: boxShadow,
    gradient: gradient,
  );

  StyleDecoration.withOverrides({
    Color color = _backgroundColor,
    Gradient? gradient,
    double? borderWidth,
    Color? borderColor,
    BorderRadiusGeometry borderRadius = _cornerRadius,
    Color? shadowColor,
    Offset? shadowOffset,
    double? shadowRadius,
  }) : super(
      color: color,
      borderRadius: borderRadius,
      gradient: gradient,
      border: Border.fromBorderSide(_borderSide.copyWith(width: borderWidth, color: borderColor)),
      boxShadow: [ BoxShadow(color: shadowColor ?? const Color(0x00000000), offset: shadowOffset ?? Offset.zero, blurRadius: shadowRadius ?? 0.0) ]
  );
}


class Style extends StatelessWidget {
  const Style({
    Key? key,
    this.decoration = const StyleDecoration(),
    this.child,
  }) : super(key: key);
  final StyleDecoration decoration;
  final Widget? child;

  @override
  Widget build(BuildContext context) {

    return DecoratedBox(
      decoration: this.decoration,
      child: this.child,
    );
  }
}


class StyleButton extends StatelessWidget {

  const StyleButton({
    Key? key,
    this.color = _backgroundColor,
    this.border = _borderSide,
    this.borderRadius = _cornerRadius,
    this.padding,
    required this.onPressed,
    required this.child,
  }): super(key: key);

  final Color color;
  final BorderSide border;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsets? padding;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {

    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: this.color,
        // shape: RoundedRectangleBorder(
        //   side: this.border,
        //   borderRadius: this.borderRadius,
        // ),
        shape: RoundedRectangleBorder(
            borderRadius:BorderRadius.circular(25.0)),
      ),
      onPressed: this.onPressed,
      child: this.child,
    );
  }
}


class StyleSwitch extends StatelessWidget {
  const StyleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  }): super(key: key);
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {

    return Switch.adaptive(
      value: this.value,
      onChanged: this.onChanged,
      activeColor: this.activeColor,
    );
  }
}


class StyleSlider extends StatelessWidget {
  const StyleSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.inactiveColor = _backgroundColor,
    this.activeColor,
    this.min,
    this.max,
  }): super(key: key);
  final double value;
  final ValueChanged<double> onChanged;
  final Color inactiveColor;
  final Color? activeColor;
  final double? min;
  final double? max;

  @override
  Widget build(BuildContext context) {

    return Slider(
      value: this.value,
      onChanged: this.onChanged,
      activeColor: this.activeColor,
    );
  }
}


class StyleCircularProgressIndicator extends StatelessWidget {
  const StyleCircularProgressIndicator({
    Key? key,
    this.color,
  }): super(key: key);
  final Color? color;

  @override
  Widget build(BuildContext context) {

    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(this.color),
    );
  }
}


class StyleLinearProgressIndicator extends StatelessWidget {
  const StyleLinearProgressIndicator({
    Key? key,
    this.color,
  }): super(key: key);
  final Color? color;

  @override
  Widget build(BuildContext context) {

    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(this.color),
    );
  }
}