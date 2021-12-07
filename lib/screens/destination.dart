import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:g7trailapp/main.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({Key? key}) : super(key: key);

  @override
  _DestinationScreenState createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              IconButton(
                onPressed: () {
                  _scaffoldKey.currentState!.openEndDrawer();
                },
                icon: Icon(Icons.audiotrack_rounded),
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.secondary,
            title: Text(
              "Pic Island".toUpperCase(),
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
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xff7FADF9),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                  title: Text('Pic Island discovery'.toUpperCase()),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.play_arrow_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text('Painting story'.toUpperCase()),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Card(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: (MediaQuery.of(context).size.width * 0.9) * .73,
                                  child: FittedBox(
                                    clipBehavior: Clip.antiAlias,
                                    fit: BoxFit.cover,
                                    child: Image(
                                      image: AssetImage("assets/images/destinations/pic-island-example.jpeg"),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Card(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: (MediaQuery.of(context).size.width * 0.9) * .73,
                                  child: FittedBox(
                                    clipBehavior: Clip.antiAlias,
                                    fit: BoxFit.cover,
                                    child: Image(
                                      image: AssetImage("assets/images/destinations/pic-island-example.jpeg"),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  padding: EdgeInsets.all(5),
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 0,
                  crossAxisCount: 3,
                  children: const [
                    Image(
                      image: AssetImage("assets/images/destinations/pic-island-example.jpeg"),
                    ),
                    Image(
                      image: AssetImage("assets/images/destinations/painters-peak-example.jpg"),
                    ),
                    Image(
                      image: AssetImage("assets/images/destinations/peninsula-harbour-example.jpeg"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
