import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:minivid/backend/apis/groq_api.dart';
import 'package:minivid/presentation/screens/bgm_music.dart';
import 'package:minivid/utils/widget/custom_appbar.dart';
import 'package:minivid/utils/widget/example_video.dart';
import 'package:minivid/utils/widget/subtitles_widget.dart';
import 'package:minivid/utils/widget/voice_selection_widget.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  bool _isLoading = false;
  bool _isAnimating = false;
  int selectedIndex = 2;
  bool _responseReceived = false;
  String _selectedOrientation = "Vertical";

  final List<String> suggestions = [
    "dog and cats",
    "Animals",
    "nature",
    "robots",
    "AI ruling on Earth",
  ];
  final List<Map<String, dynamic>> voices = [
    {"label": "Male 1", "icon": Icons.male},
    {"label": "Male 2", "icon": Icons.male},
    {"label": "Female 1", "icon": Icons.female},
    {"label": "Female 2", "icon": Icons.female},
  ];

  void _addSuggestionToTextField(String suggestion) {
    setState(() {
      _controller.text = suggestion;
    });
  }

  Future<void> _sendText() async {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _responseReceived = false;
      });

      final response = await GroqAPI().sendMessage(text);

      setState(() {
        _isLoading = false;
        _responseReceived = true;
        _responseController.text = response ?? "Failed to generate script.";
      });
    }
  }

  void _selectOrientation(String orientation) {
    setState(() {
      _selectedOrientation = orientation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.black87,
      body: IntroductionScreen(
        globalBackgroundColor: Colors.black87,
        pages: [
          PageViewModel(
            titleWidget: const Text(
              'Generate Video Scripts...',
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            bodyWidget: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Enter Description",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black87,
                    hintText: "Enter description to generate video on",
                    hintStyle:
                        const TextStyle(color: Colors.white60, fontSize: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white60),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 50, 16),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        "Suggestions",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 6.0,
                  children: suggestions.map((suggestion) {
                    return GestureDetector(
                      onTap: () => _addSuggestionToTextField(suggestion),
                      child: Chip(
                        label: Text(
                          suggestion,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        backgroundColor: Colors.grey[850],
                        side: const BorderSide(color: Colors.tealAccent),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const CircularProgressIndicator(),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _sendText,
                            icon: const Icon(Icons.send,
                                size: 16, color: Colors.white),
                            label: const Text("Send",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                )),
                          ),
                        ],
                      ),
                Divider(color: Colors.tealAccent),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        "Example Videos",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                DualVideoScreen(),
              ],
            ),
          ),
          PageViewModel(
            titleWidget: const Text(
              "Select Orientation,BGM, Voice and Subtitles",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            bodyWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select BGM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 260,
                  child: BGMPlayer(),
                ),
                const Text(
                  "Select Video Orientation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOrientationButton(
                        "Vertical", Icons.stay_current_portrait, "9:16"),
                    _buildOrientationButton(
                        "Landscape", Icons.stay_current_landscape, "16:9"),
                    _buildOrientationButton("Square", Icons.crop_square, "1:1"),
                  ],
                ),
                const SizedBox(height: 20),

                // Voice Selection Section
                const Text(
                  "Select Voice of Speech",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                VoiceSelectionWidget(),
                const SizedBox(height: 15),
                const Text(
                  "Select The Subtitles Fonts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SubtitlesWidget(),
                const SizedBox(height: 20),
                const Text(
                  "Generated Script",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _responseController,
                  maxLines: 7,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[900],
                    hintText: "Generated script will appear here...",
                    hintStyle:
                        const TextStyle(color: Colors.white60, fontSize: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.tealAccent),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 50, 16),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isAnimating = !_isAnimating;
                        });
                      },
                      icon:
                          const Icon(Icons.edit, size: 16, color: Colors.white),
                      label: const Text("Generate",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isAnimating)
                  Lottie.asset('assets/json/lottie1.json', height: 100),
              ],
            ),
          ),
        ],
        onDone: () => Navigator.pop(context),
        showSkipButton: true,
        skip: const Icon(Icons.arrow_back, color: Colors.tealAccent),
        next: const Icon(Icons.arrow_forward, color: Colors.tealAccent),
        done: const Text("Done", style: TextStyle(color: Colors.tealAccent)),
        dotsDecorator: const DotsDecorator(
          activeColor: Colors.tealAccent,
          color: Colors.grey,
          size: Size.square(8.0),
          activeSize: Size(16.0, 8.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildOrientationButton(String label, IconData icon, String ratio) {
    return GestureDetector(
      onTap: () => _selectOrientation(label),
      child: Chip(
        labelPadding:
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color:
                    _selectedOrientation == label ? Colors.black : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: Icon(
                icon,
                size: 24,
                color: _selectedOrientation == label
                    ? Colors.black
                    : Colors.tealAccent,
              ),
            ),
            Text(
              ratio,
              style: TextStyle(
                color: _selectedOrientation == label
                    ? Colors.black
                    : Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor:
            _selectedOrientation == label ? Colors.tealAccent : Colors.black,
        side: const BorderSide(color: Colors.tealAccent),
      ),
    );
  }
}
