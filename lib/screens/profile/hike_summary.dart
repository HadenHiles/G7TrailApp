import 'package:flutter/material.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/models/firestore/hike.dart';
import 'package:g7trailapp/models/hike_destination.dart';
import 'package:g7trailapp/navigation/nav.dart';
import 'package:g7trailapp/screens/destination.dart';
import 'package:g7trailapp/services/firestore.dart';
import 'package:g7trailapp/services/utility.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:html/parser.dart';

class HikeSummary extends StatefulWidget {
  HikeSummary({Key? key, required this.hike, required this.viewContext}) : super(key: key);

  final Hike hike;
  final BuildContext viewContext;

  @override
  State<HikeSummary> createState() => _HikeSummaryState();
}

class _HikeSummaryState extends State<HikeSummary> {
  // State variables
  List<Destination> _destinations = [];

  @override
  void initState() {
    _loadDestinations(widget.hike);
    super.initState();
  }

  Future<void> _loadDestinations(Hike hike) async {
    String? data = hike.data;
    List<Destination> destinations = [];
    if (data.isNotEmpty) {
      List<HikeDestination> hikeDestinations = HikeDestination.decode(data);
      List<String> hdIds = hikeDestinations.map((hd) => hd.id).toList();
      print(hdIds);
      List a = [1, 2, 3];
      print(a);
      a.addAll([1, 2, 3]);
      print(a);

      await getContentByIds(hdIds, 'fl_content').then((docs) async {
        if (docs.isNotEmpty) {
          docs.forEach((hdDoc) async {
            Destination d = Destination.fromSnapshot(hdDoc);
            destinations.add(d);
          });
        }
      }).whenComplete(() async {
        for (int i = 0; i < destinations.length; i++) {
          await loadFirestoreImage(destinations[i].images.length > 0 ? destinations[i].images[0].image : null, 1).then((url) {
            destinations[i].imgURL = url;

            if (i == destinations.length - 1) {
              setState(() {
                _destinations = destinations;
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(widget.viewContext).size.height - MediaQuery.of(widget.viewContext).padding.top,
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
              _destinations.length < 1
                  ? Container()
                  : Container(
                      padding: EdgeInsets.only(top: 20, right: 15, bottom: 20, left: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            printWeekday(widget.hike.date).toUpperCase() + " Hike".toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontFamily: Theme.of(context).textTheme.headline5!.fontFamily,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
              Expanded(
                child: Stack(
                  children: [
                    _destinations.length < 1
                        ? Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _destinations.length,
                            shrinkWrap: false,
                            padding: EdgeInsets.only(bottom: 100),
                            itemBuilder: (context, i) {
                              var doc = parse(_destinations[i].destinationSummary);
                              var summaryParagraph = doc.getElementsByTagName('p').first.text;
                              summaryParagraph = summaryParagraph.isEmpty ? "<p></p>" : summaryParagraph;

                              return Column(
                                children: [
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      image: _destinations[i].imgURL != null
                                          ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(_destinations[i].imgURL!),
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
                                                    navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) {
                                                      return DestinationScreen(destination: _destinations[i]);
                                                    }));
                                                  });
                                                },
                                                title: Text(
                                                  _destinations[i].destinationName.toUpperCase(),
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
                                                        return FluidNavigationBar(defaultTab: 1, highlightedDestination: _destinations[i]);
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
          Positioned(
            top: 15,
            left: 15,
            child: InkWell(
              onTap: () {
                navigatorKey.currentState!.pop();
              },
              focusColor: darken(Theme.of(context).primaryColor, 0.6),
              enableFeedback: true,
              borderRadius: BorderRadius.circular(30),
              child: Icon(
                Icons.close_rounded,
                size: 34,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
