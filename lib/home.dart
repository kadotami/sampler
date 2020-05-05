import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound_player.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sampler'),
      ),
      body: HomeContent(),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: [
        audioButton(trackNum: '1'),
        audioButton(trackNum: '2'),
        audioButton(trackNum: '3'),
        audioButton(trackNum: '4'),
      ],
    );
  }

  _init() async {}
}

class audioButton extends StatefulWidget {
  audioButton({this.trackNum});
  final String trackNum;
  @override
  _AudioButtonState createState() => _AudioButtonState();
}

class _AudioButtonState extends State<audioButton> {
  bool _isRecording = false;
  bool _isExsistFile = false;
  FlutterSoundPlayer playerModule;
  FlutterSoundRecorder recorderModule;
  String audioFilePath;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    playerModule = await FlutterSoundPlayer().initialize();
    recorderModule = await FlutterSoundRecorder().initialize();
    audioFilePath = '/sampler_audio_';
    Directory appDocDirectory;
    if (Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
    audioFilePath = appDocDirectory.path + audioFilePath + widget.trackNum;
    bool fileExist = await fileExists();
    setState(() {
      this._isExsistFile = fileExist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: createWidget());
  }

  Widget createWidget() {
    if (_isExsistFile) {
      return new GestureDetector(
        onTapDown: (TapDownDetails details) {
          _play();
        },
        onTapUp: (TapUpDetails details) {
          _stopPlay();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Colors.orange[300],
                Colors.orange[500],
                Colors.orange[700],
              ],
            ),
          ),
          padding: const EdgeInsets.all(10.0),
          child: const Text(
            'Play',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else if (_isRecording) {
      return new GestureDetector(
        onTapUp: (TapUpDetails details) {
          _stopRecord();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Colors.blue[300],
                Colors.blue[500],
                Colors.blue[700],
              ],
            ),
          ),
          padding: const EdgeInsets.all(10.0),
          child: const Text(
            'Recording...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return new GestureDetector(
        onTapDown: (TapDownDetails details) {
          _record();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Colors.blue[300],
                Colors.blue[500],
                Colors.blue[700],
              ],
            ),
          ),
          padding: const EdgeInsets.all(10.0),
          child: const Text(
            'Record',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<bool> fileExists() async {
    return await File(audioFilePath).exists();
  }

  _record() async {
    try {
      String path = await recorderModule.startRecorder(
        uri: audioFilePath,
        codec: t_CODEC.CODEC_AAC,
      );
      print('startRecorder: $path');
      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
      setState(() {
        _stopRecord();
        this._isRecording = false;
      });
    }
  }

  _stopRecord() async {
    String result = await recorderModule.stopRecorder();
    print('stopRecorder: $result');
    this.setState(() {
      this._isExsistFile = true;
      this._isRecording = false;
    });
  }

  _play() async {
    String path = await playerModule
        .startPlayer(audioFilePath, codec: t_CODEC.CODEC_AAC, whenFinished: () {
      print('Play finished');
      setState(() {});
    });
    print('startPlayer: $path');
  }

  _stopPlay() async {
    String result = await playerModule.stopPlayer();
    print('stopPlayer: $result');
  }
}
