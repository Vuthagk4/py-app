import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:gradient_borders/gradient_borders.dart';

import '../utils/helper/vibrate_helper.dart';

class TextfieldReusable extends StatefulWidget {
  TextfieldReusable(
      {super.key,
        this.focusNode,
        this.isFocused = false,
        this.hintText,
        this.controller,
        this.leadingIcon,
        this.obscureText});
  final FocusNode? focusNode;
  bool isFocused;
  final String? hintText;
  final TextEditingController? controller;
  final Icon? leadingIcon;
  final bool? obscureText;

  @override
  State<TextfieldReusable> createState() => _TextfieldReusableState();
}

class _TextfieldReusableState extends State<TextfieldReusable> {
  String? _errorMessage;
  void _listenFocus() async {
    widget.focusNode?.addListener(() async {
      VibrateHelper.vibrateSoft();
      setState(() {
        widget.isFocused = widget.focusNode!.hasFocus;
      });
    });
  }

  @override
  void initState() {
    _listenFocus();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextFormField(
          obscureText: widget.obscureText ?? false,
          controller: widget.controller,
          focusNode: widget.focusNode,
          // validator: (value) {
          //   if (value == null || value.isEmpty) {
          //     setState(() {
          //       _errorMessage = "This field cannot be empty";
          //     });
          //     return ''; // Returning empty string prevents error message display
          //   }
          //   setState(() {
          //     _errorMessage = null;
          //   });
          //   return null;
          // },
          onSaved: (email) {},
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            errorMaxLines:
            1, // Limit the error text to one line to avoid large expansions
            hintText: widget.hintText,
            // contentPadding: EdgeInsets.symmetric(vertical: 18),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AnimatedOpacity(
                  opacity: widget.isFocused ? 1.0 : 1.0,
                  duration: const Duration(milliseconds: 1000),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // color: backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(0, -1),
                          blurRadius: widget.isFocused ? 10 : 0,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: widget.leadingIcon,
                    ),
                  )),
            ),
            border: GradientOutlineInputBorder(
              gradient: const LinearGradient(
                colors: [
                  Colors.black12,
                  Colors.black12,
                ],
              ),
              width: 1,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
