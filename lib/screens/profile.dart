// ignore_for_file: file_names
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g7trailapp/models/firestore/hike.dart';
import 'package:g7trailapp/screens/profile/hike_summary.dart';
import 'package:g7trailapp/screens/profile/login.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/screens/profile/settings/settings.dart';
import 'package:g7trailapp/services/utility.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Static variables
  final user = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UserProfile userProfile = UserProfile('', '', '', true, null);
  List<Hike> _hikes = [];

  @override
  void initState() {
    if (user != null && !user!.isAnonymous) {
      FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((uDoc) {
        setState(() {
          userProfile = UserProfile.fromSnapshot(uDoc);
        });
      });
    }

    _loadHikes();

    super.initState();
  }

  Future<void> _loadHikes() async {
    setState(() {
      _hikes.clear();
    });

    FirebaseFirestore.instance.collection('hikes').doc(user!.uid).collection('hikes').orderBy('date', descending: true).limit(25).get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<Hike> hikes = [];
        for (DocumentSnapshot d in snapshot.docs) {
          hikes.add(Hike.fromSnapshot(d));
        }

        setState(() {
          _hikes = hikes;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                title: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      user == null || user!.isAnonymous
                          ? Icon(
                              Icons.location_history_rounded,
                              size: 22,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : Container(
                              width: 30,
                              height: 30,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: UserAvatar(
                                  user: UserProfile(user!.displayName, user!.email, userProfile.photoUrl, true, preferences.fcmToken),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            ),
                      SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                        width: 140,
                        child: AutoSizeText(
                          "Your Hikes".toUpperCase(),
                          maxFontSize: Theme.of(context).textTheme.headlineSmall!.fontSize ?? 22,
                          minFontSize: 10,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                            fontFamily: Theme.of(context).textTheme.headlineSmall!.fontFamily,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            actions: [
              Container(
                width: 60,
                height: 60,
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: InkWell(
                  radius: 34,
                  child: Icon(
                    Icons.settings,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    size: 28,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return ProfileSettings(user: user);
                    }));
                  },
                ),
              ),
            ],
          ),
        ];
      },
      body: user == null || user!.isAnonymous
          ? Login(scaffoldKey: _scaffoldKey)
          : Container(
              child: RefreshIndicator(
                onRefresh: _loadHikes,
                child: ListView(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 15,
                          ),
                          child: Text(
                            "Past Hikes".toUpperCase(),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    _hikes.length < 1
                        ? Container(
                            padding: EdgeInsets.all(25),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No hikes yet",
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "Start a hike using the banner below.",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : _buildHikes(_hikes),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHikes(List<Hike> hikes) {
    List<Widget> hikeCards = [];
    for (Hike h in hikes) {
      hikeCards.add(_buildHike(h));
    }

    return Column(children: hikeCards);
  }

  Widget _buildHike(Hike hike) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      color: darken(Theme.of(context).colorScheme.primary, 0.001),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ListTile(
                  leading: SizedBox(
                    height: 30,
                    width: 30,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image(
                        image: AssetImage("assets/images/avatar.png"),
                      ),
                    ),
                  ),
                  title: Text(
                    (printWeekday(hike.date) + " Hike").toUpperCase(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: PopupMenuButton<String>(
                    // Callback that sets the selected popup menu item.
                    onSelected: (String value) {
                      if (value == "delete") {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              "Delete ${printWeekday(hike.date)} Hike?",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            content: Text("This cannot be undone."),
                            actions: [
                              TextButton(
                                onPressed: () => navigatorKey.currentState!.pop(),
                                child: new Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  FirebaseFirestore.instance.collection("hikes").doc(user!.uid).collection("hikes").doc(hike.reference!.id).delete().then((value) {
                                    navigatorKey.currentState!.pop();
                                    _loadHikes();
                                  });
                                },
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: "delete",
                        child: Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(
                    printDate(hike.date),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ListTile(
                  title: Text(
                    "Duration",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  trailing: Text(
                    hike.duration.inMinutes < 1
                        ? "< 01m"
                        : printDuration(
                            hike.duration,
                            false,
                          ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            /*
            // Hide the share hike button until web interface is implemented
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Share the hike
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Share Hike",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50),
                        primary: lighten(Theme.of(context).backgroundColor, 0.03),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        elevation: 2,
                        textStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            */
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        BuildContext mainContext = context;
                        // show the hike summary screen
                        _showHikeSummary(mainContext, hike);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Places Visited",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50),
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        elevation: 2,
                        textStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 18,
                        ),
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
  }

  void _showHikeSummary(BuildContext mainContext, Hike hike) {
    showModalBottomSheet(
      context: mainContext,
      builder: (context) {
        return SafeArea(
          top: true,
          bottom: true,
          child: Container(
            height: MediaQuery.of(mainContext).size.height - MediaQuery.of(mainContext).padding.top,
            color: Theme.of(mainContext).colorScheme.primary,
            child: SafeArea(
              child: Container(
                child: Column(
                  children: [
                    HikeSummary(hike: hike, viewContext: mainContext),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      enableDrag: true,
      isScrollControlled: true,
      isDismissible: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
