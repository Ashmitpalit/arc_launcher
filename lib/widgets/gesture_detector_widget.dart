import 'package:flutter/material.dart';
import '../services/gesture_service.dart';

/// Widget that wraps launcher screens and provides gesture detection
class GestureDetectorWidget extends StatefulWidget {
  final Widget child;
  final GestureService gestureService;
  final bool enableGestures;
  final VoidCallback? onLeftSwipe;
  final VoidCallback? onRightSwipe;
  final VoidCallback? onUpSwipe;
  final VoidCallback? onDownSwipe;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const GestureDetectorWidget({
    super.key,
    required this.child,
    required this.gestureService,
    this.enableGestures = true,
    this.onLeftSwipe,
    this.onRightSwipe,
    this.onUpSwipe,
    this.onDownSwipe,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  State<GestureDetectorWidget> createState() => _GestureDetectorWidgetState();
}

class _GestureDetectorWidgetState extends State<GestureDetectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _swipeAnimationController;
  late AnimationController _feedbackAnimationController;
  late Animation<double> _swipeAnimation;
  late Animation<double> _feedbackAnimation;
  
  // Visual feedback state
  bool _showSwipeFeedback = false;
  String _currentGestureDirection = 'none';
  double _gestureProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Setup animations
    _swipeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _feedbackAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _feedbackAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Register gesture callbacks
    _registerGestureCallbacks();
    
    // Listen to gesture service changes
    widget.gestureService.addListener(_onGestureServiceChanged);
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    _feedbackAnimationController.dispose();
    widget.gestureService.removeListener(_onGestureServiceChanged);
    super.dispose();
  }

  void _registerGestureCallbacks() {
    // Register with gesture service
    widget.gestureService.onLeftSwipe(() {
      _handleLeftSwipe();
      widget.onLeftSwipe?.call();
    });
    
    widget.gestureService.onRightSwipe(() {
      _handleRightSwipe();
      widget.onRightSwipe?.call();
    });
    
    widget.gestureService.onUpSwipe(() {
      _handleUpSwipe();
      widget.onUpSwipe?.call();
    });
    
    widget.gestureService.onDownSwipe(() {
      _handleDownSwipe();
      widget.onDownSwipe?.call();
    });
    
    widget.gestureService.onTap(() {
      widget.onTap?.call();
    });
    
    widget.gestureService.onDoubleTap(() {
      widget.onDoubleTap?.call();
    });
    
    widget.gestureService.onLongPress(() {
      widget.onLongPress?.call();
    });
  }

  void _onGestureServiceChanged() {
    if (mounted) {
      setState(() {
        _showSwipeFeedback = widget.gestureService.isGestureActive;
        _currentGestureDirection = widget.gestureService.getGestureDirection();
        _gestureProgress = widget.gestureService.getGestureProgress();
      });
      
      // Animate feedback
      if (_showSwipeFeedback) {
        _feedbackAnimationController.forward();
      } else {
        _feedbackAnimationController.reverse();
      }
    }
  }

  void _handleLeftSwipe() {
    _swipeAnimationController.forward().then((_) {
      _swipeAnimationController.reverse();
    });
  }

  void _handleRightSwipe() {
    _swipeAnimationController.forward().then((_) {
      _swipeAnimationController.reverse();
    });
  }

  void _handleUpSwipe() {
    _swipeAnimationController.forward().then((_) {
      _swipeAnimationController.reverse();
    });
  }

  void _handleDownSwipe() {
    _swipeAnimationController.forward().then((_) {
      _swipeAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with gesture detection
        GestureDetector(
          onPanStart: widget.enableGestures 
              ? widget.gestureService.handlePanStart 
              : null,
          onPanUpdate: widget.enableGestures 
              ? widget.gestureService.handlePanUpdate 
              : null,
          onPanEnd: widget.enableGestures 
              ? widget.gestureService.handlePanEnd 
              : null,
          onTap: widget.enableGestures 
              ? widget.gestureService.handleTap 
              : null,
          onLongPress: widget.enableGestures 
              ? widget.gestureService.handleLongPress 
              : null,
          child: widget.child,
        ),
        
        // Gesture feedback overlay
        if (_showSwipeFeedback)
          _buildGestureFeedback(),
      ],
    );
  }

  Widget _buildGestureFeedback() {
    return AnimatedBuilder(
      animation: _feedbackAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Opacity(
            opacity: _feedbackAnimation.value * 0.3,
            child: Container(
              decoration: BoxDecoration(
                gradient: _getGestureGradient(),
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getGestureGradient() {
    switch (_currentGestureDirection) {
      case 'left':
        return const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Colors.blue, Colors.transparent],
        );
      case 'right':
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.green, Colors.transparent],
        );
      case 'up':
        return const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.orange, Colors.transparent],
        );
      case 'down':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple, Colors.transparent],
        );
      default:
        return const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        );
    }
  }
}
