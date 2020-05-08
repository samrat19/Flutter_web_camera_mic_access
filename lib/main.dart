import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter_webrtc/webrtc.dart';
import 'src/get_user_media_sample.dart'
    if (dart.library.js) 'src/get_user_media_sample_web.dart';

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
      home: GetUserMediaSample(),
    );
  }
}
