import 'package:flutter/material.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/models/firestore/hike.dart';
import 'package:g7trailapp/navigation/nav.dart';
import 'package:g7trailapp/screens/destination.dart';
import 'package:g7trailapp/services/utility.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:html/parser.dart';

class HikeSummary extends StatefulWidget {
  HikeSummary({Key? key, required this.hike, required this.destinations, required this.viewContext}) : super(key: key);

  final Hike hike;
  final List<Destination> destinations;
  final BuildContext viewContext;

  @override
  State<HikeSummary> createState() => _HikeSummaryState();
}

class _HikeSummaryState extends State<HikeSummary> {
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
              widget.destinations.length < 1
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
                    ListView.builder(
                      itemCount: widget.destinations.length,
                      shrinkWrap: false,
                      padding: EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, i) {
                        var doc = parse(widget.destinations[i].destinationSummary);
                        var summaryParagraph = doc.getElementsByTagName('p').first.text;
                        summaryParagraph = summaryParagraph.isEmpty ? "<p></p>" : summaryParagraph;

                        return Column(
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                image: widget.destinations[i].imgURL != null
                                    ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(widget.destinations[i].imgURL!),
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
                                                return DestinationScreen(destination: widget.destinations[i]);
                                              }));
                                            });
                                          },
                                          title: Text(
                                            widget.destinations[i].destinationName.toUpperCase(),
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
                                                  return FluidNavigationBar(defaultTab: 1, highlightedDestination: widget.destinations[i]);
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
