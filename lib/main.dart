import 'dart:developer';
import 'dart:math' as math;
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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:workmanager/workmanager.dart';

// Setup a navigation key so that we can navigate without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global variables
final user = FirebaseAuth.instance.currentUser;
Preferences preferences = Preferences(false, true, true, null);
final sessionService = SessionService();
bool introShown = false;

// Setup dependency injection using get_it package
final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  // Initialize the connection to our firebase project
  await Firebase.initializeApp();
  final appleSignInAvailable = await AppleSignInAvailable.check();

  getIt.registerSingleton<FlutterBeacon>(flutterBeacon);

  // Load user preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
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

// Beacon Monitoring background dispatcher
const rescheduledTaskKey = "trailBeaconTask";
const failedTaskKey = "failedBeaconTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final getIt = GetIt.instance;
      getIt.registerSingleton<FlutterBeacon>(flutterBeacon);

      // Start monitoring for beacons
      dynamic _streamMonitoring;
      _streamMonitoring = getIt<FlutterBeacon>().monitoring(<Region>[
        Region(
          identifier: "Group of Seven Lake Superior Trail",
          proximityUUID: 'f7826da6-4fa2-4e98-8024-bc5b71e0893e',
        )
      ]).listen((MonitoringResult result) {
        // result contains a region, event type and event state
        log("Beacon found: " + result.region.identifier + ":" + result.region.major.toString());
        NotificationService().notify(result.region.major!, "Trail Beacon Found", "Tap to learn more!");
      });

      Future.delayed(Duration(seconds: 10)).then((value) => _streamMonitoring.cancel());

      log("\n\n Workmanager called \n\n");
    } catch (e) {
      log("Workmanager exception: \n\n" + e.toString());
    }

    final key = inputData!['key']!;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('unique-$key')) {
      print('has been running before, task is successful');
      return true;
    } else {
      await prefs.setBool('unique-$key', true);
      print('reschedule task');
      return false;
    }
  });
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

    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    Workmanager().registerOneOffTask(
      "1-beaconMonitorScan",
      rescheduledTaskKey,
      // constraints: Constraints(
      //   networkType: NetworkType.not_required,
      //   requiresBatteryNotLow: false,
      //   requiresCharging: false,
      //   requiresDeviceIdle: false, // TODO: set this to true?
      //   requiresStorageNotLow: false,
      // ),
      inputData: <String, dynamic>{
        'key': math.Random().nextInt(64000),
      },
    );

    return Consumer<PreferencesStateNotifier>(
      builder: (context, settingsState, child) {
        preferences = settingsState.prefs;

        return MaterialApp(
          title: 'Group of Seven Lake Superior Trail',
          navigatorKey: navigatorKey,
          theme: preferences.darkMode ? HomeTheme.darkTheme : HomeTheme.lightTheme,
          darkTheme: HomeTheme.darkTheme,
          themeMode: preferences.darkMode ? ThemeMode.dark : ThemeMode.system,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          home: !introShown ? const IntroScreen() : const FluidNavigationBar(),
        );
      },
    );
  }
}
