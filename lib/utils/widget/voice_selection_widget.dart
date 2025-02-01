import 'package:flutter/material.dart';

class VoiceSelectionWidget extends StatefulWidget {
  const VoiceSelectionWidget({super.key});

  @override
  _VoiceSelectionWidgetState createState() => _VoiceSelectionWidgetState();
}

class _VoiceSelectionWidgetState extends State<VoiceSelectionWidget> {
  int selectedIndex = 2; // Default selection (Female 1)

  final List<Map<String, dynamic>> voices = [
    {"label": "Male 1", "icon": Icons.male},
    {"label": "Male 2", "icon": Icons.male},
    {"label": "Female 1", "icon": Icons.female},
    {"label": "Female 2", "icon": Icons.female},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(voices.length, (index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              width: 90,
              height: 90,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.teal : Colors.grey.shade700,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    voices[index]["icon"],
                    color: isSelected ? Colors.teal : Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    voices[index]["label"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.teal,
                      size: 20,
                    )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
