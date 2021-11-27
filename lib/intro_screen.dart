import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/navigation/nav.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:introduction_screen/introduction_screen.dart';
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
  Color _titleColor = Color(0xff1A1A1A);
  Color _textColor = Color(0xff8c8c8c);
  Color _buttonColor = Color(0xffA9B7A7);
  Color _buttonTextColor = Colors.white;
  Color _controlsBackground = Color(0xffF2F2F2);
  Color _controlsContrast = Color(0xffD5D5D5);
  Color _controlsActive = darken(Color(0xffA9B7A7), 0.2);

  Future<void> _onIntroEnd(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('intro_shown', true);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) {
        return const FluidNavigationBar();
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
    if (!_darkMode) {
      _background = Colors.white;
      _titleColor = Color(0xff1A1A1A);
      _textColor = Color(0xff8c8c8c);
      _buttonColor = Color(0xffA9B7A7);
      _buttonTextColor = Colors.white;
      _controlsBackground = Color(0xffA9B7A7);
      _controlsContrast = darken(Color(0xffA9B7A7), 0.1);
      _controlsActive = darken(Color(0xffA9B7A7), 0.2);
    } else {
      setState(() {
        _background = const Color(0xff1A1A1A);
        _titleColor = Color(0xffF2F2F2);
        _textColor = const Color(0xffF2f2f2);
        _buttonColor = Color(0xffA9B7A7);
        _buttonTextColor = Colors.white;
        _controlsBackground = darken(Color(0xffA9B7A7), 0.3);
        _controlsContrast = darken(Color(0xffA9B7A7), 0.4);
        _controlsActive = Color(0xffA9B7A7);
      });
    }

    var bodyStyle = TextStyle(
      fontSize: 20.0,
      color: _textColor,
    );

    PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 32.0,
        fontFamily: 'LGCafe',
        color: _titleColor,
      ),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      pageColor: _background,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: _background,
      pages: [
        PageViewModel(
          title: "",
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 25),
                child: _buildImage('logo.png', MediaQuery.of(context).size.width * .7),
              ),
              Text(
                "Appreciate all that the Group of Seven Lake Superior Trail has to offer",
                style: bodyStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Learn while you hike".toUpperCase(),
          body: "There's so many interesting things to learn about the trail's history",
          image: Icon(
            Icons.school_rounded,
            size: MediaQuery.of(context).size.width * 0.5,
            color: _buttonColor,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Get notified when you reach key destinations".toUpperCase(),
          body: "Listen to trail stories, or look at the artwork and history from that destination",
          image: Icon(
            Icons.notifications_active_rounded,
            size: MediaQuery.of(context).size.width * 0.5,
            color: _buttonColor,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "My Hikes".toUpperCase(),
          body: "Don't want to get distracted while you're hiking? Review your hikes when you get home to learn about interesting areas that you visited on your hike.",
          image: Icon(
            Icons.location_history,
            size: MediaQuery.of(context).size.width * 0.5,
            color: _buttonColor,
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
            size: MediaQuery.of(context).size.width * 0.5,
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
    );
  }
}
