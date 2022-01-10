import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({Key? key, this.icon, required this.title, this.maxWidth}) : super(key: key);

  final IconData? icon;
  final String title;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    Widget t = AutoSizeText(
      title.toUpperCase(),
      maxFontSize: Theme.of(context).textTheme.headline5!.fontSize ?? 22,
      minFontSize: 10,
      maxLines: 2,
      style: TextStyle(
        fontSize: Theme.of(context).textTheme.headline5!.fontSize,
        fontFamily: Theme.of(context).textTheme.headline5!.fontFamily,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      textAlign: TextAlign.start,
    );

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
          maxWidth != null
              ? SizedBox(
                  width: maxWidth ?? double.infinity,
                  child: t,
                )
              : t,
        ],
      ),
    );
  }
}
