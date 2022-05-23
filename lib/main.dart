import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:g7trailapp/intro_screen.dart';
import 'package:g7trailapp/models/preferences.dart';
import 'package:g7trailapp/navigation/nav.dart';
import 'package:g7trailapp/services/authentication/auth.dart';
import 'package:g7trailapp/services/beacon_ranging_service.dart';
import 'package:g7trailapp/services/notification_service.dart';
import 'package:g7trailapp/services/session.dart';
import 'package:g7trailapp/theme/preferences_state_notifier.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

import 'firebase_options.dart';

// Setup a navigation key so that we can navigate without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global variables
final user = FirebaseAuth.instance.currentUser;
Preferences preferences = Preferences(false, true, true, null);
final sessionService = SessionService();
bool introShown = false;
late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  // Initialize the connection to our firebase project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final appleSignInAvailable = await AppleSignInAvailable.check();

  // Load user preferences
  prefs = await SharedPreferences.getInstance();
  preferences = Preferences(
    prefs.getBool('dark_mode') ?? ThemeMode.system == ThemeMode.dark,
    prefs.getBool('beacon_found_alert') ?? true,
    prefs.getBool('auto_play_audio') ?? true,
    prefs.getString('fcm_token'),
  );

  introShown = prefs.getBool('intro_shown') == null ? false : true;

  /**
   * Sign in anonymously if there is no current firebase user
   * Setup firebase messaging if they are signed in
   */
  FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  } else {
    // Firebase messaging setup
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    // Only relevant for IOS
    // ignore: unused_local_variable
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Get the user's FCM token
    firebaseMessaging.getToken().then((token) {
      if (preferences.fcmToken != token) {
        prefs.setString('fcm_token', token!); // Svae the fcm token to local storage (will save to firestore after user authenticates)
      }

      print("FCM token: $token"); // Print the Token in Console
    });

    // Listen for firebase messages
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    // Listen for message clicks
    FirebaseMessaging.onMessageOpenedApp.listen(_messageClickHandler);
  }

  runApp(
    Provider<AppleSignInAvailable>.value(
      value: appleSignInAvailable,
      child: ChangeNotifierProvider<PreferencesStateNotifier>(
        create: (_) => PreferencesStateNotifier(),
        child: ChangeNotifierProvider<BeaconRangingService>(
          create: (_) => BeaconRangingService(),
          child: const Home(),
        ),
      ),
    ),
  );
}

/*
 * Called when a background message is sent from firebase cloud messaging
 */
Future<void> _messageHandler(RemoteMessage message) async {
  // print('background message ${message.notification!.body}');
}

Future<void> _messageClickHandler(RemoteMessage message) async {
  // print('Background message clicked!');
}

// Request permissions for iBeacon functionality. See https://pub.dev/packages/flutter_beacon#how-to
Future<void> initializeBeaconPermissions() async {
  try {
    // if you want to manage manual checking about the required permissions
    // await flutterBeacon.initializeScanning;

    // or if you want to include automatic checking permission
    await flutterBeacon.initializeAndCheckScanning;
  } on PlatformException catch (e) {
    // library failed to initialize, check code and message
    log(e.message ?? "There was an error requesting bluetooth beacon location permissions", error: e);
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Lock device orientation to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    FirebaseAnalytics analytics = FirebaseAnalytics.instanceFor(app: Firebase.apps.first);

    return Consumer<PreferencesStateNotifier>(
      builder: (context, settingsState, child) {
        preferences = settingsState.prefs;

        return OverlaySupport(
          child: MaterialApp(
            title: 'Group of Seven Lake Superior Trail',
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: preferences.darkMode ? HomeTheme.darkTheme : HomeTheme.lightTheme,
            darkTheme: HomeTheme.darkTheme,
            themeMode: preferences.darkMode ? ThemeMode.dark : ThemeMode.system,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            home: !introShown ? const IntroScreen() : const FluidNavigationBar(),
          ),
        );
      },
    );
  }
}
