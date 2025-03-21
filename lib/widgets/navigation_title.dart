import 'package:flutter/material.dart';

class NavigationTitle extends StatelessWidget {
  const NavigationTitle({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Text(
        title!.toUpperCase(),
        style: TextStyle(
          fontFamily: 'LGCafe',
          fontSize: 20,
          color: Theme.of(context).appBarTheme.backgroundColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
