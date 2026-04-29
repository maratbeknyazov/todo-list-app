import 'package:flutter/material.dart';

class TopAnimationShowWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double distanceY;

  const TopAnimationShowWidget({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.distanceY = 0,
  });

  @override
  _TopAnimationShowWidgetState createState() => _TopAnimationShowWidgetState();
}

class _TopAnimationShowWidgetState extends State<TopAnimationShowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: widget.duration);
    _animation = new Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    debugPrint("top_show уничтожен");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: _animation,
      child: Container(child: widget.child),
      builder: (ctx, child) {
        return Transform.translate(
          offset: Offset(0, (_animation.value - 1) * (widget.distanceY)),
          child: child,
        );
      },
    );
  }
}
