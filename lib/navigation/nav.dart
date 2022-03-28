import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/confirm_dialog.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/screens/destination.dart';
import 'package:g7trailapp/screens/profile.dart';
import 'package:g7trailapp/services/beacon_ranging_service.dart';
import 'package:g7trailapp/services/session.dart';
import 'package:g7trailapp/services/utility.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/utility/custom_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../screens/explore.dart';
import '../screens/map.dart';
import './fluid_nav_bar.dart';

late Destination? nearbyBeacon;
final PanelController sessionPanelController = PanelController();

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

  PanelState _sessionPanelState = PanelState.CLOSED;
  double _bottomNavOffsetPercentage = 0;

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
    return SessionServiceProvider(
      service: sessionService,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        extendBody: true,
        body: SlidingUpPanel(
          backdropEnabled: false,
          controller: sessionPanelController,
          maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
          minHeight: sessionService.isRunning ? 65 : 0,
          margin: EdgeInsets.only(bottom: (AppBar().preferredSize.height) - (AppBar().preferredSize.height * _bottomNavOffsetPercentage)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          onPanelOpened: () {
            setState(() {
              _sessionPanelState = PanelState.OPEN;
            });
          },
          onPanelClosed: () {
            setState(() {
              _sessionPanelState = PanelState.CLOSED;
            });
          },
          onPanelSlide: (double offset) {
            setState(() {
              _bottomNavOffsetPercentage = offset;
            });
          },
          panel: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: sessionService, // listen to ChangeNotifier
                  builder: (context, child) {
                    return Container(
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.primary,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              printWeekday(DateTime.now()) + " Hike",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontFamily: "NovecentoSans",
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Feedback.forLongPress(context);

                                    if (!sessionService.isPaused) {
                                      sessionService.pause();
                                    } else {
                                      sessionService.resume();
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(
                                      sessionService.isPaused ? Icons.play_arrow : Icons.pause,
                                      size: 30,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                  focusColor: darken(Theme.of(context).primaryColor, 0.2),
                                  enableFeedback: true,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      printDuration(sessionService.currentDuration, true),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontFamily: "NovecentoSans",
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: InkWell(
                          focusColor: darken(Theme.of(context).primaryColor, 0.6),
                          enableFeedback: true,
                          borderRadius: BorderRadius.circular(30),
                          child: Icon(
                            _sessionPanelState == PanelState.CLOSED ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          onTap: () {
                            Feedback.forLongPress(context);

                            if (sessionPanelController.isPanelClosed) {
                              sessionPanelController.open();
                              setState(() {
                                _sessionPanelState = PanelState.OPEN;
                              });
                            } else {
                              sessionPanelController.close();
                              setState(() {
                                _sessionPanelState = PanelState.CLOSED;
                              });
                            }
                          },
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        onTap: () {
                          if (sessionPanelController.isPanelClosed) {
                            sessionPanelController.open();
                            setState(() {
                              _sessionPanelState = PanelState.OPEN;
                            });
                          } else {
                            sessionPanelController.close();
                            setState(() {
                              _sessionPanelState = PanelState.CLOSED;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
                // panel content here
              ],
            ),
          ),
          body: Consumer<BeaconRangingService>(
            builder: (context, service, child) {
              if (service.nearbyBeacon != null && preferences.beaconFoundAlert) {
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
        ),
        bottomNavigationBar: SizedOverflowBox(
          alignment: AlignmentDirectional.topCenter,
          size: Size.fromHeight(AppBar().preferredSize.height - (AppBar().preferredSize.height * _bottomNavOffsetPercentage)),
          child: FluidNavBar(
            onChange: _handleNavigationChange,
            selectedIndex: widget.defaultTab,
          ),
        ),
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

                if (!sessionService.isRunning) {
                  Feedback.forTap(context);
                  sessionService.start();
                  sessionPanelController.open();
                } else {
                  dialog(
                    context,
                    ConfirmDialog(
                      "Override current hike?",
                      Text(
                        "Starting a new hike will override your existing one.\n\nWould you like to continue?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      "Cancel",
                      () {
                        Navigator.of(context).pop();
                      },
                      "Continue",
                      () {
                        Feedback.forTap(context);
                        sessionService.reset();
                        Navigator.of(context).pop();
                        sessionService.start();
                        sessionPanelController.show();
                      },
                    ),
                  );
                }
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
