import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/screens/destination.dart';
import 'package:g7trailapp/services/beacon_ranging_service.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:g7trailapp/utility/string_formatting.dart';
import 'package:g7trailapp/widgets/screen_title.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // State variables
  Destination? _nearestBeacon;
  bool _nearEntryPoint = false;
  List<Destination> _easyDestinations = [];
  List<Destination> _moderateDestinations = [];
  List<Destination> _difficultDestinations = [];
  List<Destination> _nearbyDestinations = [];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "destination").where('active', isEqualTo: true).get().then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        List<Destination> easy = [];
        List<Destination> moderate = [];
        List<Destination> difficult = [];
        for (var doc in snapshot.docs) {
          Destination d = Destination.fromSnapshot(doc);
          if (!d.entryPoint && d.images.isNotEmpty) {
            await loadFirestoreImage(d.images[0].image, 1).then((url) => d.imgURL = url);

            switch (d.difficulty) {
              case "easy":
                easy.add(d);
                break;
              case "moderate":
                moderate.add(d);
                break;
              case "difficult":
                difficult.add(d);
                break;
            }
          }

          setState(() {
            _easyDestinations = easy;
            _moderateDestinations = moderate;
            _difficultDestinations = difficult;
          });
        }
      }
    });
  }

  Future<void> _loadNearbyDestinations(Destination beacon) async {
    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "destination").where('beaconInfo.beaconId', isEqualTo: beacon.beaconId).limit(1).get().then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        List<Destination> nearby = [];
        for (var doc in snapshot.docs) {
          Destination d = Destination.fromSnapshot(doc);
          if (d.entryPoint) {
            if (d.beaconId == beacon.beaconId) {
              for (DocumentReference ref in d.nearbyDestinations) {
                await ref.get().then((snap) async {
                  if (snap.exists) {
                    Destination n = Destination.fromSnapshot(snap);
                    if (n.active) {
                      await loadFirestoreImage(n.images[0].image, 1).then((url) => n.imgURL = url);
                      nearby.add(n);
                    }
                  }
                });
              }

              setState(() {
                _nearbyDestinations = nearby;
              });
            }
          } else {
            setState(() {
              _nearbyDestinations = [];
            });
          }
        }
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(context) {
    return Consumer<BeaconRangingService>(
      builder: (context, service, child) {
        if (service.nearbyBeacon != null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _nearestBeacon = service.nearbyBeacon!;
            });

            if (service.nearbyBeacon != null && service.nearbyBeacon!.entryPoint) {
              setState(() {
                _nearEntryPoint = true;
              });

              _loadNearbyDestinations(service.nearbyBeacon!);
            } else {
              setState(() {
                _nearEntryPoint = false;
              });
            }
          });
        }
        return buildScrollView();
      },
    );
  }

  Widget buildScrollView() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            collapsedHeight: 65,
            expandedHeight: 100,
            backgroundColor: Theme.of(context).colorScheme.primary,
            iconTheme: Theme.of(context).iconTheme,
            actionsIconTheme: Theme.of(context).iconTheme,
            floating: true,
            pinned: true,
            flexibleSpace: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                titlePadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                centerTitle: false,
                title: ScreenTitle(icon: Icons.explore, title: "Explore"),
                background: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            actions: null,
          ),
        ];
      },
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadDestinations(),
              color: Theme.of(context).colorScheme.secondary,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 15, right: 0, bottom: 15, left: 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !_nearEntryPoint || _nearbyDestinations.isEmpty
                          ? Container()
                          : Column(
                              children: [
                                SizedBox(height: 15),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Near Me".toUpperCase(),
                                        style: Theme.of(context).textTheme.headlineMedium,
                                        textAlign: TextAlign.start,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "(" + _nearestBeacon!.destinationName.toUpperCase() + ")",
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 310,
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(left: 10),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _nearbyDestinations.length,
                                    itemBuilder: (context, i) {
                                      return _buildDestination(_nearbyDestinations[i]);
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Divider(
                                    color: darken(Theme.of(context).colorScheme.surface, 0.25),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: 15),
                      _easyDestinations.length < 1
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Easy".toUpperCase(),
                                    style: Theme.of(context).textTheme.headlineMedium,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  height: 310,
                                  child: _easyDestinations.isEmpty
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                                              child: LinearProgressIndicator(
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ],
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.only(left: 10),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _easyDestinations.length,
                                          itemBuilder: (context, i) {
                                            return _buildDestination(_easyDestinations[i]);
                                          },
                                        ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Divider(
                                    color: darken(Theme.of(context).colorScheme.surface, 0.25),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: 15),
                      _moderateDestinations.length < 1
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Moderate".toUpperCase(),
                                    style: Theme.of(context).textTheme.headlineMedium,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  height: 310,
                                  child: _moderateDestinations.isEmpty
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                                              child: LinearProgressIndicator(
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ],
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.only(left: 10),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _moderateDestinations.length,
                                          itemBuilder: (context, i) {
                                            return _buildDestination(_moderateDestinations[i]);
                                          },
                                        ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Divider(
                                    color: darken(Theme.of(context).colorScheme.surface, 0.25),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: 15),
                      _difficultDestinations.length < 1
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Difficult".toUpperCase(),
                                    style: Theme.of(context).textTheme.headlineMedium,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  height: 310,
                                  child: _difficultDestinations.isEmpty
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                                              child: LinearProgressIndicator(
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ],
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.only(left: 10),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _difficultDestinations.length,
                                          itemBuilder: (context, i) {
                                            return _buildDestination(_difficultDestinations[i]);
                                          },
                                        ),
                                ),
                                SizedBox(height: 50),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nearestBeacon = null;
    _easyDestinations = [];
    _moderateDestinations = [];
    _difficultDestinations = [];
    _nearbyDestinations = [];
    super.dispose();
  }

  Widget _buildDestination(Destination destination) {
    String title = destination.destinationName;
    String? imgURL = destination.imgURL;
    Widget trailing = Text(destination.difficulty.capitalize(), style: Theme.of(context).textTheme.bodyLarge);
    Image img = imgURL != null ? Image(image: CachedNetworkImageProvider(imgURL)) : Image(image: AssetImage("assets/images/avatar.png"));

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: GestureDetector(
        onTap: () {
          navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) {
            return DestinationScreen(destination: destination);
          }));
        },
        child: Card(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: (MediaQuery.of(context).size.width * 0.8) * .73,
                  child: FittedBox(
                    clipBehavior: Clip.antiAlias,
                    fit: BoxFit.cover,
                    child: img,
                  ),
                ),
              ),
              ListTile(
                title: AutoSizeText(
                  title.toUpperCase(),
                  maxLines: 1,
                  maxFontSize: 22,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                trailing: trailing,
              ),
            ],
          ),
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0,
          margin: EdgeInsets.only(top: 10, right: 10),
        ),
      ),
    );
  }
}
