// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
import 'package:flutter/material.dart';


enum DisplayType {
  desktop,
  tablet,
  mobile,
}

const _desktopBreakpointWstH = 1024.0; // Width is smaller than Height
const _desktopBreakpointWgtH = 700.0; // Width is greater than Height

/// Returns the [DisplayType] for the current screen. This app only supports
/// mobile and desktop layouts, and as such we only have one breakpoint.
DisplayType displayTypeOf(BuildContext context) {
  if ((MediaQuery.of(context).size.width < MediaQuery.of(context).size.height &&
      MediaQuery.of(context).size.width <= _desktopBreakpointWstH) ||
      (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height &&
          MediaQuery.of(context).size.width <= _desktopBreakpointWgtH)) {
    return DisplayType.mobile;
  } else {
    return DisplayType.mobile;
    /* return DisplayType.desktop;*/
  }
}

/// Returns a boolean if we are in a display of [DisplayType.desktop]. Used to
/// build adaptive and responsive layouts.
// bool isDisplayDesktop(BuildContext context) {
//   if (Config().isBuilder) return false;
//   return displayTypeOf(context) == DisplayType.desktop;
// }
/*
bool isBigScreen(BuildContext context) {
  if (Config().isBuilder) return true;
  return MediaQuery.of(context).size.width >= 768;
}
*/
/// Returns a boolean value whether the window is considered medium or large size.
/// Used to build adaptive and responsive layouts.
bool isDisplayDesktop(BuildContext context) {
  /* if (Config().isBuilder) return false;
  return getWindowType(context) >= AdaptiveWindowType.medium;
  */
  return false;
}

/// Returns boolean value whether the window is considered medium size.
/// Used to build adaptive and responsive layouts.
bool isDisplaySmallDesktop(BuildContext context) {
  return false;
  /*return getWindowType(context) == AdaptiveWindowType.medium;*/
}
