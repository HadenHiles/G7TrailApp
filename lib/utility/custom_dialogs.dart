import 'package:flutter/material.dart';
import 'package:g7trailapp/models/confirm_dialog.dart';

void dialog(BuildContext context, ConfirmDialog dialog) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(
      dialog.cancelText,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
    onPressed: dialog.cancelCallback(),
  );
  Widget continueButton = TextButton(
    child: Text(
      dialog.continueText,
      style: TextStyle(color: Colors.red),
    ),
    onPressed: dialog.continueCallback(),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      dialog.title,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 20,
      ),
    ),
    backgroundColor: Theme.of(context).colorScheme.surface,
    content: dialog.body,
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  Future.delayed(Duration.zero, () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  });
}
