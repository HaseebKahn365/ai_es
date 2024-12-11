import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  String recievedResp = '';

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
          ],
        ),
      ),
    );
  }
}
