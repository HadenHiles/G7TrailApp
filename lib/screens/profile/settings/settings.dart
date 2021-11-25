import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:g7trailapp/login.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/preferences.dart';
import 'package:g7trailapp/services/network_status_service.dart';
import 'package:g7trailapp/services/authentication/auth.dart';
import 'package:g7trailapp/screens/profile/settings/edit_profile.dart';
import 'package:g7trailapp/theme/preferences_state_notifier.dart';
import 'package:g7trailapp/widgets/basic_title.dart';
import 'package:g7trailapp/widgets/network_aware_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  // State settings values
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  //Loading counter value on start
  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _darkMode = (prefs.getBool('dark_mode') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<NetworkStatus>(
      create: (context) {
        return NetworkStatusService().networkStatusController.stream;
      },
      initialData: NetworkStatus.Online,
      child: NetworkAwareWidget(
        offlineChild: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              right: 0,
              bottom: 0,
              left: 0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/images/logo.png'),
                ),
                Text(
                  "Where's the wifi bud?".toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: "LGCafe",
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                const CircularProgressIndicator(
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
        onlineChild: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  collapsedHeight: 65,
                  expandedHeight: 65,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  floating: true,
                  pinned: true,
                  leading: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 28,
                      ),
                      onPressed: () {
                        navigatorKey.currentState!.pop();
                      },
                    ),
                  ),
                  flexibleSpace: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                    ),
                    child: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      titlePadding: null,
                      centerTitle: false,
                      title: const BasicTitle(title: "Settings"),
                      background: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                  actions: const [],
                ),
              ];
            },
            body: Stack(
              children: [
                SizedBox(
                  child: SettingsList(
                    backgroundColor: Theme.of(context).colorScheme.primaryVariant,
                    lightBackgroundColor: Theme.of(context).colorScheme.primaryVariant,
                    darkBackgroundColor: Theme.of(context).colorScheme.primaryVariant,
                    sections: [
                      SettingsSection(
                        title: 'General',
                        titleTextStyle: Theme.of(context).textTheme.headline6,
                        tiles: [
                          SettingsTile.switchTile(
                            titleTextStyle: Theme.of(context).textTheme.bodyText1,
                            title: 'Dark Mode',
                            leading: Icon(
                              Icons.brightness_2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            switchValue: _darkMode,
                            onToggle: (bool value) async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              setState(() {
                                _darkMode = !_darkMode;
                                prefs.setBool('dark_mode', _darkMode);
                              });

                              Provider.of<PreferencesStateNotifier>(context, listen: false).updateSettings(
                                Preferences(
                                  value,
                                  prefs.getString('fcm_token'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SettingsSection(
                        titleTextStyle: Theme.of(context).textTheme.headline6,
                        title: 'Account',
                        tiles: [
                          SettingsTile(
                            title: 'Edit Profile',
                            titleTextStyle: Theme.of(context).textTheme.bodyText1,
                            subtitleTextStyle: Theme.of(context).textTheme.bodyText2,
                            leading: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: (BuildContext context) {
                              navigatorKey.currentState!.push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const EditProfile();
                                  },
                                ),
                              );
                            },
                          ),
                          SettingsTile(
                            title: 'Logout',
                            titleTextStyle: TextStyle(
                              color: Colors.red,
                              fontSize: Theme.of(context).textTheme.bodyText1!.fontSize,
                            ),
                            subtitleTextStyle: Theme.of(context).textTheme.bodyText2,
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            onPressed: (BuildContext context) {
                              signOut();

                              navigatorKey.currentState!.pop();
                              navigatorKey.currentState!.pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.only(top: 0, bottom: 5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), //color of shadow
                          spreadRadius: 2, //spread radius
                          blurRadius: 10, // blur radius
                          offset: const Offset(0, 0), // changes position of shadow
                          //first paramerter of offset is left-right
                          //second parameter is top to down
                        ),
                      ],
                      color: Theme.of(context).colorScheme.primaryVariant,
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.github,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 16,
                            ),
                            TextButton(
                              child: Text(
                                "Developed by Haden Hiles".toLowerCase(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 16,
                                  fontFamily: "LGCafe",
                                ),
                              ),
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                              ),
                              onPressed: () async {
                                String link = "https://github.com/HadenHiles";
                                await canLaunch(link).then((can) {
                                  launch(link).catchError((err) {
                                    // ignore: avoid_print
                                    print(err);
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.all(0),
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.copyright,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 10,
                              ),
                              TextButton(
                                child: Text(
                                  "How To Hockey Inc.".toLowerCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 14,
                                    fontFamily: "LGCafe",
                                  ),
                                ),
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(const EdgeInsets.only(bottom: 2, left: 5)),
                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                ),
                                onPressed: () async {
                                  String link = "https://howtohockey.com";
                                  await canLaunch(link).then((can) {
                                    launch(link).catchError((err) {
                                      // ignore: avoid_print
                                      print(err);
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
