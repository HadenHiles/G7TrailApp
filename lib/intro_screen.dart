import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/navigation/nav.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:g7trailapp/login.dart';
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

  Future<void> _onIntroEnd(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('intro_shown', true);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) {
        return user != null ? const FluidNavigationBar() : const Login();
      }),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 22.0, color: Color.fromRGBO(255, 255, 255, 0.9));

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 32.0,
        fontFamily: 'LGCafe',
        color: Colors.white,
      ),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color(0xffA9B7A7),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: const Color(0xffA9B7A7),
      pages: [
        PageViewModel(
          title: "Take it all in".toUpperCase(),
          body: "Appreciate all that the Group of Seven Lake Superior Trail has to offer",
          image: _buildImage('logo.png', MediaQuery.of(context).size.width * 0.7),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Learn about the trail's History".toUpperCase(),
          body: "There's so much interesting things to learn",
          image: _buildImage('logo.png', MediaQuery.of(context).size.width * 0.9),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Get notified when you reach key destinations".toUpperCase(),
          body: "Listen to trail stories, or look at the artwork and history from that destination",
          image: Icon(
            Icons.notifications_active_rounded,
            size: MediaQuery.of(context).size.width * 0.5,
            color: Colors.white,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Hike History".toUpperCase(),
          body: "Don't want to get distracted while you're hiking? Review your hikes when you get home to learn about interesting areas that you visited on your hike.",
          image: Icon(
            Icons.history_rounded,
            size: MediaQuery.of(context).size.width * 0.5,
            color: Colors.white,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Light or Dark theme?".toUpperCase(),
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
                              style: const TextStyle(
                                fontFamily: 'LGCafe',
                                fontSize: 24,
                                color: Colors.black54,
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.white),
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
                              style: const TextStyle(
                                fontFamily: 'LGCafe',
                                fontSize: 24,
                                color: Color.fromRGBO(255, 255, 255, 0.75),
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(const Color(0xff1A1A1A)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'You can change this later',
                      style: TextStyle(
                        fontFamily: 'LGCafe',
                        fontSize: 18,
                        color: Colors.white70,
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
            size: MediaQuery.of(context).size.width * 0.5,
            color: preferences.darkMode ? Colors.black : Colors.white,
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
        style: const TextStyle(
          fontFamily: 'LGCafe',
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      next: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
      ),
      done: Text(
        'Done'.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'LGCafe',
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb ? const EdgeInsets.all(12.0) : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xff0053B1),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Color(0xff899687),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
