import 'package:ai_es/ai_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListeningButton extends StatefulWidget {
  const ListeningButton({super.key});

  @override
  _ListeningButtonState createState() => _ListeningButtonState();
}

class _ListeningButtonState extends State<ListeningButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for listening state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Breathing animation for idle state
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        return Stack(
          children: [
            AnimatedBuilder(
              animation: aiProvider.isListening ? _pulseController : _breathingController,
              builder: (context, child) {
                bool isListening = aiProvider.isListening;
                return Transform.scale(
                  scale: aiProvider.isListening ? _pulseAnimation.value : _breathingAnimation.value,
                  child: GestureDetector(
                    onTapDown: (_) {
                      if (aiProvider.isListening) {
                        aiProvider.stopListening();
                      } else {
                        aiProvider.startListening();
                      }
                    },
                    onTapUp: (_) {
                      if (aiProvider.isListening) {
                        aiProvider.stopListening();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: aiProvider.isListening ? 150 : 250,
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isListening ? Theme.of(context).colorScheme.error.withOpacity(0.5) : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            isListening ? Theme.of(context).colorScheme.error.withOpacity(0.8) : Theme.of(context).colorScheme.primary.withOpacity(0.8),
                            isListening ? Theme.of(context).colorScheme.error.withOpacity(1.0) : Theme.of(context).colorScheme.primary.withOpacity(1.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(aiProvider.isListening ? 75 : 50),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glass effect overlay
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: aiProvider.isListening ? 146 : 246,
                            height: 146,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(aiProvider.isListening ? 73 : 48),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Content
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            //on top shoudl be the label so that it doesnt animate. listening or start listening
            Positioned.fill(
              child: Center(
                child: Text(
                  aiProvider.isListening ? 'Listening...' : 'Start Listening',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
