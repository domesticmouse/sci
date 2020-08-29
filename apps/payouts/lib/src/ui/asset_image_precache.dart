import 'package:flutter/widgets.dart';

class AssetImagePrecache extends StatefulWidget {
  const AssetImagePrecache({
    Key key,
    this.paths,
    this.child,
  }) : super(key: key);

  final List<String> paths;
  final Widget child;

  @override
  _AssetImagePrecacheState createState() => _AssetImagePrecacheState();
}

class _AssetImagePrecacheState extends State<AssetImagePrecache> {
  Iterable<Future<void>> _futures;
  bool _isComplete = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_futures == null && !_isComplete) {
      // precacheImage() guarantees that the futures will not throw
      _futures = widget.paths
          .map<AssetImage>((String path) => AssetImage(path))
          .map<Future<void>>((AssetImage image) => precacheImage(image, context));
      Future.wait<void>(_futures).then((void _) {
        _futures = null;
        _isComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
