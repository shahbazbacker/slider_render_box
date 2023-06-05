import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            color: Colors.yellow,
            width: 300,
            child: CustomProgressBar(
              dotColor: Colors.blue,
              thumbColor: Colors.grey,
              thumbSize: 24,
              key: GlobalKey(),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomProgressBar extends LeafRenderObjectWidget {
  const CustomProgressBar(
      {required Key key,
      required this.dotColor,
      required this.thumbColor,
      required this.thumbSize})
      : super(key: key);
  final Color dotColor;
  final Color thumbColor;
  final double thumbSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    // TODO: implement createRenderObject
    return RenderProgressBar(
        dotColor: dotColor, thumbColor: thumbColor, thumbSize: thumbSize);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderProgressBar renderObject) {
    renderObject
      ..dotColor = dotColor
      ..thumbColor = thumbColor
      ..thumbSize = thumbSize;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(ColorProperty('dotColor', dotColor));
    properties.add(ColorProperty('thumbColor', thumbColor));
    properties.add(DoubleProperty('thumbSize', thumbSize));
    super.debugFillProperties(properties);
  }
}

class RenderProgressBar extends RenderBox {
  RenderProgressBar(
      {required Color dotColor,
      required Color thumbColor,
      required double thumbSize})
      : _dotColor = dotColor,
        _thumbColor = thumbColor,
        _thumbSize = thumbSize {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = (DragStartDetails details) {
        _updateThumbPosition(details.localPosition);
      }
      ..onUpdate = (DragUpdateDetails details) {
        _updateThumbPosition(details.localPosition);
      };
  }

  double _currentThumbValue = 0.5;

  Color _dotColor;
  Color get dotColor => _dotColor;

  set dotColor(Color value) {
    if (_dotColor == value) {
      return;
    }
    _dotColor = value;
    markNeedsPaint();
  }

  Color _thumbColor;
  Color get thumbColor => _thumbColor;

  set thumbColor(Color value) {
    if (_thumbColor == value) {
      return;
    }
    _thumbColor = value;
    markNeedsPaint();
  }

  double _thumbSize;
  double get thumbSize => _thumbSize;

  set thumbSize(double value) {
    if (_thumbSize == value) {
      return;
    }
    _thumbSize = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final desiredWidth = constraints.maxWidth;
    final desiredHeight = thumbSize;
    final desiredSize = Size(desiredWidth, desiredHeight);
    size = constraints.constrain(desiredSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    //Paint dots
    final dotPaint = Paint()
      ..color = dotColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    final barPaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    final barRemainingPaint = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    final spacing = size.width / 10;
    for (int i = 0; i < 11; i++) {
      var upperPoint = Offset(spacing * i, size.height * 0.75);
      var lowerPoint = Offset(spacing * i, size.height);
      if (i % 5 == 0) {
        upperPoint = Offset(spacing * i, size.height * 0.25);
      }
      if (upperPoint.dx <= _currentThumbValue * size.width) {
        canvas.drawLine(upperPoint, lowerPoint, barPaint);
      } else {
        canvas.drawLine(upperPoint, lowerPoint, barRemainingPaint);
      }
    }

    final thumbPaint = Paint()..color = thumbColor;
    final thumbDx = _currentThumbValue * size.width;

    //Draw the line from left to thumb position
    final pointOne = Offset(0, size.height / 2);
    final pointTwo = Offset(thumbDx, size.height / 2);
    canvas.drawLine(pointOne, pointTwo, barPaint);

    //Draw the line from   thumb to right position
    final pointThree = Offset(thumbDx, size.height / 2);
    final pointFour = Offset(size.width, size.height / 2);
    canvas.drawLine(pointThree, pointFour, barRemainingPaint);

    //paint thumb
    final center = Offset(thumbDx, size.height / 2);
    canvas.drawCircle(center, thumbSize / 2, thumbPaint);
  }

  late HorizontalDragGestureRecognizer _drag;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  void _updateThumbPosition(Offset localPosition) {
    var dx = localPosition.dx.clamp(0, size.width);
    _currentThumbValue = double.parse((dx / size.width).toStringAsFixed(1));
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }
}
