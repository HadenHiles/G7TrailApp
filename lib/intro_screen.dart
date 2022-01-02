import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:g7trailapp/navigation/nav.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:g7trailapp/models/firestore/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/theme/preferences_state_notifier.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  bool _darkMode = preferences.darkMode;
  Color _background = Colors.white;
  Color _titleColor = Color(0xff0053B1);
  Color _textColor = Color(0xff8c8c8c);
  Color _buttonColor = Color(0xff7FADF9);
  Color _buttonTextColor = Colors.white;
  Color _controlsBackground = Color(0xffF2F2F2);
  Color _controlsContrast = Color(0xffD5D5D5);
  Color _controlsActive = darken(Color(0xffA9B7A7), 0.2);

  List<WelcomeScreen> _screens = [];

  Future<void> _onIntroEnd(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('intro_shown', true);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) {
        return const FluidNavigationBar();
      }),
    );
  }

  Widget _buildImage(String assetName, [double height = 350]) {
    return Image.asset('assets/images/$assetName', height: height);
  }

  Future<void> _loadScreenContent() async {
    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "introductionScreen").orderBy('order', descending: false).get().then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        List<WelcomeScreen> screens = [];
        for (var doc in snapshot.docs) {
          screens.add(WelcomeScreen.fromSnapshot(doc));
        }

        setState(() {
          _screens = screens;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _loadScreenContent();
  }

  @override
  Widget build(BuildContext context) {
    if (!_darkMode) {
      _background = Colors.white;
      _titleColor = Color(0xff0053B1);
      _textColor = Color(0xff8c8c8c);
      _buttonColor = Color(0xff7FADF9);
      _buttonTextColor = Colors.white;
      _controlsBackground = Color(0xff7FADF9);
      _controlsContrast = darken(Color(0xff7FADF9), 0.1);
      _controlsActive = darken(Color(0xff7FADF9), 0.2);
    } else {
      _background = Color(0xff1A1A1A);
      _titleColor = Color(0xffF2F2F2);
      _textColor = Color(0xffF2f2f2);
      _buttonColor = Color(0xff7FADF9);
      _buttonTextColor = Colors.white;
      _controlsBackground = Color(0xff7FADF9);
      _controlsContrast = darken(Color(0xff7FADF9), 0.1);
      _controlsActive = darken(Color(0xff7FADF9), 0.2);
    }

    var bodyStyle = TextStyle(
      fontSize: 17,
      color: _textColor,
    );

    PageDecoration pageDecoration = PageDecoration(
      bodyFlex: 2,
      fullScreen: false,
      titleTextStyle: TextStyle(
        fontSize: 32.0,
        fontFamily: 'LGCafe',
        color: _titleColor,
      ),
      titlePadding: EdgeInsets.only(top: 40, bottom: 15),
      bodyAlignment: Alignment.topCenter,
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      pageColor: Colors.transparent,
      imagePadding: EdgeInsets.only(top: 100),
      imageAlignment: Alignment.center,
    );

    return Container(
      decoration: BoxDecoration(
        color: _background,
        image: DecorationImage(
          image: !_darkMode ? AssetImage("assets/images/treeline-sillouette.png") : AssetImage("assets/images/treeline-sillouette-on-dark.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: _screens.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            )
          : IntroductionScreen(
              key: introKey,
              globalBackgroundColor: Colors.transparent,
              pages: [
                PageViewModel(
                  title: "",
                  bodyWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: _buildImage('logo.png', MediaQuery.of(context).size.height * .6),
                      ),
                      // Text(
                      //   "Appreciate all that the Group of Seven Lake Superior Trail has to offer",
                      //   style: bodyStyle,
                      //   textAlign: TextAlign.center,
                      // ),
                    ],
                  ),
                  decoration: PageDecoration(
                    titleTextStyle: TextStyle(
                      fontSize: 32.0,
                      fontFamily: 'LGCafe',
                      color: _titleColor,
                    ),
                    bodyTextStyle: bodyStyle,
                    descriptionPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    pageColor: Colors.transparent,
                    imagePadding: EdgeInsets.zero,
                    imageAlignment: Alignment.topCenter,
                  ),
                ),
                PageViewModel(
                  title: _screens[0].title.toUpperCase(),
                  body: _screens[0].description,
                  image: Icon(
                    FontAwesomeIcons.route,
                    size: MediaQuery.of(context).size.width * 0.4,
                    color: _buttonColor,
                  ),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: _screens[1].title.toUpperCase(),
                  body: _screens[1].description,
                  image: Icon(
                    Icons.notifications_active_rounded,
                    size: MediaQuery.of(context).size.width * 0.45,
                    color: _buttonColor,
                  ),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: _screens[2].title.toUpperCase(),
                  body: _screens[2].description,
                  image: Icon(
                    FontAwesomeIcons.binoculars,
                    size: MediaQuery.of(context).size.width * 0.45,
                    color: _buttonColor,
                  ),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: _screens[3].title.toUpperCase(),
                  body: _screens[3].description,
                  image: Icon(
                    Icons.location_history,
                    size: MediaQuery.of(context).size.width * 0.45,
                    color: _buttonColor,
                  ),
                  decoration: pageDecoration,
                ),
                PageViewModel(
                  title: _screens[4].title.toUpperCase(),
                  bodyWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Transform.scale(
                                  scale: _darkMode ? 1 : 1.2,
                                  child: TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        _darkMode = false;
                                      });

                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setBool('dark_mode', false);
                                      preferences.darkMode = false;

                                      Provider.of<PreferencesStateNotifier>(context, listen: false).updateSettings(preferences);
                                    },
                                    child: Text(
                                      "Light".toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'LGCafe',
                                        fontSize: 24,
                                        color: _textColor,
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(darken(_background, 0.1)),
                                    ),
                                  ),
                                ),
                                Transform.scale(
                                  scale: _darkMode ? 1.2 : 1,
                                  child: TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        _darkMode = true;
                                      });

                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setBool('dark_mode', true);
                                      preferences.darkMode = true;

                                      Provider.of<PreferencesStateNotifier>(context, listen: false).updateSettings(preferences);
                                    },
                                    child: Text(
                                      "Dark".toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'LGCafe',
                                        fontSize: 24,
                                        color: _buttonTextColor,
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                        darken(_buttonColor, 0.1),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'You can change this later',
                              style: TextStyle(
                                fontFamily: 'LGCafe',
                                fontSize: 18,
                                color: _textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  image: Icon(
                    Icons.brightness_4,
                    size: MediaQuery.of(context).size.width * 0.45,
                    color: _buttonColor,
                  ),
                  decoration: pageDecoration,
                ),
              ],
              onDone: () => _onIntroEnd(context),
              //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
              showSkipButton: true,
              skipFlex: 0,
              nextFlex: 0,
              //rtl: true, // Display as right-to-left
              skip: Text(
                'Skip'.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'LGCafe',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _buttonTextColor,
                ),
              ),
              next: Icon(
                Icons.arrow_forward_ios,
                color: _buttonTextColor,
              ),
              done: Text(
                'Done'.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'LGCafe',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _buttonTextColor,
                ),
              ),
              curve: Curves.fastLinearToSlowEaseIn,
              controlsMargin: const EdgeInsets.all(16),
              controlsPadding: kIsWeb ? const EdgeInsets.all(12.0) : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
              dotsDecorator: DotsDecorator(
                size: Size(10.0, 10.0),
                activeColor: _controlsActive,
                color: _controlsContrast,
                activeSize: Size(22.0, 10.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
              dotsContainerDecorator: ShapeDecoration(
                color: _controlsBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
    );
  }
}
