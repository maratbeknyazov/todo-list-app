import 'package:flutter/material.dart';

class CustomAnimatedIcon extends StatefulWidget {
  final Color color;
  final double size;
  final AnimatedIconData firstIcon;
  final AnimatedIconData secondIcon;
  final Duration duration;
  final VoidCallback onTap;
  final bool hasTapped;

  const CustomAnimatedIcon({
    super.key,
    required this.color,
    required this.size,
    required this.firstIcon,
    required this.secondIcon,
    this.duration = const Duration(milliseconds: 300),
    required this.onTap,
    this.hasTapped = false,
  });

  @override
  _CustomAnimatedIconState createState() => _CustomAnimatedIconState();
}

class _CustomAnimatedIconState extends State<CustomAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool hasTapped = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    hasTapped = widget.hasTapped;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: AnimatedIcon(
        icon: hasTapped ? widget.secondIcon : widget.firstIcon,
        progress: _animation,
        color: widget.color,
        size: widget.size,
      ),
      onTap: () {
        widget.onTap();
        if (mounted) {
          setState(() {
            hasTapped = !hasTapped;
          });
        }
      },
    );
  }
}
