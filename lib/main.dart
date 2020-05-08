import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter_webrtc/webrtc.dart';
import 'src/web_portal_screen.dart'
    if (dart.library.js) 'src/web_portal_screen_web.dart';

void main() {
  if (WebRTC.platformIsDesktop)
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebPortalScreen(),
    );
  }
}
