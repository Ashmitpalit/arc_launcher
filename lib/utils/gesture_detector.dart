import 'package:flutter/material.dart';

class LauncherGestureDetector extends StatelessWidget {
  final Widget child;
  final Function()? onLeftSwipe;
  final Function()? onRightSwipe;
  final Function()? onTap;
  final Function()? onLongPress;
  final Function()? onDoubleTap;
  final double swipeThreshold;
  final Duration swipeTimeout;

  const LauncherGestureDetector({
    super.key,
    required this.child,
    this.onLeftSwipe,
    this.onRightSwipe,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.swipeThreshold = 50.0,
    this.swipeTimeout = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      onPanEnd: (details) => _handleSwipe(details),
      child: child,
    );
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final distance = details.primaryVelocity ?? 0;

    // Check if it's a horizontal swipe
    if (velocity.dx.abs() > velocity.dy.abs()) {
      if (distance > swipeThreshold && onRightSwipe != null) {
        onRightSwipe!();
      } else if (distance < -swipeThreshold && onLeftSwipe != null) {
        onLeftSwipe!();
      }
    }
  }
}

class SwipeablePage extends StatefulWidget {
  final Widget child;
  final Function()? onLeftSwipe;
  final Function()? onRightSwipe;
  final bool enableSwipe;

  const SwipeablePage({
    super.key,
    required this.child,
    this.onLeftSwipe,
    this.onRightSwipe,
    this.enableSwipe = true,
  });

  @override
  State<SwipeablePage> createState() => _SwipeablePageState();
}

class _SwipeablePageState extends State<SwipeablePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableSwipe) {
      return widget.child;
    }

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: _dragOffset + Offset(_slideAnimation.value.dx, 0),
            child: widget.child,
          );
        },
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = Offset.zero;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragOffset = Offset(details.delta.dx, 0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final distance = _dragOffset.dx;

    // Determine if it's a valid swipe
    if (distance.abs() > 100 || velocity.abs() > 500) {
      if (distance > 0 && widget.onRightSwipe != null) {
        _animateSwipe(distance, true);
        widget.onRightSwipe!();
      } else if (distance < 0 && widget.onLeftSwipe != null) {
        _animateSwipe(distance, false);
        widget.onLeftSwipe!();
      } else {
        _resetPosition();
      }
    } else {
      _resetPosition();
    }

    setState(() {
      _isDragging = false;
    });
  }

  void _animateSwipe(double distance, bool isRight) {
    final targetDistance = isRight ? MediaQuery.of(context).size.width : -MediaQuery.of(context).size.width;
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(distance, 0),
      end: Offset(targetDistance, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _resetPosition() {
    _slideAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward().then((_) {
      setState(() {
        _dragOffset = Offset.zero;
      });
    });
  }
}

class GestureConfig {
  final bool enableLeftSwipe;
  final bool enableRightSwipe;
  final bool enableTap;
  final bool enableLongPress;
  final bool enableDoubleTap;
  final double swipeThreshold;
  final Duration swipeTimeout;
  final Duration animationDuration;

  const GestureConfig({
    this.enableLeftSwipe = true,
    this.enableRightSwipe = true,
    this.enableTap = true,
    this.enableLongPress = true,
    this.enableDoubleTap = true,
    this.swipeThreshold = 50.0,
    this.swipeTimeout = const Duration(milliseconds: 300),
    this.animationDuration = const Duration(milliseconds: 200),
  });

  GestureConfig copyWith({
    bool? enableLeftSwipe,
    bool? enableRightSwipe,
    bool? enableTap,
    bool? enableLongPress,
    bool? enableDoubleTap,
    double? swipeThreshold,
    Duration? swipeTimeout,
    Duration? animationDuration,
  }) {
    return GestureConfig(
      enableLeftSwipe: enableLeftSwipe ?? this.enableLeftSwipe,
      enableRightSwipe: enableRightSwipe ?? this.enableRightSwipe,
      enableTap: enableTap ?? this.enableTap,
      enableLongPress: enableLongPress ?? this.enableLongPress,
      enableDoubleTap: enableDoubleTap ?? this.enableDoubleTap,
      swipeThreshold: swipeThreshold ?? this.swipeThreshold,
      swipeTimeout: swipeTimeout ?? this.swipeTimeout,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

class GestureManager {
  static final GestureManager _instance = GestureManager._internal();
  factory GestureManager() => _instance;
  GestureManager._internal();

  GestureConfig _config = const GestureConfig();
  final Map<String, Function()> _gestureCallbacks = {};

  GestureConfig get config => _config;

  void updateConfig(GestureConfig newConfig) {
    _config = newConfig;
  }

  void registerCallback(String gesture, Function() callback) {
    _gestureCallbacks[gesture] = callback;
  }

  void unregisterCallback(String gesture) {
    _gestureCallbacks.remove(gesture);
  }

  void executeCallback(String gesture) {
    _gestureCallbacks[gesture]?.call();
  }

  void clearAllCallbacks() {
    _gestureCallbacks.clear();
  }
}
