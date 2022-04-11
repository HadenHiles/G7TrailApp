import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/confirm_dialog.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/models/hike_destination.dart';
import 'package:g7trailapp/screens/destination.dart';
import 'package:g7trailapp/screens/profile.dart';
import 'package:g7trailapp/services/beacon_ranging_service.dart';
import 'package:g7trailapp/services/session.dart';
import 'package:g7trailapp/services/utility.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/utility/custom_dialogs.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vibration/vibration.dart';
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

  List<Destination> _hikeDestinations = [];
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

    _loadHikeDestinations();

    super.initState();
  }

  Future<void> _loadHikeDestinations() async {
    setState(() {
      _hikeDestinations = [];
    });

    String? data = prefs.getString('hike_data');
    if (data != null && data.isNotEmpty) {
      List<HikeDestination> hikeDestinations = HikeDestination.decode(data);
      for (HikeDestination hd in hikeDestinations) {
        await FirebaseFirestore.instance.collection('fl_content').doc(hd.id).get().then((snapshot) async {
          Destination d = Destination.fromSnapshot(snapshot);
          if (!d.entryPoint && d.images.isNotEmpty) {
            await loadFirestoreImage(d.images[0].image, 1).then((url) => d.imgURL = url);

            _hikeDestinations.add(d);
          }
        });
      }
    }
  }

  Future<Destination> _loadDestination(HikeDestination hd) async {
    return await FirebaseFirestore.instance.collection('fl_content').doc(hd.id).get().then((snapshot) async {
      Destination d = Destination.fromSnapshot(snapshot);
      if (!d.entryPoint && d.images.isNotEmpty) {
        await loadFirestoreImage(d.images[0].image, 1).then((url) => d.imgURL = url);

        return d;
      }

      return d;
    });
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
          minHeight: sessionService.isRunning ? 65 : 65,
          margin: EdgeInsets.only(bottom: (AppBar().preferredSize.height) - (AppBar().preferredSize.height * _bottomNavOffsetPercentage)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          isDraggable: sessionService.isRunning,
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
                        title: sessionService.isRunning
                            ? Row(
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
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Ready to go?",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontFamily: "NovecentoSans",
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                        trailing: sessionService.isRunning
                            ? InkWell(
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
                              )
                            : TextButton(
                                onPressed: _startHike,
                                child: Text(
                                  "Start Hike",
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                    fontFamily: Theme.of(context).textTheme.bodyLarge!.fontFamily,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                                ),
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
                Expanded(
                  child: ListView.builder(
                    itemCount: _hikeDestinations.length,
                    itemBuilder: (context, i) {
                      return Container(
                        height: 110,
                        child: ListTile(
                          leading: SizedBox(
                            height: 110,
                            width: 130,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: _hikeDestinations[i].imgURL != null
                                  ? Image(
                                      image: NetworkImage(_hikeDestinations[i].imgURL!),
                                    )
                                  : Image(image: AssetImage("assets/images/app-icon.png")),
                            ),
                          ),
                          title: Text(
                            _hikeDestinations[i].destinationName,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                !sessionService.isRunning
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(bottom: 25),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextButton(
                          child: Text(
                            "Cancel Hike".toUpperCase(),
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                              fontFamily: Theme.of(context).textTheme.headline5!.fontFamily,
                              color: Color(0xffCC3333),
                            ),
                          ),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 2)),
                            backgroundColor: MaterialStateProperty.all(darken(Theme.of(context).colorScheme.primary, 0.05)),
                          ),
                          onPressed: () => _finishHike(false),
                        ),
                      )
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
                    _handleBeaconFound(_nearestBeacon!).then((_) {
                      setState(() {
                        _previousBeacon = _nearestBeacon;
                      });
                    });
                  }
                });
              }
              return Padding(
                padding: EdgeInsets.only(bottom: 65),
                child: _child,
              );
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

  Future<void> _handleBeaconFound(Destination d) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<HikeDestination> beacons = [];
    List<HikeDestination?> destinations = [];
    String? data = prefs.getString('hike_data');
    if (data != null && data.isNotEmpty) {
      destinations = HikeDestination.decode(data);
    }

    HikeDestination hikeD = HikeDestination(id: d.reference!.id, entryPoint: d.entryPoint, destinationName: d.destinationName, beaconTitle: d.beaconTitle, beaconId: d.beaconId);

    if (!hikeD.entryPoint && (_previousBeacon == null || (destinations.length < 1 || destinations.last!.id != hikeD.id))) {
      if (sessionService.isRunning) {
        if (prefs.get('hike_data') == null) {
          beacons.add(hikeD);
          prefs.setString("hike_data", HikeDestination.encode(beacons));

          await _loadDestination(hikeD).then((d) {
            setState(() {
              _hikeDestinations.add(d);
            });
          });
        } else {
          beacons = HikeDestination.decode(prefs.getString('hike_data')!);
          beacons.add(hikeD);
          prefs.setString("hike_data", HikeDestination.encode(beacons));

          await _loadDestination(hikeD).then((d) {
            setState(() {
              _hikeDestinations.add(d);
            });
          });
        }
      } else {
        beacons = [];
        prefs.setString("hike_data", HikeDestination.encode(beacons));
        await _loadHikeDestinations();
      }
    }

    if (preferences.beaconFoundAlert && (_previousBeacon != d || _previousBeacon == null)) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate();
      }

      if (d.entryPoint) {
        showOverlayNotification(
          (context) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: SafeArea(
                child: ListTile(
                  leading: SizedBox.fromSize(
                    size: Size(40, 40),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image(
                        image: AssetImage("assets/images/app-icon.png"),
                      ),
                    ),
                  ),
                  title: !sessionService.isRunning ? Text("\"${d.destinationName}\" Found") : Text("Finished hiking?"),
                  subtitle: !sessionService.isRunning ? Text('Tap to start your hike!') : Text("Tap to finish your hike."),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      OverlaySupportEntry.of(context)?.dismiss();
                    },
                  ),
                  onTap: () {
                    OverlaySupportEntry.of(context)?.dismiss();

                    if (!sessionService.isRunning) {
                      _startHike();
                    } else {
                      _finishHike(true);
                    }
                  },
                ),
              ),
            );
          },
          duration: Duration(seconds: 30),
        );
      } else {
        showOverlayNotification(
          (context) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: SafeArea(
                child: ListTile(
                  leading: SizedBox.fromSize(
                    size: Size(40, 40),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image(
                        image: AssetImage("assets/images/app-icon.png"),
                      ),
                    ),
                  ),
                  title: Text("\"${d.destinationName}\" Found"),
                  subtitle: Text('Tap to learn more!'),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      OverlaySupportEntry.of(context)?.dismiss();
                    },
                  ),
                  onTap: () {
                    OverlaySupportEntry.of(context)?.dismiss();

                    navigatorKey.currentState!.push(
                      MaterialPageRoute(builder: (context) {
                        return DestinationScreen(destination: d);
                      }),
                    );
                  },
                ),
              ),
            );
          },
          duration: Duration(seconds: 15),
        );
      }
    }
  }

  void _startHike() {
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
  }

  void _finishHike(bool? save) {
    sessionService.reset();
    sessionPanelController.close();

    setState(() {
      _hikeDestinations.clear();
      prefs.setString("hike_data", "");
    });
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
