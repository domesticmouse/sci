import 'package:flutter/material.dart';

import 'push_button.dart';

enum MessageType {
  error,
  warning,
  question,
  info,
}

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
      elevation: 4,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xebf6f4ed),
          border: Border.fromBorderSide(BorderSide(color: Color(0xff999999))),
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
    bool barrierDismissible = false,
  }) {
    return _openDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
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

  static String _messageTypeToAsset(MessageType messageType) {
    switch (messageType) {
      case MessageType.error:
        return 'message_type-error-32x32.png';
      case MessageType.warning:
        return 'message_type-warning-32x32.png';
      case MessageType.question:
        return 'message_type-question-32x32.png';
      case MessageType.info:
        return 'message_type-info-32x32.png';
    }
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
                    Image.asset('assets/${_messageTypeToAsset(messageType)}'),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),
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
    return _openDialog<int>(
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

Future<T> _openDialog<T>({
  BuildContext context,
  bool barrierDismissible = true,
  String barrierLabel = 'Dismiss',
  Widget child,
}) {
  final ThemeData theme = Theme.of(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: const Color(0x80000000),
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
  );
}
