import 'package:flutter/material.dart';

/// Animates a widget into view with a combined fade and
/// slide effect. Configurable direction and timing.
///
/// Great for sections of a page that should appear in
/// sequence (header, then stats, then content).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.direction = AxisDirection.up,
    this.offset = 0.15,
  });

  /// The widget to animate.
  final Widget child;

  /// Duration of the animation.
  final Duration duration;

  /// Delay before starting.
  final Duration delay;

  /// Animation curve.
  final Curve curve;

  /// Direction to slide from.
  final AxisDirection direction;

  /// How far to slide (as a fraction of the widget size).
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    final begin = switch (widget.direction) {
      AxisDirection.up => Offset(0, widget.offset),
      AxisDirection.down => Offset(0, -widget.offset),
      AxisDirection.left => Offset(widget.offset, 0),
      AxisDirection.right => Offset(-widget.offset, 0),
    };

    _position = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _position,
        child: widget.child,
      ),
    );
  }
}
