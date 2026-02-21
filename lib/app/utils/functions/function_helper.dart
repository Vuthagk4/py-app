import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showIOSDialog(BuildContext context,
    {required String title, required String content}) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          // CupertinoDialogAction(
          //   child: Text('OK'),
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //   },
          // ),
        ],
      );
    },
  );
}
