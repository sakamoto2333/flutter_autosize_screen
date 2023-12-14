import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'auto_size_util.dart';

void runAutoApp(Widget app) {
  final binding = AutoWidgetsFlutterBinding.ensureInitialized();
  binding
    // ignore: invalid_use_of_protected_member
    ..scheduleAttachRootWidget(binding.wrapWithDefaultView(app))
    ..scheduleWarmUpFrame();
}

class AutoWidgetsFlutterBinding extends WidgetsFlutterBinding {
  static WidgetsBinding ensureInitialized() {
    _instance ??= AutoWidgetsFlutterBinding();
    return WidgetsBinding.instance;
  }

  static WidgetsBinding? _instance;

  @override
  ViewConfiguration createViewConfigurationFor(RenderView renderView) {
    return ViewConfiguration(
      size: AutoSizeUtil.getSize(),
      devicePixelRatio: AutoSizeUtil.getDevicePixelRatio(),
    );
  }

  /// 因为修改了 devicePixelRatio ，得适配点击事件  GestureBinding
  @override
  void initInstances() {
    super.initInstances();
    platformDispatcher.onPointerDataPacket = _handlePointerDataPacket;
  }

  @override
  void unlocked() {
    super.unlocked();
    _flushPointerEventQueue();
  }

  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();

  void _handlePointerDataPacket(PointerDataPacket packet) {
    _pendingPointerEvents.addAll(PointerEventConverter.expand(
      packet.data,
      // 适配事件的转换比率,采用我们修改的
      AutoSizeUtil.getDevicePixelRatio,
    ));
    if (!locked) _flushPointerEventQueue();
  }

  @override
  void cancelPointer(int pointer) {
    if (_pendingPointerEvents.isEmpty && !locked) {
      scheduleMicrotask(_flushPointerEventQueue);
    }
    _pendingPointerEvents.addFirst(PointerCancelEvent(pointer: pointer));
  }

  void _flushPointerEventQueue() {
    assert(!locked);
    while (_pendingPointerEvents.isNotEmpty) {
      _handlePointerEvent(_pendingPointerEvents.removeFirst());
    }
  }

  final Map<int, HitTestResult> _hitTests = <int, HitTestResult>{};

  void _handlePointerEvent(PointerEvent event) {
    assert(!locked);
    HitTestResult? hitTestResult;
    if (event is PointerDownEvent ||
        event is PointerSignalEvent ||
        event is PointerHoverEvent ||
        event is PointerPanZoomStartEvent) {
      assert(!_hitTests.containsKey(event.pointer));
      hitTestResult = HitTestResult();
      hitTestInView(hitTestResult, event.position, event.viewId);
      if (event is PointerDownEvent || event is PointerPanZoomStartEvent) {
        _hitTests[event.pointer] = hitTestResult;
      }
      assert(() {
        if (debugPrintHitTestResults) {
          debugPrint('$event: $hitTestResult');
        }
        return true;
      }());
    } else if (event is PointerUpEvent ||
        event is PointerCancelEvent ||
        event is PointerPanZoomEndEvent) {
      hitTestResult = _hitTests.remove(event.pointer);
    } else if (event.down || event is PointerPanZoomUpdateEvent) {
      // Because events that occur with the pointer down (like
      // [PointerMoveEvent]s) should be dispatched to the same place that their
      // initial PointerDownEvent was, we want to re-use the path we found when
      // the pointer went down, rather than do hit detection each time we get
      // such an event.
      hitTestResult = _hitTests[event.pointer];
    }
    assert(() {
      if (debugPrintMouseHoverEvents && event is PointerHoverEvent) {
        debugPrint('$event');
      }
      return true;
    }());
    if (hitTestResult != null ||
        event is PointerAddedEvent ||
        event is PointerRemovedEvent) {
      dispatchEvent(event, hitTestResult);
    }
  }
}
