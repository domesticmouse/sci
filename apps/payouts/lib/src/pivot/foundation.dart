import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef Predicate<T> = bool Function(T item);

int binarySearch<T>(
  List<T> sortedList,
  T value, {
  int Function(T, T) compare,
}) {
  compare ??= _defaultCompare<T>();
  int min = 0;
  int max = sortedList.length;
  while (min < max) {
    int mid = min + ((max - min) >> 1);
    T element = sortedList[mid];
    int comp = compare(element, value);
    if (comp == 0) {
      return mid;
    } else if (comp < 0) {
      min = mid + 1;
    } else {
      max = mid;
    }
  }
  return -(min + 1);
}

enum SelectMode {
  none,
  single,
  multi,
}

/// Returns a [Comparator] that asserts that its first argument is comparable.
Comparator<T> _defaultCompare<T>() {
  return (T value1, T value2) => (value1 as Comparable<T>).compareTo(value2);
}

/// Returns true if any shift key is pressed on a physical keyboard.
bool isShiftKeyPressed() {
  final Set<LogicalKeyboardKey> keys = RawKeyboard.instance.keysPressed;
  return keys.contains(LogicalKeyboardKey.shiftLeft) ||
      keys.contains(LogicalKeyboardKey.shiftRight);
}

/// Returns true if any "command" key is pressed on a physical keyboard.
///
/// A command key is the "Command" (⌘) key on MacOS, and the "Control" (⌃)
/// key on other platforms.
bool isPlatformCommandKeyPressed([TargetPlatform platform]) {
  platform ??= defaultTargetPlatform;
  final Set<LogicalKeyboardKey> keys = RawKeyboard.instance.keysPressed;
  switch (platform) {
    case TargetPlatform.macOS:
      return keys.contains(LogicalKeyboardKey.metaLeft) ||
          keys.contains(LogicalKeyboardKey.metaRight);
    default:
      return keys.contains(LogicalKeyboardKey.controlLeft) ||
          keys.contains(LogicalKeyboardKey.controlRight);
  }
}

class Vote {
  const Vote._(this._name);

  final String _name;

  static const Vote approve = Vote._('approve');
  static const Vote deny = Vote._('deny');
  static const Vote abstain = Vote._('abstain');

  Vote tally(Vote other) {
    assert(other != null);
    switch (other) {
      case approve:
        return this;
      case deny:
        return other;
      case abstain:
        return this == deny ? this : other;
    }
    throw StateError('Unreachable code');
  }

  @override
  String toString() => _name;
}

class LinearConstraints extends Constraints {
  const LinearConstraints({
    this.min = 0,
    this.max = double.infinity,
  })  : assert(min != null),
        assert(max != null);

  const LinearConstraints.tight(double value)
      : assert(value != null),
        min = value,
        max = value;

  LinearConstraints.width(BoxConstraints constraints)
      : min = constraints.minWidth,
        max = constraints.maxWidth;

  LinearConstraints.height(BoxConstraints constraints)
      : min = constraints.minHeight,
        max = constraints.maxHeight;

  final double min;
  final double max;

  static const LinearConstraints zero = LinearConstraints(max: 0);

  double constrainMainAxisSize(MainAxisSize mainAxisSize) {
    switch (mainAxisSize) {
      case MainAxisSize.min:
        return min;
      case MainAxisSize.max:
        return max;
    }
    throw StateError('Unreachable');
  }

  @override
  bool get isNormalized => min >= 0 && min <= max;

  @override
  bool get isTight => min >= max;
}

class MessageType {
  const MessageType._(this._assetKey);

  final String _assetKey;

  static const MessageType error = MessageType._('error');
  static const MessageType warning = MessageType._('warning');
  static const MessageType question = MessageType._('question');
  static const MessageType info = MessageType._('info');

  Widget toImage() {
    return Image.asset('assets/message_type-$_assetKey-32x32.png');
  }

  Widget toSmallImage() {
    return Image.asset('assets/message_type-$_assetKey-16x16.png');
  }
}
