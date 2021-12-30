import 'package:flutter/material.dart';
import 'package:g7trailapp/theme/theme.dart';
import './curves.dart';

typedef FluidNavBarButtonPressedCallback = void Function();

class FluidNavBarButton extends StatefulWidget {
  static const nominalExtent = Size(64, 64);

  final IconData _iconData;
  final bool _selected;
  final FluidNavBarButtonPressedCallback _onPressed;

  const FluidNavBarButton(IconData iconData, bool selected, FluidNavBarButtonPressedCallback onPressed, {Key? key})
      : _iconData = iconData,
        _selected = selected,
        _onPressed = onPressed,
        super(key: key);

  @override
  State createState() {
    // ignore: no_logic_in_create_state
    return _FluidNavBarButtonState(_iconData, _selected, _onPressed);
  }
}

class _FluidNavBarButtonState extends State<FluidNavBarButton> with SingleTickerProviderStateMixin {
  static const double _activeOffset = 16;
  static const double _defaultOffset = 0;
  static const double _radius = 25;

  final IconData _iconData;
  bool _selected;
  final FluidNavBarButtonPressedCallback _onPressed;

  late AnimationController _animationController;
  late Animation<double> _animation;

  _FluidNavBarButtonState(IconData iconData, bool selected, FluidNavBarButtonPressedCallback onPressed)
      : _iconData = iconData,
        _selected = selected,
        _onPressed = onPressed;

  @override
  void initState() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 1666), reverseDuration: const Duration(milliseconds: 833), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _startAnimation();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    const ne = FluidNavBarButton.nominalExtent;
    final offsetCurve = _selected ? const ElasticOutCurve(0.38) : Curves.easeInQuint;

    final progress = const LinearPointCurve(0.28, 0.0).transform(_animation.value);

    final offset = Tween<double>(begin: _defaultOffset, end: _activeOffset).transform(offsetCurve.transform(progress));

    // Create a parameterizable flat button with a fluid fill icon
    return GestureDetector(
      // We wan't to know when this button was tapped, don't bother letting out children know as well
      onTap: _onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Alignment container to the circle
        constraints: BoxConstraints.tight(ne),
        alignment: Alignment.center,
        child: Container(
          // This container just draws a circle with a certain radius and offset
          margin: EdgeInsets.all(ne.width / 2 - _radius),
          constraints: BoxConstraints.tight(const Size.square(_radius * 2)),
          decoration: ShapeDecoration(
            color: darken(Color(0xffA9B7A7), 0.2),
            shape: CircleBorder(),
          ),
          transform: Matrix4.translationValues(0, -offset, 0),
          // Create a fluid fill icon that get's filled in with a slight delay to the buttons animation
          child: Icon(
            _iconData,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(oldWidget) {
    setState(() {
      _selected = widget._selected;
    });
    _startAnimation();
    super.didUpdateWidget(oldWidget);
  }

  void _startAnimation() {
    if (_selected) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}
