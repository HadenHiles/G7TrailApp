import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:g7trailapp/navigation/nav.dart';
import 'package:g7trailapp/screens/explore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/preferences.dart';
import 'package:g7trailapp/services/network_status_service.dart';
import 'package:g7trailapp/services/authentication/auth.dart';
import 'package:g7trailapp/theme/preferences_state_notifier.dart';
import 'package:g7trailapp/widgets/screen_title.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key, required this.user}) : super(key: key);

  final User? user;

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  // State settings values
  bool _darkMode = false;
  bool _beaconFoundAlert = true;

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
      _beaconFoundAlert = (prefs.getBool('beacon_found_alert') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<NetworkStatus>(
      create: (context) {
        return NetworkStatusService().networkStatusController.stream;
      },
      initialData: NetworkStatus.Online,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                collapsedHeight: 65,
                expandedHeight: 65,
                floating: true,
                pinned: true,
                leading: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      size: 28,
                    ),
                    onPressed: () {
                      navigatorKey.currentState!.pop();
                    },
                  ),
                ),
                flexibleSpace: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: FlexibleSpaceBar(
                    collapseMode: CollapseMode.none,
                    titlePadding: EdgeInsets.only(top: 25, left: 50),
                    centerTitle: false,
                    title: const ScreenTitle(title: "Settings"),
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
                  sections: [
                    SettingsSection(
                      title: Text(
                        'Preferences',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      tiles: [
                        SettingsTile.switchTile(
                          title: Text(
                            'Dark Mode',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          leading: Icon(
                            Icons.brightness_2,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          initialValue: _darkMode,
                          onToggle: (bool value) async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            setState(() {
                              _darkMode = !_darkMode;
                              prefs.setBool('dark_mode', _darkMode);
                            });

                            Provider.of<PreferencesStateNotifier>(context, listen: false).updateSettings(
                              Preferences(
                                value,
                                _beaconFoundAlert,
                                prefs.getString('fcm_token'),
                              ),
                            );
                          },
                        ),
                        SettingsTile.switchTile(
                          title: Text(
                            'Vibrate when near a beacon',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          description: Text(
                            '(while app is open)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          leading: Icon(
                            Icons.vibration_rounded,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          initialValue: _beaconFoundAlert,
                          onToggle: (bool value) async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            setState(() {
                              _beaconFoundAlert = !_beaconFoundAlert;
                              prefs.setBool('beacon_found_alert', _beaconFoundAlert);
                            });

                            Provider.of<PreferencesStateNotifier>(context, listen: false).updateSettings(
                              Preferences(
                                _darkMode,
                                value,
                                prefs.getString('fcm_token'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: Text(
                        'Account',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      tiles: [
                        SettingsTile(
                          title: Row(
                            children: [
                              Text(
                                'Delete Account',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: RotatedBox(
                                  quarterTurns: 2,
                                  child: Icon(
                                    Icons.info_outlined,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          leading: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: (BuildContext context) {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text(
                                    "Are you absolutely sure you want to delete your account?",
                                    style: TextStyle(
                                      fontFamily: 'NovecentoSans',
                                      fontSize: 24,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "All of your data will be lost, and there is no undoing this action. The app will close upon continuing with deletion.",
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(
                                        "Cancel".toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'NovecentoSans',
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        FirebaseAuth.instance.currentUser!.delete().then((_) {
                                          navigatorKey.currentState!.pop();
                                          navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (_) {
                                            return const ExploreScreen();
                                          }));

                                          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                                        }).onError((FirebaseAuthException error, stackTrace) {
                                          String msg = error.code == "requires-recent-login" ? "This action requires a recent login, please logout and try again." : "Error deleting account, please email info.g7trail@gmail.com for assistance";
                                          Fluttertoast.showToast(
                                            msg: msg,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Theme.of(context).cardTheme.color,
                                            textColor: Theme.of(context).colorScheme.onPrimary,
                                            fontSize: 16.0,
                                          );
                                        });
                                      },
                                      child: Text(
                                        "Delete Account".toUpperCase(),
                                        style: TextStyle(fontFamily: 'NovecentoSans', color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        user == null
                            ? SettingsTile(
                                title: Text(
                                  'Sign In',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                leading: Icon(
                                  Icons.login,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                ),
                                onPressed: (BuildContext context) {
                                  navigatorKey.currentState!.pop();
                                },
                              )
                            : SettingsTile(
                                title: Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                  ),
                                ),
                                leading: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                onPressed: (BuildContext context) {
                                  signOut();

                                  navigatorKey.currentState!.pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return FluidNavigationBar(defaultTab: 2);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ],
                    )
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
                    color: Theme.of(context).colorScheme.primaryContainer,
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
                            size: 14,
                          ),
                          TextButton(
                            child: Text(
                              "Developed by Haden Hiles",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 14,
                                fontFamily: "LGCafe",
                              ),
                            ),
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
                              backgroundColor: WidgetStateProperty.all(Colors.transparent),
                            ),
                            onPressed: () async {
                              Uri link = Uri(scheme: "https", host: "github.com", path: "HadenHiles");
                              await canLaunchUrl(link).then((can) {
                                launchUrl(link).catchError((err) {
                                  print(err);
                                  return false;
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
                                "Group of Seven Lake Superior Trail",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 14,
                                  fontFamily: "LGCafe",
                                ),
                              ),
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(const EdgeInsets.only(bottom: 2, left: 5)),
                                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                              ),
                              onPressed: () async {
                                Uri link = Uri(scheme: "https", host: "www.groupofseventrail.com");
                                await canLaunchUrl(link).then((can) {
                                  launchUrl(link).catchError((err) {
                                    print(err);
                                    return false;
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
    );
  }
}
