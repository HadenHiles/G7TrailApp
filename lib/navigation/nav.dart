import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/models/firestore/hike.dart';
import 'package:g7trailapp/models/hike_destination.dart';
import 'package:g7trailapp/screens/destination.dart';
import 'package:g7trailapp/screens/profile.dart';
import 'package:g7trailapp/services/beacon_ranging_service.dart';
import 'package:g7trailapp/services/session.dart';
import 'package:g7trailapp/services/utility.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vibration/vibration.dart';
import '../screens/explore.dart';
import '../screens/map.dart';
import './fluid_nav_bar.dart';
import 'package:html/parser.dart';

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
        backgroundColor: Theme.of(context).colorScheme.surface,
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
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                opacity: 0.2,
                image: AssetImage("assets/images/app-icon.png"),
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(color: darken(Theme.of(context).colorScheme.secondary, 0.5).withOpacity(0.55)),
                ),
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: sessionService, // listen to ChangeNotifier
                      builder: (context, child) {
                        return GestureDetector(
                          onTap: _startHike,
                          child: Container(
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
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
                                          "Start a hike".toUpperCase(),
                                          style: Theme.of(context).textTheme.headlineMedium,
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
                                    )
                                  : InkWell(
                                      child: Icon(
                                        Icons.arrow_circle_right,
                                        color: darken(Theme.of(context).colorScheme.secondary, 0.1),
                                        size: 50,
                                      ),
                                    ),
                              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                            ),
                          ),
                        );
                      },
                    ),
                    _hikeDestinations.length < 1
                        ? Container()
                        : Container(
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                            padding: EdgeInsets.only(top: 0, right: 15, bottom: 8, left: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Destinations visited".toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.headlineSmall!.color,
                                    fontFamily: Theme.of(context).textTheme.headlineSmall!.fontFamily,
                                    fontSize: 18,
                                    fontWeight: Theme.of(context).textTheme.headlineSmall!.fontWeight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                            itemCount: _hikeDestinations.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.only(bottom: 100),
                            itemBuilder: (context, i) {
                              var doc = parse(_hikeDestinations[i].destinationSummary);
                              var summaryParagraph = doc.getElementsByTagName('p').first.text;
                              summaryParagraph = summaryParagraph.isEmpty ? "<p></p>" : summaryParagraph;

                              return Column(
                                children: [
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      image: _hikeDestinations[i].imgURL != null
                                          ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(_hikeDestinations[i].imgURL!),
                                            )
                                          : DecorationImage(
                                              fit: BoxFit.cover,
                                              image: AssetImage("assets/images/app-icon.png"),
                                            ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(color: darken(Theme.of(context).colorScheme.secondary, 0.4).withOpacity(0.45)),
                                        ),
                                        Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              ListTile(
                                                dense: true,
                                                onTap: () {
                                                  sessionPanelController.close();
                                                  Future.delayed(Duration(milliseconds: 500), () {
                                                    navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) {
                                                      return FluidNavigationBar(defaultTab: 1, highlightedDestination: _hikeDestinations[i]);
                                                    }));
                                                  });
                                                },
                                                title: Text(
                                                  _hikeDestinations[i].destinationName.toUpperCase(),
                                                  style: TextStyle(
                                                    color: HomeTheme.darkTheme.textTheme.headlineSmall!.color,
                                                    fontFamily: HomeTheme.darkTheme.textTheme.headlineSmall!.fontFamily,
                                                    fontSize: 26,
                                                    fontWeight: HomeTheme.darkTheme.textTheme.headlineSmall!.fontWeight,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  summaryParagraph.length >= 40 ? summaryParagraph.substring(0, 39) + ".." : summaryParagraph.substring(0, summaryParagraph.length) + "..",
                                                  style: TextStyle(
                                                    color: HomeTheme.darkTheme.textTheme.bodyMedium!.color,
                                                    fontFamily: HomeTheme.darkTheme.textTheme.bodyMedium!.fontFamily,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                                trailing: InkWell(
                                                  onTap: () {
                                                    Future.delayed(Duration.zero, () {
                                                      navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) {
                                                        return FluidNavigationBar(defaultTab: 1, highlightedDestination: _hikeDestinations[i]);
                                                      }));
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.arrow_right_alt_rounded,
                                                    size: 36,
                                                    color: HomeTheme.darkTheme.textTheme.headlineSmall!.color,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 85,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    darken(Theme.of(context).colorScheme.secondary, 0.4).withOpacity(0),
                                    darken(Theme.of(context).colorScheme.secondary, 0.4).withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          !sessionService.isRunning
                              ? Container()
                              : Positioned(
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          width: MediaQuery.of(context).size.width * 0.49,
                                          child: TextButton(
                                            child: Text(
                                              "Cancel".toUpperCase(),
                                              style: TextStyle(
                                                fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                                                fontFamily: Theme.of(context).textTheme.headlineSmall!.fontFamily,
                                                color: Color(0xffCC3333),
                                              ),
                                            ),
                                            style: ButtonStyle(
                                              padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 2)),
                                              backgroundColor: WidgetStateProperty.all(darken(Theme.of(context).colorScheme.primary, 0.05)),
                                            ),
                                            onPressed: () => _finishHike(false),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          width: MediaQuery.of(context).size.width * 0.49,
                                          child: TextButton(
                                            child: Text(
                                              "Save".toUpperCase(),
                                              style: TextStyle(
                                                fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                                                fontFamily: Theme.of(context).textTheme.headlineSmall!.fontFamily,
                                                color: Theme.of(context).colorScheme.onSecondary,
                                              ),
                                            ),
                                            style: ButtonStyle(
                                              padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 2)),
                                              backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor),
                                            ),
                                            onPressed: () => _finishHike(true),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Consumer<BeaconRangingService>(
            builder: (context, service, child) {
              if (service.nearbyBeacon != null) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
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
        if (data == null || data.isEmpty) {
          beacons.add(hikeD);
          prefs.setString("hike_data", HikeDestination.encode(beacons));

          await _loadDestination(hikeD).then((d) {
            setState(() {
              _hikeDestinations.add(d);
            });
          });
        } else {
          beacons = HikeDestination.decode(data);
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

    if (preferences.beaconFoundAlert && (_previousBeacon != d || _previousBeacon == null) && (destinations.length < 1 || destinations.last!.id != d.id)) {
      if (d.entryPoint) {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate();
        }

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

                      navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) {
                        return FluidNavigationBar(defaultTab: 2);
                      }));
                    }
                  },
                ),
              ),
            );
          },
          duration: Duration(seconds: 30),
        );
      } else if (sessionService.isRunning) {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate();
        }

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

                    Future.delayed(Duration.zero, () {
                      navigatorKey.currentState!.push(
                        MaterialPageRoute(builder: (context) {
                          return DestinationScreen(destination: d);
                        }),
                      );
                    });
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

    if (!sessionService.isRunning) {
      sessionService.start();
    }
  }

  void _finishHike(bool? save) {
    save = save ?? false;

    if (save && FirebaseAuth.instance.currentUser != null && !FirebaseAuth.instance.currentUser!.isAnonymous) {
      _saveHike(user!, prefs.getString("hike_data"));

      sessionService.reset();
      sessionPanelController.close();

      setState(() {
        _hikeDestinations.clear();
        prefs.setString("hike_data", "");
      });

      navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) {
        return FluidNavigationBar(defaultTab: 2);
      }));
    } else if (save) {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text("Login required"),
                content: Container(
                  child: Text(
                    "Please login to save hikes.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Close');
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Login');

                      sessionPanelController.close();
                      _handleNavigationChange(2); // Go to profile tab without re-painting navigation widget (messes up hike session contents)
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ));
    } else {
      sessionService.reset();
      sessionPanelController.close();

      setState(() {
        _hikeDestinations.clear();
        prefs.setString("hike_data", "");
      });
    }
  }

  Future<void> _saveHike(User user, String? data) async {
    if (data != null && data.isNotEmpty) {
      Hike hike = Hike(data, sessionService.currentDuration, DateTime.now());
      FirebaseFirestore.instance.collection('hikes').doc(user.uid).collection('hikes').add(hike.toMap());
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
