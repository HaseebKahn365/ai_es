import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

FlutterTts flutterTts = FlutterTts();

class VoiceControlApp extends StatefulWidget {
  const VoiceControlApp({super.key});
  @override
  State<VoiceControlApp> createState() => _VoiceControlAppState();
}

class _VoiceControlAppState extends State<VoiceControlApp> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';
  String _error = '';

  final String _serverUrl = 'http://192.168.149.254:5000/voice-command';

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() => _text = result.recognizedWords),
          cancelOnError: true,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      // Wait a moment then send the final text
      await Future.delayed(const Duration(milliseconds: 500));
      if (_text.isNotEmpty) {
        await _sendCommand(_text);
      }
    }
  }

  Future<void> _sendCommand(String command) async {
    try {
      final response = await http.post(Uri.parse(_serverUrl), body: {'command': command});

      if (response.statusCode != 200) {
        setState(() => _error = 'Error: ${response.statusCode}');
      }

      setState(() {
        recievedResp = response.body;
        // parse the body as json and then look for 'message' key
        words = json.decode(response.body)['message'];
        if (words.length > 100) {
          words = words.substring(0, 100);
        }
      });
      await flutterTts.speak(words);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  String recievedResp = '';
  String words = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Control'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _listen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: _isListening ? 150 : 80,
                width: _isListening ? 150 : 80,
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red.shade100 : Colors.blue.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _isListening ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                      spreadRadius: 10,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : Colors.blue,
                  size: 50,
                ),
              ),
            ),
            if (recievedResp.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  recievedResp,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            //a segmented button to select voice using popup menu and say "Hello this is demo voice for selected voice"

            const SegmentedControlDemo(),
          ],
        ),
      ),
    );
  }
}

class SegmentedControlDemo extends StatefulWidget {
  const SegmentedControlDemo({super.key});

  @override
  State<StatefulWidget> createState() => _SegmentedControlDemoState();
}

class _SegmentedControlDemoState extends State<SegmentedControlDemo> {
  final Map<int, Widget> children = const <int, Widget>{
    0: Text('Voice 1'),
    1: Text('Voice 2'),
    2: Text('Voice 3'),
  };

  int _sharedValue = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          const Text('Select Voice'),
          CupertinoSlidingSegmentedControl<int>(
            children: children,
            onValueChanged: (int? newValue) {
              // Changed to accept nullable int
              if (newValue != null) {
                // Add null check
                setState(() {
                  _sharedValue = newValue;
                });
              }
            },
            groupValue: _sharedValue,
          ),
          ElevatedButton(
            onPressed: () async {
              await flutterTts.setVoice({"name": "en-us-x-sfg#female_1-local", "locale": "en-US"});
              Map<String, String> voice;
              if (_sharedValue == 0) {
                voice = {"name": "en-us-x-sfg#male_1-local", "locale": "en-US"};
              } else if (_sharedValue == 1) {
                voice = {"name": "en-us-x-sfg#male_2-local", "locale": "en-US"};
              } else {
                voice = {"name": "en-us-x-sfg#male_3-local", "locale": "en-US"};
              }

              await flutterTts.speak('Hello this is demo voice for selected voice');
            },
            child: const Text('Say Hello'),
          ),
        ],
      ),
    );
  }
}
