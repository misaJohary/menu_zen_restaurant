import 'package:flutter/material.dart';

/// Animates a numeric value from zero to [end], displaying
/// it with an optional [prefix] and [suffix].
///
/// Ideal for dashboard stat cards where numbers should
/// "count up" when they first appear on screen.
class AnimatedCountUp extends StatefulWidget {
  const AnimatedCountUp({
    super.key,
    required this.end,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.curve = Curves.easeOutCubic,
    this.formatter,
  });

  /// The target number to count up to.
  final double end;

  /// How long the count-up animation takes.
  final Duration duration;

  /// Optional delay before the animation starts.
  final Duration delay;

  /// Text style for the rendered number.
  final TextStyle? style;

  /// Text rendered before the number (e.g. currency symbol).
  final String prefix;

  /// Text rendered after the number (e.g. unit like "k").
  final String suffix;

  /// Animation curve.
  final Curve curve;

  /// Optional custom formatter. If null, integers display
  /// without decimals and doubles show one decimal place.
  final String Function(double value)? formatter;

  @override
  State<AnimatedCountUp> createState() => _AnimatedCountUpState();
}

class _AnimatedCountUpState extends State<AnimatedCountUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _rebuildAnimation(0, widget.end);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  void _rebuildAnimation(double from, double to) {
    _animation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void didUpdateWidget(AnimatedCountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end) {
      _rebuildAnimation(oldWidget.end, widget.end);
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _defaultFormat(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _animation,
      builder: (context, child) {
        final formatted = widget.formatter != null
            ? widget.formatter!(_animation.value)
            : _defaultFormat(_animation.value);
        return Text(
          '${widget.prefix}$formatted${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
