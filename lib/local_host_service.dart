import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceControlApp extends StatefulWidget {
  const VoiceControlApp({super.key});

  @override
  _VoiceControlAppState createState() => _VoiceControlAppState();
}

class _VoiceControlAppState extends State<VoiceControlApp> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _lastCommand = '';

  // Server IP and Port (replace with your computer's IP)
  final String serverUrl = 'http://192.168.121.254:5000/voice-command';

  @override
  void initState() {
    _speechToText.initialize(
      onStatus: (status) => log(status),
      onError: (err) => log(err as String),
    );
    super.initState();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (val) async {
            String recognizedWords = val.recognizedWords;
            setState(() {
              _lastCommand = recognizedWords;
            });

            // Send command to server
            await _sendVoiceCommand(recognizedWords);
            log(recognizedWords);
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  // Response temp;

  Future<void> _sendVoiceCommand(String command) async {
    try {
      final response = await http.post(Uri.parse(serverUrl), body: {'command': command});
      Map<String, dynamic> responseBody = json.decode(response.body);
      setState(() {
        // incomingResult = response.headers['message'] ?? '';
        httpError = response.statusCode.toString();
        // incomingResult = responseBody['message'] ?? 'No message received';
      });

      if (response.statusCode == 200) {
        print('Command sent successfully');
        setState(() {
          // incomingResult = httpError = response.statusCode.toString();
        });
      } else {
        print('Failed to send command');
      }
    } catch (e) {
      httpError = e.toString();
      print('Error sending command: $e');
    }
  }

  String httpError = '';
  String incomingResult = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Control Home Automation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _lastCommand.isEmpty ? '' : _lastCommand,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(httpError),
            Text(incomingResult),
            FloatingActionButton(
              onPressed: _listen,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            )
          ],
        ),
      ),
    );
  }
}
