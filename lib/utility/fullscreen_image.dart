import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageFullScreenWrapperWidget extends StatelessWidget {
  final CachedNetworkImage child;
  final bool dark;

  const ImageFullScreenWrapperWidget({Key? key, required this.child, this.dark = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            barrierColor: dark ? Colors.black : Colors.white,
            pageBuilder: (BuildContext context, _, __) {
              return FullScreenPage(
                child: child,
                dark: dark,
              );
            },
          ),
        );
      },
      child: child,
    );
  }
}

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({Key? key, required this.child, required this.dark}) : super(key: key);

  final CachedNetworkImage child;
  final bool dark;

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  final TransformationController _interactiveViewerController = TransformationController();

  @override
  void initState() {
    var brightness = widget.dark ? Brightness.light : Brightness.dark;
    var color = widget.dark ? Colors.black12 : Colors.white70;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: color,
      statusBarColor: color,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarDividerColor: color,
      systemNavigationBarIconBrightness: brightness,
    ));

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        // Restore your settings here...
        ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.dark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          Stack(
            children: [
              AnimatedPositioned(
                duration: Duration(milliseconds: 333),
                curve: Curves.fastOutSlowIn,
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: LayoutBuilder(
                  builder: (__, constraint) {
                    return InteractiveViewer(
                      transformationController: _interactiveViewerController,
                      constrained: false,
                      panEnabled: true,
                      minScale: 0.1,
                      maxScale: 8,
                      child: Builder(
                        builder: (context) {
                          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                            final renderBox = context.findRenderObject() as RenderBox?;
                            final childSize = renderBox?.size ?? Size.zero;
                            if (childSize != Size.zero) {
                              _interactiveViewerController.value = Matrix4.identity() * _coverRatio(constraint.biggest, childSize);
                            }
                          });
                          return widget.child;
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: MaterialButton(
                  padding: const EdgeInsets.all(15),
                  elevation: 0,
                  child: Icon(
                    Icons.arrow_back,
                    color: widget.dark ? Colors.white : Colors.black,
                    size: 25,
                  ),
                  color: widget.dark ? Colors.black12 : Colors.white70,
                  highlightElevation: 0,
                  minWidth: double.minPositive,
                  height: double.minPositive,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _coverRatio(Size outside, Size inside) {
    if (outside.width / outside.height > inside.width / inside.height) {
      return outside.width / inside.width;
    } else {
      return outside.height / inside.height;
    }
  }
}
