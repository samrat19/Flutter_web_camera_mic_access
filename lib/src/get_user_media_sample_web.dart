// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as HTML;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:flutter_webrtc/web/get_user_media.dart' as gum;
import 'dart:core';

class GetUserMediaSample extends StatefulWidget {
  static String tag = 'get_usermedia_sample';

  @override
  _GetUserMediaSampleState createState() => _GetUserMediaSampleState();
}

class _GetUserMediaSampleState extends State<GetUserMediaSample> {
  MediaStream _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  MediaRecorder _mediaRecorder;

  get _isRec => _mediaRecorder != null;
  List<dynamic> cameras;

  @override
  initState() {
    super.initState();
    initRenderers();
    gum.navigator.getSources().then((md) {
      setState(() {
        cameras = md.where((d) => d['kind'] == 'videoinput');
      });
    });
  }

  @override
  deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
    _localRenderer.dispose();
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  _makeCall() async {
    final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": {
        "mandatory": {
          "minWidth":
              '1280', // Provide your own width, height and frame rate here
          "minHeight": '720',
          "minFrameRate": '30',
        },
      }
    };

    try {
      var stream = await navigator.getUserMedia(mediaConstraints);
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
      _localRenderer.mirror = true;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  _hangUp() async {
    try {
      await _localStream.dispose();
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });
  }

  _startRecording() async {
    _mediaRecorder = MediaRecorder();
    setState(() {});
    _mediaRecorder.startWeb(_localStream);
  }

  _stopRecording() async {
    final objectUrl = await _mediaRecorder?.stop();
    setState(() {
      _mediaRecorder = null;
    });
    print(objectUrl);
    HTML.window.open(objectUrl, '_blank');
  }

  _captureFrame() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == "video");
    final frame = await videoTrack.captureFrame();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.network(frame, height: 720, width: 1280),
        actions: <Widget>[
          FlatButton(
            child: Text("OK"),
            onPressed: Navigator.of(context, rootNavigator: true).pop,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width / 50,
                bottom: MediaQuery.of(context).size.width / 20,
                left: MediaQuery.of(context).size.width / 30,
              ),
              child: RTCVideoView(_localRenderer),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width / 8),
              child: MaterialButton(
                color:  _inCalling ? Colors.redAccent : Colors.green[800],
                onPressed: _inCalling ? _hangUp : _makeCall,
                child: _inCalling
                    ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'end video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40.0,
                        ),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'make video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40.0,
                        ),
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
