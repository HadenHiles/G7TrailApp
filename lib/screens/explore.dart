import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/models/firestore/destination_image.dart';
import 'package:g7trailapp/models/firestore/file.dart';
import 'package:g7trailapp/screens/destination.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/utitlity/firebase_storage.dart';
import 'package:g7trailapp/utitlity/string_extension.dart';
import 'package:g7trailapp/widgets/screen_title.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Static variables
  final bool _nearEntryPoint = false; // TODO: make stateful when beacon functionality is introduced

  // State variables
  List<Destination> _easyDestinations = [];
  List<Destination> _moderateDestinations = [];
  List<Destination> _difficultDestinations = [];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "destination").get().then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        List<Destination> easy = [];
        List<Destination> moderate = [];
        List<Destination> difficult = [];
        for (var doc in snapshot.docs) {
          Destination d = Destination.fromSnapshot(doc);
          await _loadDestinationImage(d.images[0]).then((url) => d.imgURL = url);

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

          setState(() {
            _easyDestinations = easy;
            _moderateDestinations = moderate;
            _difficultDestinations = difficult;
          });
        }
      }
    });
  }

  Future<String> _loadDestinationImage(DestinationImage image) async {
    return await image.image.get().then((doc) async {
      File i = File.fromSnapshot(doc);
      return imageDownloadURL("/flamelink/media/sized/${i.sizes[1]['path']}/${i.file}").then((imgURL) {
        return imgURL;
      });
    });
  }

  @override
  Widget build(context) {
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
                color: Theme.of(context).backgroundColor,
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
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: 15, right: 0, bottom: 15, left: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    !_nearEntryPoint
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
                                      style: Theme.of(context).textTheme.headline4,
                                      textAlign: TextAlign.start,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "(Entry Point B)".toUpperCase(),
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 310,
                                child: ListView(
                                  padding: EdgeInsets.only(left: 10),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      child: GestureDetector(
                                        onTap: () {},
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
                                                    child: Image(
                                                      image: AssetImage("assets/images/destinations/peninsula-harbour-example.jpeg"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                title: AutoSizeText(
                                                  "Peninsula Harbour".toUpperCase(),
                                                  maxLines: 1,
                                                  maxFontSize: 22,
                                                  style: Theme.of(context).textTheme.headline5,
                                                ),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text("Easy", style: Theme.of(context).textTheme.bodyText1),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        top: 3,
                                                      ),
                                                      child: Text(
                                                        "4.5km",
                                                        style: Theme.of(context).textTheme.bodyText2,
                                                      ),
                                                    ),
                                                  ],
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
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(right: 15),
                                child: Divider(
                                  color: darken(Theme.of(context).colorScheme.background, 0.25),
                                ),
                              ),
                            ],
                          ),
                    SizedBox(height: 15),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        "Easy".toUpperCase(),
                        style: Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      height: 310,
                      child: ListView.builder(
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
                        color: darken(Theme.of(context).colorScheme.background, 0.25),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        "Moderate".toUpperCase(),
                        style: Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      height: 310,
                      child: ListView.builder(
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
                        color: darken(Theme.of(context).colorScheme.background, 0.25),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        "Difficult".toUpperCase(),
                        style: Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      height: 310,
                      child: ListView.builder(
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestination(Destination destination) {
    String title = destination.destinationName;
    String? imgURL = destination.imgURL;
    Widget trailing = Text(destination.difficulty.capitalize(), style: Theme.of(context).textTheme.bodyText1);
    Image img = imgURL != null ? Image(image: NetworkImage(imgURL)) : Image(image: AssetImage("/assets/images/app-icon.png"));

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
                  style: Theme.of(context).textTheme.headline5,
                ),
                trailing: trailing,
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
    );
  }
}
