import 'dart:ui';

import 'package:flutter/material.dart';

Future<Object?> customSigninDialog(
  BuildContext context, {
  required ValueChanged onClosed,
  required Widget child,
  Offset? offset,
}) {
  double verticalPosition = 0; // Starting vertical position
  double horizontalPosition = 0; // Starting horizontal position
  return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Sign In",
      context: context,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        Tween<Offset> tween =
            Tween(begin: offset ?? Offset(1, 0), end: Offset.zero);
        return SlideTransition(
            position: tween.animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child);
      },
      pageBuilder: (context, _, __) => StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  onPanUpdate: (details) {
                    // Update the position as the user drags the dialog (freely in any direction)
                    setState(() {
                      verticalPosition += details.delta.dy;
                      // horizontalPosition += details.delta.dx;
                    });
                  },
                  onPanEnd: (details) {
                    print("verticalPosition ${verticalPosition}");
                    setState(() {
                      verticalPosition = 0; // Snap back to the center
                      horizontalPosition = 0;
                    });
                  },
                  child: Transform.translate(
                    offset: Offset(horizontalPosition, verticalPosition),
                    child: SingleChildScrollView(
                      child: child,
                    ),
                  ),
                ),
              );
            },
          )).then(onClosed);
}
