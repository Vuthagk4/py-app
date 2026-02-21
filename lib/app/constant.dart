import 'package:flutter/material.dart';
import 'package:get/get.dart';

// google map api key
const String kGoogleApiKey = "AIzaSyAQYPE8jH1NougzGkwt1mxlo89XPxPy-xE";
const tEditProfile = Colors.amber;
const tPrimaryColor = Colors.amber;
const tDarkColor = Colors.black;
var kBaseURL =
    "http://${GetPlatform.isAndroid ? "10.0.2.2" : "localhost"}:8000/api";

var imageBaseUrl =
    "http://${GetPlatform.isAndroid ? "10.0.2.2" : "localhost"}:8000/storage";

// active button navigation
const kNavbarActive = Color(0xff20F2FF);

const Color backgroundColor = Color(0xff25254B);
const Color homeBackground = Color(0xff25254B);
const Color backgroundColor2 = Color(0xFF17203A);
const Color backgroundColorLight = Color(0xFFF2F6FF);
const Color backgroundColorDark = Color(0xFF25254B);
const Color shadowColorLight = Color(0xFF4A5367);
const Color shadowColorDark = Colors.black;
const Color lightShadow = Color(0xffFF72B6);
const Color lightNavActive = Color(0xffFF1FCE);

//border gradient
var kBorderGradientColor = LinearGradient(
  colors: [
    Colors.red.withOpacity(0.6),
    Color(0xffFF72B6).withOpacity(0.44),
    Color(0xffD9AFD9).withOpacity(0.61),
    Color(0xff97E1D4).withOpacity(0.85),
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const kTextGradientColor = LinearGradient(
  colors: [
    Color(0xff6284FF),
    Color(0xffFF72B6),
  ],
);
// const Color kModalBackground = Color(0xff0ff010203);
const Color kModalBackground = Color(0xff25254B);

const tProfileImage =
    "https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D";

//old constant

const String kYoutubeChannel =
    "https://www.youtube.com/channel/UC-RlkQcSnw8dNKA7kkF5kmw";
const String kFacebookPage = "https://facebook.com/reanitprogramming";

const kEmptyProductImg = "assets/images/empty_product.png";
// Colors
const kBackgroundColor = Color(0xffffffff);
const kCardColor = Color(0xfff7f7f7);

const kTextColor = Color(0xff000000);
const kPrimaryColor = Color(0xff000000);

const kSidebarBackgroundColor = Color(0xFFF1F4FB);
const kCardPopupBackgroundColor = Color(0xFFF5F8FF);
const kPrimaryLabelColor = Color(0xFF242629);
var kPrimaryLabelColorLight = const Color(0xFFF1F4FB);
const kSecondaryLabelColor = Color(0xFF797F8A);
const kShadowColor = Color.fromRGBO(72, 76, 82, 0.16);
const kElementIconColor = Color(0xFF17294D);
const kElementTitleColor = Color(0xFF17294D);
const kBackgroundColorDark = Color(0xFF191919);
const kCourseElementIconColor = Color(0xFF17294D);
const kLoginInputTextStyle = TextStyle(
  fontSize: 16,
  color: Color(0xFF17294D),
  fontWeight: FontWeight.w500,
  decoration: TextDecoration.none,
);
// Gradients
final kInnerDecoration = BoxDecoration(
  color: Colors.blue,
  border: Border.all(color: Colors.red),
  borderRadius: BorderRadius.circular(32),
);

final kGradientBoxDecoration = BoxDecoration(
  gradient: const LinearGradient(colors: [Colors.blue, Colors.green]),
  border: Border.all(
    color: Colors.white,
  ),
  borderRadius: BorderRadius.circular(32),
);

var kHeadingTextStyle = TextStyle(
  fontSize: 30.0,
  fontWeight: FontWeight.w800,
  decoration: TextDecoration.none,
);

// Text Styles
const kLargeTitleStyle = TextStyle(
  fontSize: 28.0,
  fontWeight: FontWeight.bold,
  color: kPrimaryLabelColor,
  decoration: TextDecoration.none,
);
const kTitle1StyleDark = TextStyle(
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  // color: kPrimaryLabelColor,
  // decoration: TextDecoration.none,
);
const kTitle1Style = TextStyle(
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  // color: kPrimaryLabelColor,
  // color: kPrimaryLabelColor,
  // decoration: TextDecoration.none,
);

var kTitle1LightStyle = TextStyle(
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
  color: kPrimaryLabelColorLight,
  // color: kPrimaryLabelColor,
  // decoration: TextDecoration.none,
);
var kCardTitleStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  color: kPrimaryLabelColor,

  // color: Colors.white,
  fontSize: 18.0,
  decoration: TextDecoration.none,
  overflow: TextOverflow.ellipsis,
);
var kTitle2Style = const TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,

  // color: kPrimaryLabelColor,
  decoration: TextDecoration.none,
);
var kHeadlineLabelStyle = TextStyle(
  fontSize: 17.0,
  fontWeight: FontWeight.w800,
  // color: kPrimaryLabelColor,
  decoration: TextDecoration.none,
);
const kHeadlineLabelStyleDark = TextStyle(
  fontSize: 17.0,
  fontWeight: FontWeight.w800,
  decoration: TextDecoration.none,
);
const kSubtitleStyle = TextStyle(
  fontSize: 16.0,
  decoration: TextDecoration.none,
);
const kSubtitleStyleDark = TextStyle(
  fontSize: 16.0,
  color: Colors.white,
  decoration: TextDecoration.none,
);
var kBodyLabelStyle = TextStyle(
  fontSize: 16.0,
  // color: Colors.black,
  // fontFamily: 'SF Pro Text',
  decoration: TextDecoration.none,
);
var kCalloutLabelStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.w800,
  decoration: TextDecoration.none,
);
const kSecondaryCalloutLabelStyle = TextStyle(
  fontSize: 16.0,
  decoration: TextDecoration.none,
);
const kSearchPlaceholderStyle = TextStyle(
  fontSize: 13.0,
  decoration: TextDecoration.none,
);
var kSearchTextStyle = const TextStyle(
  fontSize: 13.0,
  decoration: TextDecoration.none,
);
const kCardSubtitleStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 13.0,
  decoration: TextDecoration.none,
);
const kCaptionLabelStyle = TextStyle(
  fontSize: 12.0,
  color: kSecondaryLabelColor,
  decoration: TextDecoration.none,
);

ThemeData getEnglishTheme() {
  return ThemeData(
    // Define your English theme settings
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'SF Pro Text'),
    ),
  );
}

ThemeData getKhmerTheme() {
  return ThemeData();
}

// assets path
const kLogoImage = 'assets/images/logo.png';
const kProfileURL =
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKKdhi4rN1UIINQMZ91SQ_U7SvVwFnMEk2iw&s';

kShowLoading() {
  Get.dialog(
    const Center(
      child: CircularProgressIndicator(),
    ),
    barrierDismissible: false,
  );
}
