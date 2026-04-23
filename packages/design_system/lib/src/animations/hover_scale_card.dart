import 'package:flutter/material.dart';

/// Wraps its [child] in a subtle scale + elevation effect
/// triggered on hover (desktop/web) or tap-down (mobile).
///
/// Perfect for cards and interactive tiles to give a
/// responsive, premium feel.
class HoverScaleCard extends StatefulWidget {
  const HoverScaleCard({
    super.key,
    required this.child,
    this.scaleOnHover = 1.03,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
    this.borderRadius = 20.0,
  });

  /// The widget to wrap.
  final Widget child;

  /// Scale factor when hovered.
  final double scaleOnHover;

  /// Animation duration.
  final Duration duration;

  /// Animation curve.
  final Curve curve;

  /// Border radius for the shadow clip.
  final double borderRadius;

  @override
  State<HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<HoverScaleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _elevation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scale = Tween<double>(
      begin: 1.0,
      end: widget.scaleOnHover,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _elevation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() => _controller.forward();

  void _onExit() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      cursor: SystemMouseCursors.click,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.04 + (_elevation.value * 0.008),
                    ),
                    blurRadius: 10 + _elevation.value,
                    offset: Offset(0, 4 + _elevation.value * 0.5),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
