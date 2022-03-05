import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/screens/destination.dart';
import 'package:g7trailapp/screens/profile.dart';
import 'package:g7trailapp/services/beacon_service.dart';
import 'package:provider/provider.dart';
import '../screens/explore.dart';
import '../screens/map.dart';
import './fluid_nav_bar.dart';

late Destination? nearbyBeacon;

class FluidNavigationBar extends StatefulWidget {
  const FluidNavigationBar({Key? key, this.defaultTab, this.highlightedDestination}) : super(key: key);

  final Destination? highlightedDestination;
  final int? defaultTab;

  @override
  State createState() {
    return _FluidNavigationBarState();
  }
}

class _FluidNavigationBarState extends State<FluidNavigationBar> {
  late Widget _child;

  Destination? _nearestBeacon;
  Destination? _previousBeacon = null;

  @override
  void initState() {
    switch (widget.defaultTab ?? 0) {
      case 0:
        _child = ExploreScreen();
        break;
      case 1:
        _child = MapScreen(highlightedDestination: widget.highlightedDestination);
        break;
      case 2:
        _child = ProfileScreen();
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
      body: Consumer<BeaconService>(
        builder: (context, service, child) {
          if (service.nearbyBeacon != null) {
            SchedulerBinding.instance!.addPostFrameCallback((_) {
              setState(() {
                _previousBeacon = _nearestBeacon;
                _nearestBeacon = service.nearbyBeacon!;
              });

              if (service.nearbyBeacon != null) {
                if (_previousBeacon != service.nearbyBeacon || _previousBeacon == null) {
                  setState(() {
                    _previousBeacon = _nearestBeacon;
                  });

                  _handleBeaconFound(_nearestBeacon!);
                }
              }
            });
          }
          return _child;
        },
      ),
      bottomNavigationBar: FluidNavBar(
        onChange: _handleNavigationChange,
        selectedIndex: widget.defaultTab,
      ),
    );
  }

  @override
  void dispose() {
    nearbyBeacon = null;
    super.dispose();
  }

  void _handleBeaconFound(Destination d) {
    if (d.entryPoint) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("\"${d.destinationName}\" Found"),
          content: const Text('Would you like to start a hike?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Yes');
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("\"${d.destinationName}\" Found"),
          content: const Text('Tap continue to learn more!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) {
                  return DestinationScreen(destination: d);
                }));
              },
              child: Text(
                'Continue',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      );
    }
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
