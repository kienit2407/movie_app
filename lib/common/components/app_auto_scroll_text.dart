import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class AppAutoScrollText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Duration delayBefore;
  final Duration pauseOnBounce;
  final Velocity velocity;
  final bool fadedBorder;
  final double fadedBorderWidth;

  const AppAutoScrollText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.delayBefore = const Duration(milliseconds: 700),
    this.pauseOnBounce = const Duration(milliseconds: 900),
    this.velocity = const Velocity(pixelsPerSecond: Offset(35, 0)),
    this.fadedBorder = true,
    this.fadedBorderWidth = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.clip,
            textAlign: textAlign,
            style: effectiveStyle,
          );
        }

        final painter = TextPainter(
          text: TextSpan(text: text, style: effectiveStyle),
          maxLines: 1,
          textDirection: textDirection,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);

        if (!painter.didExceedMaxLines) {
          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.clip,
            textAlign: textAlign,
            style: effectiveStyle,
          );
        }

        return ClipRect(
          child: TextScroll(
            text,
            mode: TextScrollMode.bouncing,
            delayBefore: delayBefore,
            pauseOnBounce: pauseOnBounce,
            velocity: velocity,
            fadedBorder: fadedBorder,
            fadedBorderWidth: fadedBorderWidth,
            textAlign: textAlign,
            textDirection: textDirection,
            style: effectiveStyle,
          ),
        );
      },
    );
  }
}
