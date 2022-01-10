import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/screens/destination/art.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:g7trailapp/utility/fullscreen_image.dart';
import 'package:simple_animations/stateless_animation/custom_animation.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({Key? key, required this.destination}) : super(key: key);

  final Destination destination;

  @override
  _DestinationScreenState createState() => _DestinationScreenState();
}

enum TtsState { playing, stopped, paused, continued }

class _DestinationScreenState extends State<DestinationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  late FlutterTts flutterTts;
  bool _autoplay = true;
  String? language;
  String? engine;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => Platform.isIOS;
  bool get isAndroid => Platform.isAndroid;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(false);

    await flutterTts.setLanguage("en-US");

    await flutterTts.setSpeechRate(rate);

    await flutterTts.setVolume(volume);

    await flutterTts.setPitch(pitch);

    await flutterTts.isLanguageAvailable("en-US");

    // iOS only
    await flutterTts.setSharedInstance(true);
    // Android only
    await flutterTts.setSilence(2);

    await flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});

    await flutterTts.isLanguageInstalled("en-AU");

    await flutterTts.areLanguagesInstalled(["en-AU", "en-US"]);

    await flutterTts.setQueueMode(1);

    await flutterTts.getMaxSpeechInputLength;
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: preferences.darkMode ? Theme.of(context).backgroundColor : Colors.white,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                navigatorKey.currentState!.pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.photo_camera_rounded),
              ),
              CustomAnimation<double>(
                control: CustomAnimationControl.mirror,
                tween: Tween(begin: 24.0, end: 30.0),
                duration: const Duration(milliseconds: 750),
                delay: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                startPosition: 0,
                animationStatusListener: (status) {
                  // print('status updated: $status');
                },
                builder: (context, child, value) {
                  return IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState!.openEndDrawer();
                    },
                    icon: Icon(Icons.audiotrack_rounded),
                    iconSize: value,
                  );
                },
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.secondary,
            title: Text(
              widget.destination.destinationName.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontFamily: Theme.of(context).textTheme.headline5!.fontFamily,
                fontSize: 22,
              ),
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(FontAwesomeIcons.binoculars),
                  text: "Scenery Guide".toUpperCase(),
                ),
                Tab(
                  icon: Icon(FontAwesomeIcons.paintBrush),
                  text: "Artwork".toUpperCase(),
                ),
                Tab(
                  icon: Icon(Icons.photo_album_rounded),
                  text: "Photos".toUpperCase(),
                ),
              ],
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontFamily: Theme.of(context).textTheme.headline5!.fontFamily,
              ),
            ),
          ),
          endDrawer: Drawer(
            child: SizedBox(
              height: double.infinity,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.destination.audio.length,
                itemBuilder: (context, i) {
                  return i == 0
                      ? Column(
                          children: [
                            DrawerHeader(
                              decoration: BoxDecoration(
                                color: Color(0xff7FADF9),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                                        child: Text(
                                          "Listen".toUpperCase(),
                                          style: TextStyle(
                                            color: Theme.of(context).backgroundColor,
                                            fontSize: 20,
                                            fontFamily: Theme.of(context).textTheme.headline1!.fontFamily,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Autoplay".toUpperCase(),
                                            style: TextStyle(
                                              color: Theme.of(context).backgroundColor,
                                              fontFamily: Theme.of(context).textTheme.bodyText2!.fontFamily,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Switch(
                                            value: _autoplay,
                                            onChanged: (value) {
                                              setState(() {
                                                _autoplay = value;
                                              });
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.play_arrow_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(widget.destination.audio[i].title.toUpperCase()),
                              onTap: () {
                                if (widget.destination.audio[i].file != null) {
                                  // Play audio file
                                } else if (widget.destination.audio[i].textToSpeech.isNotEmpty) {
                                  // Speak text - play/pause toggle
                                  if (ttsState != TtsState.playing) {
                                    _speak(widget.destination.audio[i].textToSpeech);
                                  } else {
                                    _pause();
                                  }
                                }
                              },
                            ),
                          ],
                        )
                      : ListTile(
                          leading: Icon(
                            Icons.play_arrow_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(widget.destination.audio[i].title.toUpperCase()),
                          onTap: () {
                            if (widget.destination.audio[i].file != null) {
                              // Play audio file
                            } else if (widget.destination.audio[i].textToSpeech.isNotEmpty) {
                              // Speak text - play/pause toggle
                              if (ttsState != TtsState.playing) {
                                _speak(widget.destination.audio[i].textToSpeech);
                              } else {
                                _pause();
                              }
                            }
                          },
                        );
                },
              ),
            ),
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Html(
                        data: widget.destination.destinationSummary,
                        style: preferences.darkMode ? HomeTheme.darkHtmlStyle : HomeTheme.lightHtmlStyle,
                      )
                    ],
                  ),
                ),
              ),
              ListView.builder(
                itemCount: widget.destination.art.length,
                itemBuilder: (context, i) {
                  return FutureBuilder(
                    future: loadFirestoreImage(widget.destination.art[i].image, 1),
                    builder: (context, snap) {
                      String imgUrl = snap.data.toString();
                      return !snap.hasData
                          ? Container()
                          : GestureDetector(
                              onTap: () {
                                navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) {
                                  return ArtScreen(art: widget.destination.art[i]);
                                }));
                              },
                              child: Card(
                                margin: EdgeInsets.all(0),
                                elevation: 1,
                                color: i % 2 != 0 ? Theme.of(context).cardTheme.color : (preferences.darkMode ? Theme.of(context).backgroundColor : Colors.white),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      height: 95,
                                      child: FittedBox(
                                        clipBehavior: Clip.antiAlias,
                                        fit: BoxFit.cover,
                                        child: CachedNetworkImage(
                                          imageUrl: imgUrl,
                                          placeholder: (context, _) {
                                            return SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: FittedBox(
                                                clipBehavior: Clip.antiAlias,
                                                fit: BoxFit.contain,
                                                child: Padding(
                                                  padding: EdgeInsets.all(50),
                                                  child: CircularProgressIndicator(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width - 120 - 25, // Image width + text padding
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 25),
                                              child: AutoSizeText(
                                                widget.destination.art[i].title.toUpperCase(),
                                                maxFontSize: Theme.of(context).textTheme.bodyText1!.fontSize ?? 14,
                                                minFontSize: 10,
                                                maxLines: 2,
                                                style: Theme.of(context).textTheme.bodyText1,
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
                    },
                  );
                },
              ),
              GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                itemCount: widget.destination.images.length,
                clipBehavior: Clip.antiAlias,
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                  childAspectRatio: 1 / 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (context, i) {
                  return FutureBuilder(
                    future: loadFirestoreImage(widget.destination.images[i].image, null),
                    builder: (context, snap) {
                      String imgUrl = snap.data.toString();

                      return !snap.hasData
                          ? Container()
                          : SizedBox(
                              width: 100,
                              height: 100,
                              child: ClipRRect(
                                child: ImageFullScreenWrapperWidget(
                                  dark: true,
                                  child: CachedNetworkImage(
                                    imageUrl: imgUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
