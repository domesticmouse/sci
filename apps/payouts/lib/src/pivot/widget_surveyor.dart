import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Class that allows callers to measure the size of arbitrary widgets when
/// laid out with specific constraints.
///
/// The widget surveyor creates synthetic widget trees to hold the widgets it
/// measures. This is important because if the widgets (or any widgets in their
/// subtrees) depend on any inherited widgets (e.g. [Directionality]) that they
/// assume exist in their ancestry, those assumptions may hold true when the
/// widget is rendered by the application but prove false when the widget is
/// rendered via the widget surveyor. Due to this, callers are advised to
/// either:
///
///  1. pass in widgets that don't depend on inherited widgets, or
///  1. ensure all inherited widget dependencies exist in the widget tree
///     that's passed to the widget surveyor's measure methods.
class WidgetSurveyor {
  const WidgetSurveyor();

  /// Builds a widget from the specified builder, inserts the widget into a
  /// synthetic widget tree, lays out the resulting render tree, and returns
  /// the size of the laid-out render tree.
  ///
  /// The build context that's passed to the `builder` argument will represent
  /// the root of the synthetic tree.
  ///
  /// The `constraints` argument specify the constraints that will be passed
  /// to the render tree during layout. If unspecified, the widget will be laid
  /// out unconstrained.
  Size measureBuilder(
    WidgetBuilder builder, {
    BoxConstraints constraints = const BoxConstraints(),
  }) {
    return measureWidget(Builder(builder: builder), constraints: constraints);
  }

  /// Inserts the specified widget into a synthetic widget tree, lays out the
  /// resulting render tree, and returns the size of the laid-out render tree.
  ///
  /// The `constraints` argument specify the constraints that will be passed
  /// to the render tree during layout. If unspecified, the widget will be laid
  /// out unconstrained.
  Size measureWidget(
    Widget widget, {
    BoxConstraints constraints = const BoxConstraints(),
  }) {
    final _MeasurementView rendered = _render(widget, constraints);
    assert(rendered.hasSize);
    return rendered.size;
  }

  double? measureDistanceToActualBaseline(
    Widget widget, {
    TextBaseline baseline = TextBaseline.alphabetic,
    BoxConstraints constraints = const BoxConstraints(),
  }) {
    final _MeasurementView rendered = _render(widget, constraints);
    return rendered.getDistanceToActualBaseline(baseline);
  }

  _MeasurementView _render(Widget widget, BoxConstraints constraints) {
    PipelineOwner pipelineOwner = PipelineOwner(
      onNeedVisualUpdate: () {},
      onSemanticsOwnerCreated: () {},
      onSemanticsOwnerDisposed: () {},
    );
    pipelineOwner.rootNode = _MeasurementView();
    BuildOwner buildOwner = BuildOwner(onBuildScheduled: () {});
    RenderObjectToWidgetAdapter<RenderBox>(
      container: pipelineOwner.rootNode as RenderObjectWithChildMixin<RenderBox>,
      debugShortDescription: '[root]',
      child: widget,
    ).attachToRenderTree(buildOwner);
    _MeasurementView rootView = pipelineOwner.rootNode as _MeasurementView;
    rootView.scheduleInitialLayout();
    rootView.childConstraints = constraints;
    pipelineOwner.flushLayout();
    assert(rootView.child != null);
    return rootView;
  }
}

class _MeasurementView extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  BoxConstraints? childConstraints;

  @override
  void performLayout() {
    assert(child != null);
    assert(childConstraints != null);
    child!.layout(childConstraints!, parentUsesSize: true);
    size = child!.size;
  }

  @override
  double? getDistanceToActualBaseline(TextBaseline baseline) {
    return super.getDistanceToActualBaseline(baseline);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return child!.getDistanceToActualBaseline(baseline);
  }

  @override
  void debugAssertDoesMeetConstraints() => true;
}
