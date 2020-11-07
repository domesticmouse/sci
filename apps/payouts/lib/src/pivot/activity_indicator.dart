import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const Duration _duration = Duration(milliseconds: 1200);
const double _defaultSize = 128;
const int _spokes = 12;

class ActivityIndicator extends StatefulWidget {
  const ActivityIndicator({
    Key? key,
    this.color = const Color(0xff000000),
    this.animating = true,
    this.semanticLabel = 'Loading',
  })  : super(key: key);

  final Color color;
  final bool animating;
  final String semanticLabel;

  @override
  _ActivityIndicatorState createState() => _ActivityIndicatorState();
}

class _ActivityIndicatorState extends State<ActivityIndicator>
    with SingleTickerProviderStateMixin<ActivityIndicator> {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _duration,
      vsync: this,
    );
    if (widget.animating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ActivityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animating != oldWidget.animating) {
      if (widget.animating) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      child: CustomPaint(
        size: Size.square(_defaultSize),
        painter: ActivityIndicatorPainter(
          baseColor: widget.color,
          animation: _controller,
        ),
      ),
    );
  }
}

class ActivityIndicatorPainter extends CustomPainter {
  ActivityIndicatorPainter({
    required this.baseColor,
    required this.animation,
  })  : colors = _splitColor(baseColor),
        super(repaint: animation);

  final Color baseColor;
  final List<Color> colors;
  final Animation<double> animation;

  static List<Color> _splitColor(Color color) {
    return List<Color>.generate(_spokes, (int index) {
      final int alpha = (255 * index / _spokes).floor();
      return color.withAlpha(alpha);
    });
  }

  static final Tween<double> _rotationTween = _StepTween(
    begin: 0,
    end: 2 * math.pi,
    step: 2 * math.pi / _spokes,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width > size.height) {
      canvas.translate((size.width - size.height) / 2, 0);
      final double scale = size.height / _defaultSize;
      canvas.scale(scale);
    } else if (size.width != _defaultSize || size.height != _defaultSize) {
      canvas.translate(0, (size.height - size.width) / 2);
      final double scale = size.width / _defaultSize;
      canvas.scale(scale);
    }

    final double rotationValue = _rotationTween.evaluate(animation);
    canvas.translate(_defaultSize / 2, _defaultSize / 2);
    canvas.rotate(rotationValue);

    final double increment = 2 * math.pi / _spokes;
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < _spokes; i++) {
      paint.color = colors[i];
      canvas.drawRRect(RRect.fromLTRBR(24, -4, 56, 4, Radius.circular(4)), paint);
      canvas.rotate(increment);
    }
  }

  @override
  bool shouldRepaint(ActivityIndicatorPainter oldPainter) {
    return oldPainter.baseColor != baseColor || oldPainter.animation.value != animation.value;
  }
}

class _StepTween extends Tween<double> {
  _StepTween({
    required double begin,
    required double end,
    required this.step,
  }) : super(begin: begin, end: end);

  final double step;

  @override
  @protected
  double lerp(double t) {
    double value = super.lerp(t);
    int steps = (value / step).floor();
    return steps * step;
  }
}
