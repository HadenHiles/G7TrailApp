// ignore_for_file: avoid_print, file_names

import 'package:flutter_html/flutter_html.dart';
import 'package:g7trailapp/models/firestore/privacy_policy.dart';
import 'package:g7trailapp/navigation/nav.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:the_apple_sign_in/scope.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/services/authentication/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:g7trailapp/services/bootstrap.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Auth variables
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // static variables
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _forgotPasswordEmail = TextEditingController();
  final TextEditingController _signInEmail = TextEditingController();
  final TextEditingController _signInPass = TextEditingController();
  final TextEditingController _signUpEmail = TextEditingController();
  final TextEditingController _signUpPass = TextEditingController();
  final TextEditingController _signUpConfirmPass = TextEditingController();

  // State variables
  bool _hidePassword = true;
  bool? _termsAccepted = false;
  String? _policyText = "Your login information will only be used for the purposes of authenticating you within this app.";
  String _policyLabel = "Terms & Conditions";

  @override
  void initState() {
    initTerms();
    super.initState();
  }

  Future<void> initTerms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('terms_accepted') == null) {
      prefs.setBool('terms_accepted', false);
    } else {
      bool? termsAccepted = prefs.getBool('terms_accepted');

      setState(() {
        _termsAccepted = termsAccepted;
      });
    }

    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "privacyPolicy").limit(1).get().then((snapshot) async {
      PrivacyPolicy policy = PrivacyPolicy.fromSnapshot(snapshot.docs[0]);
      setState(() {
        _policyText = policy.text ?? _policyText;
        _policyLabel = policy.label ?? _policyLabel;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appleSignInAvailable = Provider.of<AppleSignInAvailable>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * .02),
                      child: Text(
                        "Sign in to save your hikes & share them with friends.",
                        style: TextStyle(
                          fontFamily: "LGCafe",
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 300,
                      child: SignInButton(
                        Buttons.Google,
                        onPressed: () {
                          if (_termsAccepted ?? false) {
                            socialSignIn(context, 'google', (error) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Theme.of(context).cardTheme.color,
                                  content: Text(
                                    error,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 10),
                                  action: SnackBarAction(
                                    label: "Dismiss",
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    },
                                  ),
                                ),
                              );
                            });
                          } else {
                            _showPolicyDialog();
                          }
                        },
                      ),
                    ),
                    !appleSignInAvailable.isAvailable
                        ? Container()
                        : Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: SizedBox(
                              height: 50,
                              width: 300,
                              child: SignInButton(
                                Buttons.AppleDark,
                                onPressed: () {
                                  if (_termsAccepted ?? false) {
                                    socialSignIn(context, 'apple', (error) {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Theme.of(context).cardTheme.color,
                                          content: Text(
                                            error,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 10),
                                          action: SnackBarAction(
                                            label: "Dismiss",
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            },
                                          ),
                                        ),
                                      );
                                    });
                                  } else {
                                    _showPolicyDialog();
                                  }
                                },
                              ),
                            ),
                          ),
                    const Divider(
                      color: Colors.transparent,
                      height: 5,
                    ),
                    SizedBox(
                      width: 220,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                              bottom: 15,
                            ),
                            child: Text(
                              'Or'.toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 15),
                              child: Icon(
                                Icons.email,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 50),
                              child: Text(
                                'Sign in with Email',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          if (_termsAccepted ?? false) {
                            setState(() {
                              _hidePassword = true;
                            });

                            showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  contentPadding: const EdgeInsets.all(25),
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            SizedBox(
                                              height: 50,
                                              child: Image.asset(
                                                'assets/images/logo-small.png',
                                                width: 120,
                                              ),
                                            ),
                                            const Text(
                                              'SIGN IN',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                        Form(
                                          key: _signInFormKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  controller: _signInEmail,
                                                  decoration: InputDecoration(
                                                    labelText: 'Email',
                                                    labelStyle: TextStyle(
                                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                                    ),
                                                    hintText: 'Enter your email',
                                                    hintStyle: TextStyle(
                                                      color: Theme.of(context).cardTheme.color,
                                                    ),
                                                  ),
                                                  keyboardType: TextInputType.emailAddress,
                                                  validator: (String? value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter your email';
                                                    } else if (!validEmail(value)) {
                                                      return 'Invalid email address';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  controller: _signInPass,
                                                  obscureText: _hidePassword,
                                                  decoration: InputDecoration(
                                                    labelText: 'Password',
                                                    labelStyle: TextStyle(
                                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                                    ),
                                                    hintText: 'Enter your password',
                                                    hintStyle: TextStyle(
                                                      color: Theme.of(context).cardTheme.color,
                                                    ),
                                                  ),
                                                  keyboardType: TextInputType.visiblePassword,
                                                  validator: (String? value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter a password';
                                                    }

                                                    return null;
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      foregroundColor: Colors.white,
                                                      backgroundColor: Theme.of(context).primaryColor,
                                                    ),
                                                    child: const Text("Sign in"),
                                                    onPressed: () async {
                                                      if (_signInFormKey.currentState!.validate()) {
                                                        _signInFormKey.currentState!.save();

                                                        signIn(
                                                            context,
                                                            AuthAttempt(
                                                              _signInEmail.text,
                                                              _signInPass.text,
                                                            ), (error) async {
                                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              backgroundColor: Theme.of(context).cardTheme.color,
                                                              content: Text(
                                                                error,
                                                                style: TextStyle(
                                                                  color: Theme.of(context).colorScheme.onPrimary,
                                                                ),
                                                              ),
                                                              duration: const Duration(seconds: 10),
                                                              action: SnackBarAction(
                                                                label: "Dismiss",
                                                                onPressed: () {
                                                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: ElevatedButton(
                                                  child: const Text("Forgot password?"),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return SimpleDialog(
                                                          contentPadding: const EdgeInsets.all(25),
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  mainAxisSize: MainAxisSize.max,
                                                                  children: [
                                                                    SizedBox(
                                                                      height: 50,
                                                                      child: Image.asset(
                                                                        'assets/images/logo-small.png',
                                                                        width: 120,
                                                                      ),
                                                                    ),
                                                                    const Text(
                                                                      'Forgot Password',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Form(
                                                                  key: _forgotPasswordFormKey,
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: TextFormField(
                                                                          controller: _forgotPasswordEmail,
                                                                          decoration: InputDecoration(
                                                                            labelText: 'Email',
                                                                            labelStyle: TextStyle(
                                                                              color: Theme.of(context).textTheme.bodyLarge!.color,
                                                                            ),
                                                                            hintText: 'Confirm your password',
                                                                            hintStyle: TextStyle(
                                                                              color: Theme.of(context).cardTheme.color,
                                                                            ),
                                                                          ),
                                                                          keyboardType: TextInputType.emailAddress,
                                                                          validator: (String? value) {
                                                                            if (value!.isEmpty) {
                                                                              return 'Please enter your email';
                                                                            } else if (!validEmail(value)) {
                                                                              return 'Invalid email address';
                                                                            }

                                                                            return null;
                                                                          },
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: ElevatedButton(
                                                                          child: const Text("Send reset email"),
                                                                          onPressed: () {
                                                                            if (_forgotPasswordFormKey.currentState!.validate()) {
                                                                              FirebaseAuth.instance.sendPasswordResetEmail(email: _forgotPasswordEmail.text.toString()).then((value) {
                                                                                _forgotPasswordEmail.text = "";

                                                                                navigatorKey.currentState!.pop();
                                                                                navigatorKey.currentState!.pop();

                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    backgroundColor: Theme.of(context).cardTheme.color,
                                                                                    content: Text(
                                                                                      "Reset email link sent to ${_forgotPasswordEmail.text.toString()}",
                                                                                      style: TextStyle(
                                                                                        color: Theme.of(context).colorScheme.onPrimary,
                                                                                      ),
                                                                                    ),
                                                                                    duration: const Duration(seconds: 10),
                                                                                    action: SnackBarAction(
                                                                                      label: "Dismiss",
                                                                                      onPressed: () {
                                                                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              });
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            _showPolicyDialog();
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: MediaQuery.of(context).size.height * .025,
                      ),
                      child: SizedBox(
                        height: 50,
                        width: 300,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text(
                            'Sign up'.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            if (_termsAccepted ?? false) {
                              setState(() {
                                _hidePassword = true;
                              });

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    contentPadding: const EdgeInsets.all(25),
                                    children: [
                                      SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                SizedBox(
                                                  height: 50,
                                                  child: Image.asset(
                                                    'assets/images/logo-small.png',
                                                    width: 120,
                                                  ),
                                                ),
                                                const Text(
                                                  'SIGN UP',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Form(
                                              key: _signUpFormKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: TextFormField(
                                                      controller: _signUpEmail,
                                                      decoration: InputDecoration(
                                                        labelText: 'Email',
                                                        labelStyle: TextStyle(
                                                          color: Theme.of(context).colorScheme.onPrimary,
                                                        ),
                                                        hintText: 'Enter your email',
                                                        hintStyle: TextStyle(
                                                          color: Theme.of(context).cardTheme.color,
                                                        ),
                                                      ),
                                                      keyboardType: TextInputType.emailAddress,
                                                      validator: (String? value) {
                                                        if (value!.isEmpty) {
                                                          return 'Please enter your email';
                                                        }
                                                        if (!validEmail(value)) {
                                                          return 'Invalid email address';
                                                        }

                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: TextFormField(
                                                      controller: _signUpPass,
                                                      obscureText: _hidePassword,
                                                      decoration: InputDecoration(
                                                        labelText: 'Password',
                                                        labelStyle: TextStyle(
                                                          color: Theme.of(context).colorScheme.onPrimary,
                                                        ),
                                                        hintText: 'Enter your password',
                                                        hintStyle: TextStyle(
                                                          color: Theme.of(context).cardTheme.color,
                                                        ),
                                                      ),
                                                      keyboardType: TextInputType.visiblePassword,
                                                      validator: (String? value) {
                                                        if (value!.isEmpty) {
                                                          return 'Please enter a password';
                                                        } else if (!validPassword(value)) {
                                                          return 'Please enter a stronger password';
                                                        }

                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: TextFormField(
                                                      controller: _signUpConfirmPass,
                                                      obscureText: _hidePassword,
                                                      decoration: InputDecoration(
                                                        labelText: 'Confirm Password',
                                                        labelStyle: TextStyle(
                                                          color: Theme.of(context).colorScheme.onPrimary,
                                                        ),
                                                        hintText: 'Confirm your password',
                                                        hintStyle: TextStyle(
                                                          color: Theme.of(context).cardTheme.color,
                                                        ),
                                                      ),
                                                      keyboardType: TextInputType.visiblePassword,
                                                      validator: (String? value) {
                                                        if (value!.isEmpty) {
                                                          return 'Please confirm your password';
                                                        } else if (value != _signUpPass.text) {
                                                          return 'Passwords do not match';
                                                        }

                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          foregroundColor: Colors.white,
                                                          backgroundColor: Theme.of(context).primaryColor,
                                                        ),
                                                        child: const Text("Sign up"),
                                                        onPressed: () async {
                                                          if (_signUpFormKey.currentState!.validate()) {
                                                            _signUpFormKey.currentState!.save();

                                                            signUp(
                                                                context,
                                                                AuthAttempt(
                                                                  _signUpEmail.text,
                                                                  _signUpPass.text,
                                                                ), (error) async {
                                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  backgroundColor: Theme.of(context).cardTheme.color,
                                                                  content: Text(
                                                                    error,
                                                                    style: TextStyle(
                                                                      color: Theme.of(context).colorScheme.onPrimary,
                                                                    ),
                                                                  ),
                                                                  duration: const Duration(seconds: 10),
                                                                  action: SnackBarAction(
                                                                    label: "Dismiss",
                                                                    onPressed: () {
                                                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                                    },
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              _showPolicyDialog();
                            }
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 40),
                            child: Checkbox(
                              value: _termsAccepted,
                              materialTapTargetSize: MaterialTapTargetSize.padded,
                              onChanged: (val) {
                                setState(() {
                                  _termsAccepted = val;
                                  prefs.setBool('terms_accepted', val ?? false);
                                });
                              },
                            ),
                          ),
                          Container(
                            height: 60,
                            child: Text(
                              "Accept ",
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                            height: 60,
                            child: GestureDetector(
                              onTap: () {
                                _showPolicyDialog();
                              },
                              child: Text(
                                _policyLabel,
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).primaryColor, fontStyle: FontStyle.italic),
                              ),
                            ),
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
    );
  }

  _showPolicyDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Html(
                      data: _policyText,
                      style: preferences.darkMode ? HomeTheme.darkHtmlStyle : HomeTheme.lightHtmlStyle,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        navigatorKey.currentState!.pop();
                      },
                      child: Text(
                        "Close",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        navigatorKey.currentState!.pop();
                        setState(() {
                          _termsAccepted = true;
                          prefs.setBool('terms_accepted', true);
                        });
                      },
                      child: Text(
                        "Accept",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  signUp(BuildContext context, AuthAttempt authAttempt, Function error) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: authAttempt.email,
        password: authAttempt.password,
      )
          .then((credential) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Update/add the user's display name to firestore
        FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
          'display_name_lowercase': FirebaseAuth.instance.currentUser!.email!.toLowerCase(),
          'display_name': FirebaseAuth.instance.currentUser!.email,
          'email': FirebaseAuth.instance.currentUser!.email,
          'photo_url': null,
          'fcm_token': prefs.getString('fcm_token'),
        }).then((value) => () {});

        Navigator.of(context, rootNavigator: true).pop('dialog');

        bootstrap();

        navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) {
          return FluidNavigationBar(defaultTab: 2);
        }));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print(e.toString());
        await error('The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        print(e.toString());
        await error('The account already exists for that email');
      } else {
        print(e.toString());
        await error('There was an error signing up');
      }
    } catch (e) {
      print(e.toString());
      await error('There was an error signing up');
    }
  }

  signIn(BuildContext context, AuthAttempt authAttempt, Function error) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: authAttempt.email, password: authAttempt.password).then((credential) async {
        Navigator.of(context, rootNavigator: true).pop('dialog');

        // Update/add the user's display name to firestore
        DocumentReference uDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
        await uDoc.get().then((u) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (u.exists) {
            u.reference.update({
              'fcm_token': prefs.getString('fcm_token'),
            }).then((value) => null);
          } else {
            uDoc.set({
              'display_name_lowercase': FirebaseAuth.instance.currentUser!.email!.toLowerCase(),
              'display_name': FirebaseAuth.instance.currentUser!.email,
              'email': FirebaseAuth.instance.currentUser!.email,
              'public': true,
              'fcm_token': prefs.getString('fcm_token'),
            }).then((value) => null);
          }
        });

        bootstrap();

        navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) {
          return FluidNavigationBar(defaultTab: 2);
        }));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print(e.toString());
        await error('No user found for that email');
      } else if (e.code == 'wrong-password') {
        print(e.toString());
        await error('Wrong password');
      } else {
        print(e.toString());
        await error('There was an error signing in');
      }
    } catch (e) {
      print(e.toString());
      await error('There was an error signing in');
    }
  }

  socialSignIn(BuildContext context, String provider, Function error) async {
    if (provider == 'google') {
      signInWithGoogle().then((googleSignInAccount) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        DocumentReference uDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
        await uDoc.get().then((u) {
          if (u.exists) {
            // Update/add the user's display name to firestore
            u.reference.update({
              'fcm_token': prefs.getString('fcm_token'),
            }).then((value) => () {});
          } else {
            // Update/add the user's display name to firestore
            uDoc.set({
              'display_name_lowercase': FirebaseAuth.instance.currentUser!.displayName!.toLowerCase(),
              'display_name': FirebaseAuth.instance.currentUser!.displayName,
              'email': FirebaseAuth.instance.currentUser!.email,
              'photo_url': FirebaseAuth.instance.currentUser!.photoURL,
              'public': true,
              'fcm_token': prefs.getString('fcm_token'),
            }).then((value) => () {});
          }
        });

        bootstrap();

        navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) {
          return FluidNavigationBar(defaultTab: 2);
        }));
      }).catchError((e) async {
        var message = "There was an error signing in with Google";
        // if (e.code == "user-disabled") {
        //   message = "Your account has been disabled by the administrator";
        // } else if (e.code == "account-exists-with-different-credential") {
        //   message = "An account already exists with the same email address but different sign-in credentials. Please try signing in a different way";
        // }

        print(e);
        await error(message);
      });
    } else if (provider == 'apple') {
      signInWithApple(scopes: [Scope.email, Scope.fullName]).then((appleSignInAccount) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        DocumentReference uDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
        await uDoc.get().then((u) {
          if (u.exists) {
            // Update/add the user's display name to firestore
            u.reference.update({
              'fcm_token': prefs.getString('fcm_token'),
            }).then((value) => () {});
          } else {
            // Update/add the user's display name to firestore
            uDoc.set({
              'display_name_lowercase': FirebaseAuth.instance.currentUser!.displayName!.toLowerCase(),
              'display_name': FirebaseAuth.instance.currentUser!.displayName,
              'email': FirebaseAuth.instance.currentUser!.email,
              'photo_url': FirebaseAuth.instance.currentUser!.photoURL,
              'public': true,
              'fcm_token': prefs.getString('fcm_token'),
            }).then((value) => () {});
          }
        });

        bootstrap();

        navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) {
          return FluidNavigationBar(defaultTab: 2);
        }));
      }).catchError((e) async {
        var message = "There was an error signing in with Apple";
        // if (e.code == "user-disabled") {
        //   message = "Your account has been disabled by the administrator";
        // } else if (e.code == "account-exists-with-different-credential") {
        //   message = "An account already exists with the same email address but different sign-in credentials. Please try signing in a different way";
        // }

        print(e);
        await error(message);
      });
    }
  }
}

class AuthAttempt {
  final String email;
  final String password;

  AuthAttempt(this.email, this.password);
}
