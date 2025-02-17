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

class BoolChildren extends StatelessWidget {
  const BoolChildren({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 items per row
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2, // Adjust to balance size
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final devices = deviceNames.keys.toList();
        log(devices.toString());
        return BoolChild(device: devices[index]);
      },
    );
  }
}

class BoolChild extends StatelessWidget {
  final String device;
  const BoolChild({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    // Get the device state
    final deviceState = aiProvider.deviceStates[device];
    log('Device state: $deviceState for device $device');

    // Determine if the device is on
    final bool isOn;
    if (deviceState is String) {
      isOn = deviceState == 'on';
    } else if (deviceState is Map<String, dynamic>) {
      isOn = deviceState['state'] == 'on';
    } else {
      isOn = false; // Default to false if the state is neither a string nor a map
    }
    log('$device state : $isOn');
    return Card(
      elevation: 0,
      color: isOn ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7) : null,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          //use a thin outline in case if it is on. also use primary color if on
          side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), width: isOn ? 1 : 0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            device == "TV"
                ? Icons.connected_tv
                : device == "Refrigerator"
                    ? Icons.kitchen
                    : device == "DC motor"
                        //fan
                        ? Icons.wind_power_rounded
                        : Icons.lightbulb,
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
}

//user friendly names for the devices
const Map<String, String> deviceNames = {
  "room 1 light": "Room 1",
  "room 4 light": "Room 4",
  "kitchen light": "Kitchen",
  "TV": "TV",
  "Refrigerator": "Refrigerator",
  "DC motor": "Fan",

  // devices with intensity control
  "room 2 light": "Room 2",
  "room 3 light": "Room 3",
  "Servo motor": "Servo",
};

//lets create devices with intensity control using slider for room2 and room3 light and servo motor

class SliderChildren extends StatelessWidget {
  const SliderChildren({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SliderChild(device: "room 2 Light"),
        SizedBox(height: 5),
        SliderChild(device: "room 3 Light"),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child:
          //dont display anyting for servo
          (device == 'Servo motor')
              ? const SizedBox.shrink()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      device == "Servo motor" ? Icons.rotate_right : Icons.lightbulb,
                      size: 20,
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
                    const SizedBox(height: 10),
                    if (device == "Servo motor")
                      Row(
                        children: [
                          const Text(
                            ": 0°",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          Slider(
                            value: 0,
                            onChanged: (value) {},
                            onChangeEnd: (value) => print(value),
                            min: 0,
                            max: 180,
                            activeColor: Theme.of(context).colorScheme.primary,
                            inactiveColor: Colors.grey[300],
                          ),
                        ],
                      )
                    else
                      Slider(
                        value: 0,
                        onChanged: (value) {},
                        min: 0,
                        max: 100,
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Colors.grey[300],
                      ),
                  ],
                ),
    );
  }
}
