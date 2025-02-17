import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

/*

self.device_states = {
            # Lights with ON/OFF and Intensity Control
            "room 1 light": "off",
            "room 2 light": {"state": "off", "intensity": 0},  # Intensity control (0-100%)
            "room 3 light": {"state": "off", "intensity": 0},  # Intensity control (0-100%)
            "room 4 light": "off",
            "kitchen light": "off",
            
            # TV and Refrigerator (ON/OFF)
            "TV": "off",
            "Refrigerator": "off",

            # DC Motor (ON/OFF)
            "DC motor": "off",

            # Servo Motor (Clockwise/Anticlockwise in degrees)
            "Servo motor": {"direction": "none", "degrees": 0}
        }
 */

//in the above configs only Room1, room4, kitchen light, TV, Refrigerator, DC motor are on/off switches are of bool type

class AIAssistantProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool isListening = false;
  String text = '';
  String error = '';
  bool isLoading = false;

  String voiceEndPoint = 'http://192.168.149.254:5000/voice-command';
  String commandEndPoint = 'http://192.168.149.254:5000/command';

  Map<String, dynamic> deviceStates = {
    'room 1 light': 'off',
    'room 2 light': {'state': 'off', 'intensity': 0},
    'room 3 light': {'state': 'off', 'intensity': 0},
    'room 4 light': 'off',
    'kitchen light': 'off',
    'TV': 'off',
    'Refrigerator': 'off',
    'DC motor': 'off',
    'Servo motor': {'direction': 'none', 'degrees': 0},
  };

  //

  void setVoiceEndPoint(String endPoint) {
    voiceEndPoint = endPoint;
    notifyListeners();
  }

  void setCommandEndPoint(String endPoint) {
    commandEndPoint = endPoint;
    notifyListeners();
  }

  // Initialize speech recognition
  Future<void> initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (errorNotification) => _handleError(errorNotification.errorMsg),
      );
      if (!available) {
        _handleError('Speech recognition not available');
      }
    } catch (e) {
      _handleError('Error initializing speech: $e');
    }
  }

  // Start listening
  Future<void> startListening() async {
    try {
      if (!isListening) {
        isListening = true;
        text = '';
        error = '';
        notifyListeners();

        await _speech.listen(
          onResult: (result) {
            text = result.recognizedWords;
            log(text);
            notifyListeners();
          },
        );
      }
    } catch (e) {
      _handleError('Error starting listening: $e');
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      isListening = false;
      notifyListeners();

      if (text.isNotEmpty) {
        await sendVoiceCommand(text);
      }
    } catch (e) {
      _handleError('Error stopping listening: $e');
    }
  }

  // Send voice command to server

/*
 try {
      final response = await http.post(Uri.parse(serverUrl), body: {'command': command});
      Map<String, dynamic> responseBody = json.decode(response.body);
      setState(() {
        // incomingResult = response.headers['message'] ?? '';
        httpError = response.statusCode.toString();
        // incomingResult = responseBody['message'] ?? 'No message received';
      });
      final response = await http.post(Uri.parse(_serverUrl), body: {'command': command});

      if (response.statusCode == 200) {
        print('Command sent successfully');
        setState(() {
          // incomingResult = httpError = response.statusCode.toString();
        });
      } else {
        print('Failed to send command');
      if (response.statusCode != 200) {
        setState(() => _error = 'Error: ${response.statusCode}');
      }

      setState(() {
        recievedResp = response.body;
      });
    } catch (e) {
      httpError = e.toString();
      print('Error sending command: $e');
      setState(() => _error = e.toString());
    }

 */

  Future<void> sendVoiceCommand(String command) async {
    try {
      log('Sending command: $command');
      isLoading = true;
      error = '';
      notifyListeners();

      final response = await http.post(Uri.parse(voiceEndPoint), body: {'command': command});

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        text = responseBody['message'] ?? 'No message received';
        await _tts.speak(text);
      } else {
        error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      error = 'Network error: $e';
      log('Error sending command: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Clear state
  void clearState() {
    text = '';
    error = '';
    notifyListeners();
  }

  // Handle errors
  void _handleError(String errorMessage) {
    error = errorMessage;
    //speak first 100 characters of error message
    _tts.speak(errorMessage.substring(0, 100));
    isListening = false;
    notifyListeners();
  }
}

AIAssistantProvider aiProvider = AIAssistantProvider();
