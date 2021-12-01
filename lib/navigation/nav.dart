import 'package:flutter/material.dart';
import 'package:g7trailapp/screens/profile.dart';
import '../screens/explore.dart';
import '../screens/map.dart';
import './fluid_nav_bar.dart';

class FluidNavigationBar extends StatefulWidget {
  const FluidNavigationBar({Key? key, this.defaultTab}) : super(key: key);

  final int? defaultTab;

  @override
  State createState() {
    return _FluidNavigationBarState();
  }
}

class _FluidNavigationBarState extends State<FluidNavigationBar> {
  late Widget _child;

  @override
  void initState() {
    switch (widget.defaultTab ?? 0) {
      case 0:
        _child = ExploreScreen();
        break;
      case 1:
        _child = const MapScreen();
        break;
      case 2:
        _child = const ProfileScreen();
        break;
    }
    _child = AnimatedSwitcher(
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      duration: const Duration(milliseconds: 500),
      child: _child,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Build a simple container that switches content based of off the selected navigation item
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBody: true,
      body: _child,
      bottomNavigationBar: FluidNavBar(
        onChange: _handleNavigationChange,
        selectedIndex: widget.defaultTab,
      ),
    );
  }

  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _child = ExploreScreen();
          break;
        case 1:
          _child = const MapScreen();
          break;
        case 2:
          _child = const ProfileScreen();
          break;
      }
      _child = AnimatedSwitcher(
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        duration: const Duration(milliseconds: 500),
        child: _child,
      );
    });
  }
}
