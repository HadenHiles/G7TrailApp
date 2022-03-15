// ignore_for_file: file_names
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    if (user != null && !user!.isAnonymous) {
      FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((uDoc) {
        setState(() {
          userProfile = UserProfile.fromSnapshot(uDoc);
        });
      });
    }

    super.initState();
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
                color: Theme.of(context).backgroundColor,
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
                          maxFontSize: Theme.of(context).textTheme.headline5!.fontSize ?? 22,
                          minFontSize: 10,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.headline5!.fontSize,
                            fontFamily: Theme.of(context).textTheme.headline5!.fontFamily,
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
                    color: Theme.of(context).textTheme.bodyText1!.color,
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
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ],
                  ),
                  _buildPastHike(),
                  _buildPastHike(),
                  _buildPastHike(),
                  SizedBox(height: 15),
                ],
              ),
            ),
    );
  }

  // TODO: Add params for hike data
  Widget _buildPastHike() {
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
                    "Saturday Hike".toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.more_vert_rounded,
                    ),
                    onPressed: () {},
                  ),
                ),
                ListTile(
                  title: Text(
                    printDate(DateTime(2022, 03, 12)),
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                ListTile(
                  title: Text(
                    "Duration",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  trailing: Text(
                    printDuration(
                      Duration(minutes: 78),
                      false,
                    ),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
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
                            "View Summary",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50),
                        primary: Theme.of(context).primaryColor,
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

  @override
  void dispose() {
    super.dispose();
  }
}
