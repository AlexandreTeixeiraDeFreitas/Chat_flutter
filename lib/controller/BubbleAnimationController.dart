import 'dart:async';

import 'package:flutter/material.dart';

class BubbleAnimationController extends StatefulWidget {
  final int delay;
  final Widget child;
  final bool play;

  BubbleAnimationController({required this.delay, required this.child, this.play = false, Key? key}) : super(key: key);

  @override
  _BubbleAnimationControllerState createState() => _BubbleAnimationControllerState();
}

class _BubbleAnimationControllerState extends State<BubbleAnimationController> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    );

    if (widget.play) {
      Timer(Duration(seconds: widget.delay), () {
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: play,
      child: FadeTransition(
        opacity: _controller,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
