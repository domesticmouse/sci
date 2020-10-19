import 'dart:async';

import 'package:flutter/material.dart';

import 'push_button.dart';
import 'foundation.dart';

class Sheet extends StatelessWidget {
  const Sheet({
    Key key,
    @required this.content,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  final Widget content;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: const Color(0xebf6f4ed),
      elevation: 4,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border.fromBorderSide(BorderSide(color: const Color(0xff999999))),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xffdedcd5)),
              ),
            ),
            child: Padding(
              padding: padding,
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  static Future<T> open<T>({
    BuildContext context,
    Widget content,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8),
    Color barrierColor = const Color(0x80000000),
    bool barrierDismissible = false,
  }) {
    return DialogTracker<T>().open(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      child: Sheet(
        padding: padding,
        content: content,
      ),
    );
  }
}

class Prompt extends StatelessWidget {
  const Prompt({
    Key key,
    @required this.messageType,
    @required this.message,
    this.body,
    this.options = const <String>[],
    this.selectedOption,
  })  : assert(messageType != null),
        assert(message != null),
        super(key: key);

  final MessageType messageType;
  final String message;
  final Widget body;
  final List<String> options;
  final int selectedOption;

  void _setSelectedOption(BuildContext context, int index) {
    Navigator.of(context).pop<int>(index);
  }

  @override
  Widget build(BuildContext context) {
    return Sheet(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xff999999),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(13),
              child: SizedBox(
                width: 280,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    messageType.toImage(),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 11),
                              child: body,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(options.length, (int index) {
                return Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: CommandPushButton(
                    onPressed: () => _setSelectedOption(context, index),
                    label: options[index],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  static Future<int> open({
    BuildContext context,
    @required MessageType messageType,
    @required String message,
    Widget body,
    List<String> options = const <String>[],
    int selectedOption,
  }) {
    assert(messageType != null);
    assert(message != null);
    return DialogTracker<int>().open(
      context: context,
      barrierDismissible: false,
      child: Prompt(
        messageType: messageType,
        message: message,
        body: body,
        options: options,
        selectedOption: selectedOption,
      ),
    );
  }
}

/// Tracks the open/close animation of a dialog, allowing callers to open a
/// dialog and get notified when the dialog fully closes (closing animation
/// completes) rather than simply when the modal route is popped (closing
/// animation starts)
@visibleForTesting
class DialogTracker<T> {
  final Completer<T> _completer = Completer<T>();

  Animation<double> _animation;
  bool _isDialogClosing = false;
  _AsyncResult<T> _result;

  Future<T> open({
    BuildContext context,
    bool barrierDismissible = true,
    String barrierLabel = 'Dismiss',
    Color barrierColor = const Color(0x80000000),
    Widget child,
  }) {
    final ThemeData theme = Theme.of(context);
    showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        Widget result = child;
        if (theme != null) {
          result = Theme(
            data: theme,
            child: result,
          );
        }
        return result;
      },
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        assert(_animation == null || _animation == animation);
        if (_animation == null) {
          assert(animation != null);
          _animation = animation;
          animation.addStatusListener(_handleAnimationStatusUpdate);
        }
        return Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, -1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
    ).then((T value) {
      _result = _AsyncResult.value(value);
    }).catchError((dynamic error, StackTrace stack) {
      _result = _AsyncResult.error(error, stack);
    });
    return _completer.future;
  }

  void _handleAnimationStatusUpdate(AnimationStatus status) {
    if (!_isDialogClosing && status == AnimationStatus.reverse) {
      _isDialogClosing = true;
    }
    if (_isDialogClosing && status == AnimationStatus.dismissed) {
      assert(_result != null);
      assert(!_completer.isCompleted);
      _isDialogClosing = false;
      _animation.removeStatusListener(_handleAnimationStatusUpdate);
      _animation = null;
      _result.complete(_completer);
    }
  }
}

class _AsyncResult<T> {
  const _AsyncResult.value(this.value)
      : error = null,
        stack = null;

  const _AsyncResult.error(this.error, this.stack)
      : assert(error != null),
        assert(stack != null),
        value = null;

  final FutureOr<T> value;
  final dynamic error;
  final StackTrace stack;

  void complete(Completer<T> completer) {
    if (error != null) {
      completer.completeError(error, stack);
    } else {
      completer.complete(value);
    }
  }
}
