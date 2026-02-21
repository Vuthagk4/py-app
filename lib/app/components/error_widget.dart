import 'package:flutter/material.dart';

class CustomFlutterErrorWidget extends StatelessWidget {
  const CustomFlutterErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Image(
            image: AssetImage("assets/images/notfound.png"),
            height: 100.0,
          ),
          SizedBox(height: 20.0),
          Text(
            "An error occurred. Please try again later",
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
