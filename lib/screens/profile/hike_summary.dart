import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/models/firestore/hike.dart';
import 'package:g7trailapp/models/hike_destination.dart';
import 'package:g7trailapp/navigation/nav.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:html/parser.dart';

class HikeSummary extends StatefulWidget {
  HikeSummary({Key? key, required this.hike}) : super(key: key);

  final Hike hike;

  @override
  State<HikeSummary> createState() => _HikeSummaryState();
}

class _HikeSummaryState extends State<HikeSummary> {
  List<Destination> _hikeDestinations = [];

  @override
  void initState() {
    super.initState();
    _loadHikeDestinations();
  }

  @override
  void didUpdateWidget(HikeSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadHikeDestinations();
  }

  Future<void> _loadHikeDestinations() async {
    setState(() {
      _hikeDestinations = [];
    });

    String? data = widget.hike.data;
    if (data.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      navigatorKey.currentState!.pop();
                    },
                    focusColor: darken(Theme.of(context).primaryColor, 0.6),
                    enableFeedback: true,
                    borderRadius: BorderRadius.circular(30),
                    child: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
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
                              color: Theme.of(context).textTheme.headline5!.color,
                              fontFamily: Theme.of(context).textTheme.headline5!.fontFamily,
                              fontSize: 18,
                              fontWeight: Theme.of(context).textTheme.headline5!.fontWeight,
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
                                              color: HomeTheme.darkTheme.textTheme.headline5!.color,
                                              fontFamily: HomeTheme.darkTheme.textTheme.headline5!.fontFamily,
                                              fontSize: 26,
                                              fontWeight: HomeTheme.darkTheme.textTheme.headline5!.fontWeight,
                                            ),
                                          ),
                                          subtitle: Text(
                                            summaryParagraph.length >= 40 ? summaryParagraph.substring(0, 39) + ".." : summaryParagraph.substring(0, summaryParagraph.length) + "..",
                                            style: TextStyle(
                                              color: HomeTheme.darkTheme.textTheme.bodyText2!.color,
                                              fontFamily: HomeTheme.darkTheme.textTheme.bodyText2!.fontFamily,
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
                                              color: HomeTheme.darkTheme.textTheme.headline5!.color,
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
