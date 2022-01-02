import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:simple_animations/stateless_animation/custom_animation.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({Key? key, required this.destination}) : super(key: key);

  final Destination destination;

  @override
  _DestinationScreenState createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _autoplay = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                navigatorKey.currentState!.pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.photo_camera_rounded),
              ),
              CustomAnimation<double>(
                control: CustomAnimationControl.mirror,
                tween: Tween(begin: 24.0, end: 30.0),
                duration: const Duration(milliseconds: 750),
                delay: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                startPosition: 0,
                animationStatusListener: (status) {
                  // print('status updated: $status');
                },
                builder: (context, child, value) {
                  return IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState!.openEndDrawer();
                    },
                    icon: Icon(Icons.audiotrack_rounded),
                    iconSize: value,
                  );
                },
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.secondary,
            title: Text(
              widget.destination.destinationName.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontFamily: Theme.of(context).textTheme.headline5!.fontFamily,
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
                fontFamily: Theme.of(context).textTheme.headline5!.fontFamily,
              ),
            ),
          ),
          endDrawer: Drawer(
            child: SizedBox(
              height: double.maxFinite,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.destination.audio.length,
                itemBuilder: (context, i) {
                  return i == 0
                      ? Column(
                          children: [
                            DrawerHeader(
                              decoration: BoxDecoration(
                                color: Color(0xff7FADF9),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                                        child: Text(
                                          "Listen".toUpperCase(),
                                          style: TextStyle(
                                            color: Theme.of(context).backgroundColor,
                                            fontSize: 20,
                                            fontFamily: Theme.of(context).textTheme.headline1!.fontFamily,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Autoplay".toUpperCase(),
                                            style: TextStyle(
                                              color: Theme.of(context).backgroundColor,
                                              fontFamily: Theme.of(context).textTheme.bodyText2!.fontFamily,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Switch(
                                            value: _autoplay,
                                            onChanged: (value) {
                                              setState(() {
                                                _autoplay = value;
                                              });
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              leading: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: Text(widget.destination.audio[i].title.toUpperCase()),
                              onTap: () {
                                // Update the state of the app.
                                // ...
                              },
                            ),
                          ],
                        )
                      : ListTile(
                          leading: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.play_arrow_rounded,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: Text(widget.destination.audio[i].title.toUpperCase()),
                          onTap: () {
                            // Update the state of the app.
                            // ...
                          },
                        );
                },
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
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                itemCount: widget.destination.art.length,
                itemBuilder: (context, i) {
                  return FutureBuilder(
                    future: loadFirestoreImage(widget.destination.art[i].image),
                    builder: (context, snap) {
                      String imgUrl = snap.data.toString();
                      return !snap.hasData
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: (MediaQuery.of(context).size.width) * .73,
                              child: FittedBox(
                                clipBehavior: Clip.antiAlias,
                                fit: BoxFit.contain,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            )
                          : Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: (MediaQuery.of(context).size.width) * .73,
                                      child: FittedBox(
                                        clipBehavior: Clip.antiAlias,
                                        fit: BoxFit.cover,
                                        child: CachedNetworkImage(
                                          imageUrl: imgUrl,
                                          placeholder: (context, _) {
                                            return SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: FittedBox(
                                                clipBehavior: Clip.antiAlias,
                                                fit: BoxFit.contain,
                                                child: CircularProgressIndicator(
                                                  color: Theme.of(context).colorScheme.secondary,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              color: Theme.of(context).colorScheme.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 0,
                              margin: EdgeInsets.only(top: 10, right: 10),
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
                    future: loadFirestoreImage(widget.destination.images[i].image),
                    builder: (context, snap) {
                      String imgUrl = snap.data.toString();

                      return !snap.hasData
                          ? Container()
                          : Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: CachedNetworkImageProvider(imgUrl),
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
