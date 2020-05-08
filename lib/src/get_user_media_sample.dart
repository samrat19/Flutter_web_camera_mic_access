import 'dart:io';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:path_provider/path_provider.dart';

class GetUserMediaSample extends StatefulWidget {
  static String tag = 'get_usermedia_sample';

  @override
  _GetUserMediaSampleState createState() => _GetUserMediaSampleState();
}

class _GetUserMediaSampleState extends State<GetUserMediaSample> {
  MediaStream _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _isTorchOn = false;
  MediaRecorder _mediaRecorder;

  get _isRec => _mediaRecorder != null;

  @override
  initState() {
    super.initState();
    initRenderers();
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
      "audio": false,
      "video": {
        "mandatory": {
          "minWidth":
              '1280', // Provide your own width, height and frame rate here
          "minHeight": '720',
          "minFrameRate": '30',
        },
        "facingMode": "user",
        "optional": [],
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
    if (Platform.isIOS) {
      print("Recording is not available on iOS");
      return;
    }
    final storagePath = await getExternalStorageDirectory();
    final filePath = storagePath.path + '/webrtc_sample/test.mp4';
    _mediaRecorder = MediaRecorder();
    setState(() {});
    await _localStream.getMediaTracks();
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == "video");
    await _mediaRecorder.start(
      filePath,
      videoTrack: videoTrack,
    );
  }

  _stopRecording() async {
    await _mediaRecorder?.stop();
    setState(() {
      _mediaRecorder = null;
    });
  }

  _toggleTorch() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == "video");
    final has = await videoTrack.hasTorch();
    if (has) {
      setState(() => _isTorchOn = !_isTorchOn);
      await videoTrack.setTorch(_isTorchOn);
    }
  }

  _toggleCamera() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == "video");
    await videoTrack.switchCamera();
  }

  _captureFrame() async {
    String filePath;
    if (Platform.isAndroid) {
      final storagePath = await getExternalStorageDirectory();
      filePath = storagePath.path + '/webrtc_sample/test.jpg';
    } else {
      final storagePath = await getApplicationDocumentsDirectory();
      filePath = storagePath.path + '/test${DateTime.now()}.jpg';
    }

    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == "video");
    videoTrack.captureFrame(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _inCalling
            ? <Widget>[
                IconButton(
                  icon: Icon(_isTorchOn ? Icons.flash_off : Icons.flash_on),
                  onPressed: _toggleTorch,
                ),
                IconButton(
                  icon: Icon(Icons.switch_video),
                  onPressed: _toggleCamera,
                ),
                IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: _captureFrame,
                ),
                IconButton(
                  icon: Icon(_isRec ? Icons.stop : Icons.fiber_manual_record),
                  onPressed: _isRec ? _stopRecording : _startRecording,
                ),
              ]
            : null,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(_localRenderer),
              decoration: BoxDecoration(color: Colors.black54),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
