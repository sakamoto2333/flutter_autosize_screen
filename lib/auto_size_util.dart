import 'dart:ui';

import 'package:flutter/material.dart';
// import 'binding.dart';

export 'binding.dart';

class AutoSizeUtil {
  static double _devicePixelRatio = 3.0;

  static double _screenWidth = 300;

  static double _screenHeight = 800;

  static double _screenStandard = 360;

  static Size _screenSize = Size.zero;

  static bool _autoTextSize = true;

  /// 如果是横屏 就以高度为基准
  /// 如果是竖屏 就以宽度为基准
  /// 是否随着系统的文字大小而改变，默认是改变
  static void setStandard(double standard, {bool isAutoTextSize = true}) {
    _screenStandard = standard;
    _autoTextSize = isAutoTextSize;
  }

  /// 根据设置 的 宽度 来得到 devicePixelRatio
  static double getDevicePixelRatio() {
    // Android 在个别情况(可能是Android 12的启动遮罩层)下启动时会返回空Size
    if (window.physicalSize.isEmpty) return _devicePixelRatio;
    final originalSize = window.physicalSize / window.devicePixelRatio;
    final originalWidth = originalSize.width;
    final originalHeight = originalSize.height;
    if (originalHeight > originalWidth) {
      // 竖屏
      _devicePixelRatio =
          window.physicalSize.width / AutoSizeUtil._screenStandard;
    } else {
      // 横屏
      _devicePixelRatio =
          window.physicalSize.height / AutoSizeUtil._screenStandard;
    }
    return _devicePixelRatio;
  }

  /// 根据设置的宽度，来得到对应的高度
  static Size getSize() {
    // 如果是横屏就已宽度为基准

    final originalSize = window.physicalSize / window.devicePixelRatio;
    final originalWidth = originalSize.width;
    final originalHeight = originalSize.height;
    if (originalHeight > originalWidth) {
      // 竖屏
      _screenHeight = window.physicalSize.height / getDevicePixelRatio();
      _screenWidth = _screenStandard;
      _screenSize = Size(_screenStandard, _screenHeight);
      return _screenSize;
    } else {
      // 横屏
      _screenWidth = window.physicalSize.width / getDevicePixelRatio();
      _screenHeight = _screenStandard;
      _screenSize = Size(_screenWidth, _screenStandard);
      return _screenSize;
    }
  }

  static Size getScreenSize() => _screenSize;

  static Widget appBuilder(BuildContext context, Widget? widget) {
    // final viewInsets = MediaQuery.of(context).viewInsets;
    // final pading = MediaQuery.of(context).padding;
    // final viewPadding = MediaQuery.of(context).viewPadding;
    // final adapterEdge = EdgeInsets.fromLTRB(
    //   viewInsets.left,
    //   viewInsets.top,
    //   viewInsets.right,
    //   getRealSize(viewInsets.bottom),
    // );
    // final adapterPadding = EdgeInsets.fromLTRB(
    //   pading.left,
    //   getRealSize(pading.top),
    //   pading.right,
    //   getRealSize(pading.bottom),
    // );
    // final adapterViewPadding = EdgeInsets.fromLTRB(
    //   viewPadding.left,
    //   getRealSize(viewPadding.top),
    //   viewPadding.right,
    //   getRealSize(viewPadding.bottom),
    // );

    return MediaQuery(
      // 这里如果设置 textScaleFactor = 1.0 ，就不会随着系统字体大小去改变了
      data: MediaQuery.of(context).copyWith(
        size: Size(AutoSizeUtil._screenWidth, AutoSizeUtil._screenHeight),
        devicePixelRatio: AutoSizeUtil._devicePixelRatio,
        textScaleFactor:
            _autoTextSize ? MediaQuery.of(context).textScaleFactor : 1.0,
        // viewInsets: adapterEdge,
        // padding: adapterPadding,
        // viewPadding: adapterViewPadding,
      ),
      child: _adapterTheme(context, widget),
    );
  }

  /// 获取真正的大小，比如 kToolbarHeight kBottomNavigationBarHeight
  static double getRealSize(double size) {
    return size / (_devicePixelRatio / window.devicePixelRatio);
  }

  static Theme _adapterTheme(BuildContext context, Widget? widget) {
    return Theme(
      data: Theme.of(context).copyWith(),
      child: widget!,
    );
  }
}
