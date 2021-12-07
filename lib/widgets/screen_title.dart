import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({Key? key, this.icon, required this.title}) : super(key: key);

  final IconData? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          icon == null
              ? Container()
              : Icon(
                  icon,
                  size: 22,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          SizedBox(
            width: 5,
          ),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headline5!.fontSize,
              fontFamily: Theme.of(context).textTheme.headline5!.fontFamily,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
