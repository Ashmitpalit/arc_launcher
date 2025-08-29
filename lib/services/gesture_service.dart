import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Service responsible for handling all gesture interactions in the launcher
class GestureService extends ChangeNotifier {
  // Gesture configuration
  static const double _swipeThreshold = 100.0; // Minimum distance for swipe
  static const double _swipeVelocityThreshold = 300.0; // Minimum velocity for swipe
  static const Duration _longPressDuration = Duration(milliseconds: 500);
  static const Duration _doubleTapDuration = Duration(milliseconds: 300);
  
  // Gesture state
  bool _isGestureActive = false;
  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;
  DateTime _lastTapTime = DateTime.now();
  DateTime _longPressStartTime = DateTime.now();
  
  // Callbacks for different gestures
  VoidCallback? _onLeftSwipe;
  VoidCallback? _onRightSwipe;
  VoidCallback? _onUpSwipe;
  VoidCallback? _onDownSwipe;
  VoidCallback? _onTap;
  VoidCallback? _onDoubleTap;
  VoidCallback? _onLongPress;
  VoidCallback? _onPinchIn;
  VoidCallback? _onPinchOut;
  
  // Getters
  bool get isGestureActive => _isGestureActive;
  Offset get startPosition => _startPosition;
  Offset get currentPosition => _currentPosition;
  
  /// Register callback for left swipe gesture
  void onLeftSwipe(VoidCallback callback) {
    _onLeftSwipe = callback;
  }
  
  /// Register callback for right swipe gesture
  void onRightSwipe(VoidCallback callback) {
    _onRightSwipe = callback;
  }
  
  /// Register callback for up swipe gesture
  void onUpSwipe(VoidCallback callback) {
    _onUpSwipe = callback;
  }
  
  /// Register callback for down swipe gesture
  void onDownSwipe(VoidCallback callback) {
    _onDownSwipe = callback;
  }
  
  /// Register callback for tap gesture
  void onTap(VoidCallback callback) {
    _onTap = callback;
  }
  
  /// Register callback for double tap gesture
  void onDoubleTap(VoidCallback callback) {
    _onDoubleTap = callback;
  }
  
  /// Register callback for long press gesture
  void onLongPress(VoidCallback callback) {
    _onLongPress = callback;
  }
  
  /// Register callback for pinch in gesture
  void onPinchIn(VoidCallback callback) {
    _onPinchIn = callback;
  }
  
  /// Register callback for pinch out gesture
  void onPinchOut(VoidCallback callback) {
    _onPinchOut = callback;
  }
  
  /// Handle pan start gesture
  void handlePanStart(DragStartDetails details) {
    _isGestureActive = true;
    _startPosition = details.globalPosition;
    _currentPosition = details.globalPosition;
    _longPressStartTime = DateTime.now();
    
    // Start long press timer
    _startLongPressTimer();
    
    notifyListeners();
  }
  
  /// Handle pan update gesture
  void handlePanUpdate(DragUpdateDetails details) {
    if (!_isGestureActive) return;
    
    _currentPosition = details.globalPosition;
    notifyListeners();
  }
  
  /// Handle pan end gesture
  void handlePanEnd(DragEndDetails details) {
    if (!_isGestureActive) return;
    
    _isGestureActive = false;
    
    // Calculate swipe distance and velocity
    final distance = (_currentPosition - _startPosition).distance;
    final velocity = details.velocity.pixelsPerSecond.distance;
    
    // Determine if this is a valid swipe
    if (distance >= _swipeThreshold || velocity >= _swipeVelocityThreshold) {
      _handleSwipeGesture();
    }
    
    notifyListeners();
  }
  
  /// Handle tap gesture
  void handleTap() {
    final now = DateTime.now();
    final timeSinceLastTap = now.difference(_lastTapTime);
    
    if (timeSinceLastTap <= _doubleTapDuration) {
      // Double tap detected
      _onDoubleTap?.call();
      HapticFeedback.mediumImpact();
    } else {
      // Single tap
      _onTap?.call();
      HapticFeedback.lightImpact();
    }
    
    _lastTapTime = now;
  }
  
  /// Handle long press gesture
  void handleLongPress() {
    _onLongPress?.call();
    HapticFeedback.heavyImpact();
  }
  
  /// Start long press timer
  void _startLongPressTimer() {
    Future.delayed(_longPressDuration, () {
      if (_isGestureActive && _onLongPress != null) {
        handleLongPress();
      }
    });
  }
  
  /// Handle swipe gesture based on direction
  void _handleSwipeGesture() {
    final delta = _currentPosition - _startPosition;
    final horizontalDistance = delta.dx.abs();
    final verticalDistance = delta.dy.abs();
    
    // Determine primary direction
    if (horizontalDistance > verticalDistance) {
      // Horizontal swipe
      if (delta.dx > 0) {
        // Right swipe
        _onRightSwipe?.call();
        HapticFeedback.mediumImpact();
      } else {
        // Left swipe
        _onLeftSwipe?.call();
        HapticFeedback.mediumImpact();
      }
    } else {
      // Vertical swipe
      if (delta.dy > 0) {
        // Down swipe
        _onDownSwipe?.call();
        HapticFeedback.mediumImpact();
      } else {
        // Up swipe
        _onUpSwipe?.call();
        HapticFeedback.mediumImpact();
      }
    }
  }
  
  /// Calculate gesture progress (0.0 to 1.0)
  double getGestureProgress() {
    if (!_isGestureActive) return 0.0;
    
    final delta = _currentPosition - _startPosition;
    final distance = delta.distance;
    
    return math.min(distance / _swipeThreshold, 1.0);
  }
  
  /// Get gesture direction as a string
  String getGestureDirection() {
    if (!_isGestureActive) return 'none';
    
    final delta = _currentPosition - _startPosition;
    final horizontalDistance = delta.dx.abs();
    final verticalDistance = delta.dy.abs();
    
    if (horizontalDistance > verticalDistance) {
      return delta.dx > 0 ? 'right' : 'left';
    } else {
      return delta.dy > 0 ? 'down' : 'up';
    }
  }
  
  /// Reset gesture state
  void reset() {
    _isGestureActive = false;
    _startPosition = Offset.zero;
    _currentPosition = Offset.zero;
    notifyListeners();
  }
  
  /// Dispose the service
  @override
  void dispose() {
    super.dispose();
  }
}
