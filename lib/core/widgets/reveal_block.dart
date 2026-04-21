import 'package:flutter/material.dart';

class RevealBlock extends StatelessWidget {
  const RevealBlock({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 360),
    this.offset = const Offset(0, 18),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final delayedValue = delay == Duration.zero
            ? value
            : ((value * (duration + delay).inMilliseconds - delay.inMilliseconds) /
                      duration.inMilliseconds)
                  .clamp(0.0, 1.0);

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(
              offset.dx * (1 - delayedValue),
              offset.dy * (1 - delayedValue),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
