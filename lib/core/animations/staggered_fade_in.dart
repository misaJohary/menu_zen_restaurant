import 'package:flutter/material.dart';

/// A widget that animates its child with a staggered
/// slide-up + fade-in effect.
///
/// Useful in grids and lists where items should appear
/// one after another with a cascading delay.
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delayPerItem = const Duration(milliseconds: 60),
    this.slideOffset = 30.0,
  });

  /// Index of the item in the list/grid, used to compute
  /// the stagger delay.
  final int index;

  /// The widget to animate into view.
  final Widget child;

  /// Duration of the individual item's animation.
  final Duration duration;

  /// Additional delay per item index to create the stagger.
  final Duration delayPerItem;

  /// How far the item slides up from (in logical pixels).
  final double slideOffset;

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset / 100),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    final delay = widget.delayPerItem * widget.index;
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
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
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

