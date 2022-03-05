// ignore_for_file: file_names
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g7trailapp/screens/profile/login.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/screens/profile/settings/settings.dart';
import 'package:g7trailapp/widgets/screen_title.dart';
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
                title: ScreenTitle(icon: Icons.location_history, title: "My Hikes"),
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
      body: user == null
          ? Login(scaffoldKey: _scaffoldKey)
          : Container(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                  child: SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: UserAvatar(
                                      user: UserProfile(user!.displayName, user!.email, userProfile.photoUrl, true, preferences.fcmToken),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: (MediaQuery.of(context).size.width - 100) * 0.6,
                                child: StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: const [
                                          Center(
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      UserProfile userProfile = UserProfile.fromSnapshot(snapshot.data);

                                      return SizedBox(
                                        width: (MediaQuery.of(context).size.width - 100) * 0.5,
                                        child: AutoSizeText(
                                          userProfile.displayName!,
                                          maxLines: 1,
                                          maxFontSize: 22,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).textTheme.bodyText1!.color,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
