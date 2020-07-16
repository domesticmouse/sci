import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Tab {
  const Tab({
    this.label,
    this.child,
  });

  final String label;
  final Widget child;
}

class TabPane extends StatefulWidget {
  const TabPane({
    this.initialSelectedIndex = 0,
    this.tabs,
  })  : assert(tabs != null),
        assert(tabs.length > 0);

  final int initialSelectedIndex;
  final List<Tab> tabs;

  @override
  _TabPaneState createState() => _TabPaneState();
}

class _TabPaneState extends State<TabPane> {
  int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[];
    for (int i = 0; i < widget.tabs.length; i++) {
      final Tab tab = widget.tabs[i];
      if (i == selectedIndex) {
        tabs.add(
          Ink(
            decoration: BoxDecoration(
              color: Color(0xfff7f5ee),
              border: Border(
                top: BorderSide(width: 1, color: Color(0xff999999)),
                bottom: BorderSide(width: 1, color: Color(0xfff7f5ee)),
                left: BorderSide(width: 1, color: Color(0xff999999)),
                right: BorderSide(width: 1, color: Color(0xff999999)),
              ),
              gradient: LinearGradient(
                begin: Alignment(0, -0.85),
                end: Alignment(0, -0.65),
                colors: <Color>[Color(0xffe2e0d8), Color(0xfff7f5ee)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(4, 3, 4, 4),
              child: Text(tab.label),
            ),
          ),
        );
      } else {
        tabs.add(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = i;
                });
              },
              child: Ink(
                decoration: BoxDecoration(
                  color: Color(0xffc4c3bc),
                  border: Border(
                    top: BorderSide(width: 1, color: Color(0xff999999)),
                    bottom: BorderSide(width: 1, color: Color(0xff999999)),
                    left: BorderSide(width: 1, color: Color(0xff999999)),
                    right: BorderSide(width: 1, color: Color(0xff999999)),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment(0, -0.85),
                    end: Alignment(0, -0.65),
                    colors: <Color>[Color(0xffdad8d0), Color(0xffc4c3bc)],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4, 3, 4, 4),
                  child: Text(tab.label),
                ),
              ),
            ),
          ),
        );
      }
      tabs.add(
        Ink(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1, color: Color(0xff999999)),
            ),
          ),
          child: SizedBox(width: 2),
        ),
      );
    }
    tabs.add(
      Expanded(
        child: Ink(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1, color: Color(0xff999999)),
            ),
          ),
          child: SizedBox(width: 4),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: tabs,
        ),
        Expanded(
          child: Ink(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 1, color: Color(0xff999999)),
                right: BorderSide(width: 1, color: Color(0xff999999)),
                bottom: BorderSide(width: 1, color: Color(0xff999999)),
              ),
              color: Color(0xfff7f5ee),
            ),
            child: IndexedStack(
              index: selectedIndex,
              sizing: StackFit.passthrough,
              children: List<Widget>.generate(widget.tabs.length, (int index) {
                return ExcludeFocus(
                  excluding: index != selectedIndex,
                  child: widget.tabs[index].child,
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
