import 'package:flutter/material.dart';

class Spinner extends StatefulWidget {
  const Spinner({Key? key, required this.icon, this.duration = const Duration(milliseconds: 1800)}) : super(key: key);

  final Icon icon;
  final Duration duration;

  @override
  _SpinnerState createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Widget _child;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat();
    _child = widget.icon;

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: _child,
    );
  }
}
