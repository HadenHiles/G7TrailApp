import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/navigation/nav.dart';
import 'package:g7trailapp/screens/destination/art.dart';
import 'package:g7trailapp/screens/destination/street_view.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:g7trailapp/utility/fullscreen_image.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({Key? key, required this.destination}) : super(key: key);

  final Destination destination;

  @override
  _DestinationScreenState createState() => _DestinationScreenState();
}

enum TtsState { playing, stopped, paused, continued }

class _DestinationScreenState extends State<DestinationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  initState() {
    super.initState();
  }

  // Future _pauseTTS() async {
  //   var result = await _flutterTTS.pause();
  //   if (result == 1) setState(() => ttsState = TtsState.paused);
  // }
  // END TTS FUNCTIONS

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: preferences.darkMode ? Theme.of(context).colorScheme.surface : Colors.white,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                navigatorKey.currentState!.pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
            actions: [
              widget.destination.panoId.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) {
                          return DestinationPanoView(destination: widget.destination);
                        }));
                      },
                      icon: Icon(Icons.streetview_rounded),
                    )
                  : Container(),
              IconButton(
                onPressed: () {
                  navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) {
                    return FluidNavigationBar(defaultTab: 1, highlightedDestination: widget.destination);
                  }));
                },
                icon: Icon(Icons.location_on),
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.secondary,
            title: Text(
              widget.destination.destinationName.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontFamily: Theme.of(context).textTheme.headlineSmall!.fontFamily,
                fontSize: 22,
              ),
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(FontAwesomeIcons.binoculars),
                  text: "Scenery Guide".toUpperCase(),
                ),
                Tab(
                  icon: Icon(FontAwesomeIcons.paintBrush),
                  text: "Artwork".toUpperCase(),
                ),
                Tab(
                  icon: Icon(Icons.photo_album_rounded),
                  text: "Photos".toUpperCase(),
                ),
              ],
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontFamily: Theme.of(context).textTheme.headlineSmall!.fontFamily,
              ),
            ),
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Html(
                        data: widget.destination.destinationSummary,
                        style: preferences.darkMode ? HomeTheme.darkHtmlStyle : HomeTheme.lightHtmlStyle,
                      )
                    ],
                  ),
                ),
              ),
              ListView.builder(
                itemCount: widget.destination.art.length,
                itemBuilder: (context, i) {
                  return FutureBuilder(
                    future: loadFirestoreImage(widget.destination.art[i].image, 1),
                    builder: (context, snap) {
                      String imgUrl = snap.data.toString();
                      return !snap.hasData
                          ? Container()
                          : GestureDetector(
                              onTap: () {
                                navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) {
                                  return ArtScreen(art: widget.destination.art[i]);
                                }));
                              },
                              child: Card(
                                margin: EdgeInsets.all(0),
                                elevation: 1,
                                color: i % 2 != 0 ? Theme.of(context).cardTheme.color : (preferences.darkMode ? Theme.of(context).colorScheme.surface : Colors.white),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      height: 95,
                                      child: FittedBox(
                                        clipBehavior: Clip.antiAlias,
                                        fit: BoxFit.cover,
                                        child: CachedNetworkImage(
                                          imageUrl: imgUrl,
                                          placeholder: (context, _) {
                                            return SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: FittedBox(
                                                clipBehavior: Clip.antiAlias,
                                                fit: BoxFit.contain,
                                                child: Padding(
                                                  padding: EdgeInsets.all(50),
                                                  child: CircularProgressIndicator(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width - 120 - 25, // Image width + text padding
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 25),
                                              child: AutoSizeText(
                                                widget.destination.art[i].title.toUpperCase(),
                                                maxFontSize: Theme.of(context).textTheme.bodyLarge!.fontSize ?? 14,
                                                minFontSize: 10,
                                                maxLines: 2,
                                                style: Theme.of(context).textTheme.bodyLarge,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                    },
                  );
                },
              ),
              GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                itemCount: widget.destination.images.length,
                clipBehavior: Clip.antiAlias,
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                  childAspectRatio: 1 / 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (context, i) {
                  return FutureBuilder(
                    future: loadFirestoreImage(widget.destination.images[i].image, null),
                    builder: (context, snap) {
                      String imgUrl = snap.data.toString();

                      return !snap.hasData
                          ? Container()
                          : SizedBox(
                              width: 100,
                              height: 100,
                              child: ClipRRect(
                                child: ImageFullScreenWrapperWidget(
                                  dark: true,
                                  child: CachedNetworkImage(
                                    imageUrl: imgUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
