// ignore_for_file: avoid_print, file_names

import 'package:g7trailapp/navigation/nav.dart';
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
  bool _signedIn = FirebaseAuth.instance.currentUser != null;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appleSignInAvailable = Provider.of<AppleSignInAvailable>(context, listen: false);

    //If user is signed in
    if (_signedIn) {
      return const FluidNavigationBar();
    }

    return SingleChildScrollView(
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .45,
                    child: Image.asset(
                      'assets/images/logo.png',
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * .02),
                    child: Text(
                      "Sign in to save your hikes, share them with friends, and more.",
                      style: TextStyle(
                        fontFamily: "LGCafe",
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyText1!.color,
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
                        socialSignIn(context, 'google', (error) {
                          // ignore: deprecated_member_use
                          // ignore: deprecated_member_use
                          widget.scaffoldKey.currentState!.hideCurrentSnackBar();
                          // ignore: deprecated_member_use
                          widget.scaffoldKey.currentState!.showSnackBar(
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
                                  // ignore: deprecated_member_use
                                  widget.scaffoldKey.currentState!.hideCurrentSnackBar();
                                },
                              ),
                            ),
                          );
                        });
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
                                socialSignIn(context, 'apple', (error) {
                                  // ignore: deprecated_member_use
                                  // ignore: deprecated_member_use
                                  widget.scaffoldKey.currentState!.hideCurrentSnackBar();
                                  // ignore: deprecated_member_use
                                  widget.scaffoldKey.currentState!.showSnackBar(
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
                                          // ignore: deprecated_member_use
                                          widget.scaffoldKey.currentState!.hideCurrentSnackBar();
                                        },
                                      ),
                                    ),
                                  );
                                });
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
                              color: Theme.of(context).textTheme.bodyText1!.color,
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
                        primary: Colors.white,
                        onPrimary: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Icon(
                              Icons.email,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 50),
                            child: const Text(
                              'Sign in with Email',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
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
                                                  color: Theme.of(context).textTheme.bodyText1!.color,
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
                                                  color: Theme.of(context).textTheme.bodyText1!.color,
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
                                                  primary: Theme.of(context).primaryColor,
                                                  onPrimary: Colors.white,
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
                                                      // ignore: deprecated_member_use
                                                      // ignore: deprecated_member_use
                                                      widget.scaffoldKey.currentState!.hideCurrentSnackBar();
                                                      // ignore: deprecated_member_use
                                                      widget.scaffoldKey.currentState!.showSnackBar(
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
                                                              // ignore: deprecated_member_use
                                                              widget.scaffoldKey.currentState!.hideCurrentSnackBar();
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
                                                                          color: Theme.of(context).textTheme.bodyText1!.color,
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
                                                                                    // ignore: deprecated_member_use
                                                                                    widget.scaffoldKey.currentState!.hideCurrentSnackBar();
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
                                                      primary: Theme.of(context).primaryColor,
                                                      onPrimary: Colors.white,
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
                                                          // ignore: deprecated_member_use
                                                          widget.scaffoldKey.currentState!.hideCurrentSnackBar();
                                                          // ignore: deprecated_member_use
                                                          widget.scaffoldKey.currentState!.showSnackBar(
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
                                                                  // ignore: deprecated_member_use
                                                                  widget.scaffoldKey.currentState!.hideCurrentSnackBar();
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
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

        setState(() {
          _signedIn = true;
        });
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

        setState(() {
          _signedIn = true;
        });
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

        setState(() {
          _signedIn = true;
        });
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

        setState(() {
          _signedIn = true;
        });
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
