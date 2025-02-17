import 'package:ai_es/ai_provider.dart';
import 'package:ai_es/listening_button.dart';
import 'package:ai_es/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VoiceControlScreen extends StatelessWidget {
  const VoiceControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, _) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  //on the left side should be the title of the app ie. Home Assistant
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Text(
                            'Smart Home',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          aiProvider.isLoading
                              ? const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  //button to toggle the theme
                  const Positioned(
                      //top center
                      top: 0,
                      right: 0,
                      child: Center(child: ThemeChanger())),
                  // Loading State
                  // if (aiProvider.isLoading)
                  //   Positioned(
                  //     left: MediaQuery.of(context).size.width / 2 - 20,
                  //     top: 0,
                  //     child: const Center(
                  //       child: CircularProgressIndicator(),
                  //     ),
                  //   ),

                  // Text Display
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          child: Text(
                            aiProvider.text.isEmpty ? '' : aiProvider.text,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w200,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // create a stylish button to start listening but make sure to use animated container and gesture detector
                        const ListeningButton(),
                      ],
                    ),
                  ),

                  // Error Display
                  if (aiProvider.error.isNotEmpty)
                    Positioned(
                      bottom: 20, // Position at the bottom
                      left: 20, // Add left padding
                      right: 20, // Add right padding to constrain width
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(maxWidth: 300), // Limit width
                        child: Text(
                          aiProvider.error,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true, // Enable text wrapping
                          overflow: TextOverflow.visible, // Show all text
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     if (aiProvider.isListening) {
          //       aiProvider.stopListening();
          //     } else {
          //       aiProvider.startListening();
          //     }
          //   },
          //   child: Icon(
          //     aiProvider.isListening ? Icons.mic : Icons.mic_none,
          //     color: Colors.white,
          //   ),
          // ),
        );
      },
    );
  }
}

class ThemeChanger extends StatelessWidget {
  const ThemeChanger({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Switch.adaptive(
          value: themeProvider.isDarkMode,
          onChanged: (_) => themeProvider.toggleTheme(),
          activeColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          activeTrackColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          inactiveThumbColor: Theme.of(context).colorScheme.surface,
          inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return Icon(
                  Icons.dark_mode,
                  color: Theme.of(context).colorScheme.secondary,
                );
              }
              return Icon(
                Icons.light_mode,
                color: Theme.of(context).colorScheme.secondary,
              );
            },
          ),
        );
      },
    );
  }
}
