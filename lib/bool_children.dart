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

//we need to create stunning looking cards for each of the above devices with icon and a lable

import 'dart:developer';

import 'package:ai_es/ai_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Define global deviceNames
const Map<String, String> deviceNames = {
  "room 1 light": "Room 1",
  "room 4 light": "Room 4",
  "kitchen light": "Kitchen",
  "TV": "TV",
  "Refrigerator": "Refrigerator",
  "DC motor": "Fan",
  "room 2 light": "Room 2",
  "room 3 light": "Room 3",
  "Servo motor": "Servo",
};

class BoolChildren extends StatelessWidget {
  const BoolChildren({super.key});

  @override
  Widget build(BuildContext context) {
    // This line ensures the widget rebuilds when notifyListeners is called
    // but we still use the global aiProvider for data access
    context.watch<AIAssistantProvider>();

    final devices = deviceNames.keys.toList();
    log('Rebuilding BoolChildren with devices: ${devices.toString()}');

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 items per row
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2, // Adjust to balance size
      ),
      itemCount: devices.length > 6 ? 6 : devices.length,
      itemBuilder: (context, index) {
        if (index < devices.length) {
          return BoolChild(device: devices[index]);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class BoolChild extends StatelessWidget {
  final String device;
  const BoolChild({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    // This line ensures the widget rebuilds when notifyListeners is called
    // but we still use the global aiProvider for data access
    context.watch<AIAssistantProvider>();

    // Get the device state from global aiProvider
    final deviceState = aiProvider.deviceStates[device];
    log('Device state: $deviceState for device $device');

    // Determine if the device is on
    final bool isOn = _determineDeviceState(deviceState);
    log('$device state: $isOn');

    return Card(
      elevation: 0,
      color: isOn ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), width: isOn ? 1 : 0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForDevice(device),
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text(
            deviceNames[device] ?? device,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _determineDeviceState(dynamic state) {
    if (state == null) return false;

    if (state is String) {
      return state.toLowerCase() == 'on';
    } else if (state is Map) {
      try {
        // Try to safely access the state value, handling different map structures
        final dynamic stateValue = state['state'];
        if (stateValue is String) {
          return stateValue.toLowerCase() == 'on';
        }
      } catch (e) {
        log('Error determining device state: $e');
      }
    }
    return false;
  }

  IconData _getIconForDevice(String device) {
    if (device == "TV") return Icons.connected_tv;
    if (device == "Refrigerator") return Icons.kitchen;
    if (device == "DC motor") return Icons.wind_power_rounded;
    if (device == "Servo motor") return Icons.rotate_right;
    return Icons.lightbulb; // Default for lights
  }
}

class SliderChildren extends StatelessWidget {
  const SliderChildren({super.key});

  @override
  Widget build(BuildContext context) {
    // This line ensures the widget rebuilds when notifyListeners is called
    context.watch<AIAssistantProvider>();

    return const Column(
      children: [
        SliderChild(device: "room 2 light"),
        SizedBox(height: 5),
        SliderChild(device: "room 3 light"),
        SizedBox(height: 5),
        SliderChild(device: "Servo motor"),
      ],
    );
  }
}

class SliderChild extends StatelessWidget {
  final String device;
  const SliderChild({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    // This line ensures the widget rebuilds when notifyListeners is called
    context.watch<AIAssistantProvider>();

    // Get state from global aiProvider
    final deviceState = aiProvider.deviceStates[device];

    // Determine intensity or degrees based on device type
    final double sliderValue = _getSliderValue(deviceState);
    final bool isOn = _isDeviceOn(deviceState);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: device == 'Servo motor' && !isOn
          ? const SizedBox.shrink()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  device == "Servo motor" ? Icons.rotate_right : Icons.lightbulb,
                  size: 20,
                  color: isOn ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  deviceNames[device] ?? device,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isOn ? Theme.of(context).colorScheme.onSurface : Colors.grey,
                  ),
                ),
                const SizedBox(width: 10),
                if (device == "Servo motor")
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          ": ${sliderValue.toInt()}°",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isOn ? Theme.of(context).colorScheme.onSurface : Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: sliderValue,
                            onChanged: isOn
                                ? (value) {
                                    // Use global aiProvider directly
                                    // aiProvider.updateDeviceAngle(device, value.toInt());
                                  }
                                : null,
                            min: 0,
                            max: 180,
                            activeColor: Theme.of(context).colorScheme.primary,
                            inactiveColor: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Slider(
                      value: sliderValue,
                      onChanged: isOn
                          ? (value) {
                              // Use global aiProvider directly
                              // aiProvider.updateDeviceIntensity(device, value.toInt());
                            }
                          : null,
                      min: 0,
                      max: 100,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Colors.grey[300],
                    ),
                  ),
              ],
            ),
    );
  }

  double _getSliderValue(dynamic state) {
    if (state == null) return 0;

    try {
      if (state is Map) {
        if (device == "Servo motor" && state.containsKey('degrees')) {
          final degrees = state['degrees'];
          return degrees is int ? degrees.toDouble() : 0.0;
        } else if (state.containsKey('intensity')) {
          final intensity = state['intensity'];
          return intensity is int ? intensity.toDouble() : 0.0;
        }
      }
    } catch (e) {
      log('Error getting slider value: $e');
    }
    return 0;
  }

  bool _isDeviceOn(dynamic state) {
    if (state == null) return false;

    if (state is String) {
      return state.toLowerCase() == 'on';
    } else if (state is Map) {
      try {
        final dynamic stateValue = state['state'];
        if (stateValue is String) {
          return stateValue.toLowerCase() == 'on';
        }
      } catch (e) {
        log('Error determining device state: $e');
      }
    }
    return false;
  }
}
