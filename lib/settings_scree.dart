import 'package:ai_es/ai_provider.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _voiceEndpointController = TextEditingController();
  final TextEditingController _commandEndpointController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _voiceEndpointController..text = aiProvider.voiceEndPoint,
              decoration: const InputDecoration(
                labelText: 'Voice Endpoint',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _commandEndpointController..text = aiProvider.commandEndPoint,
              decoration: const InputDecoration(
                labelText: 'Command Endpoint',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save the endpoints
                aiProvider.setVoiceEndPoint(_voiceEndpointController.text);
                aiProvider.setCommandEndPoint(_commandEndpointController.text);
              },
              child: const Text('Save'),
            ),
            //text widgets to show current endpoints
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Voice Endpoint: \n${aiProvider.voiceEndPoint}'),
                  Text('Command Endpoint: \n${aiProvider.commandEndPoint}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
