import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constant.dart';

class ButtonReusable extends StatelessWidget {
  final void Function()? onPressed;
  final String? label;
  final bool? isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const ButtonReusable({
    super.key,
    this.onPressed,
    this.label,
    this.isLoading,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            gradient: (isLoading == null || !isLoading!)
                ? kBorderGradientColor
                : null,
            // gradient: kBorderGradientColor,
            // color: isLoading != null ? backgroundColor : null,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                spreadRadius: 11,
                blurRadius: 20,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: ElevatedButton.icon(
              // onPressed: isLoading != null ? onPressed : null,
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
              icon: Icon(
                CupertinoIcons.arrow_right,
                color: textColor,
              ),
              label: (isLoading != null && isLoading!)
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : Text(
                label ?? "",
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
