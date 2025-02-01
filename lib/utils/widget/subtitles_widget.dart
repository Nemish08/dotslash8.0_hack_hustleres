import 'package:flutter/material.dart';

class SubtitlesWidget extends StatefulWidget {
  final List<ImageDescription> imageDescriptions;

  const SubtitlesWidget({super.key, List<ImageDescription>? imageDescriptions})
      : imageDescriptions = imageDescriptions ?? defaultDescriptions;

  @override
  _SubtitlesWidgetState createState() => _SubtitlesWidgetState();
}

class _SubtitlesWidgetState extends State<SubtitlesWidget> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: ListView.builder(
        itemCount: widget.imageDescriptions.length,
        itemBuilder: (context, index) {
          final imageDescription = widget.imageDescriptions[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: Colors.teal, width: 2)
                    : null,
                image: DecorationImage(
                  image: AssetImage(imageDescription.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      imageDescription.topText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 100),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: imageDescription.subtitleBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        imageDescription.subtitle,
                        style: TextStyle(
                          color: imageDescription.subtitleTextColor,
                          fontSize: imageDescription.subtitleFontSize,
                          fontStyle: imageDescription.subtitleFontStyle,
                          fontWeight: imageDescription.subtitleFontWeight,
                          decoration: imageDescription.underline
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageDescription {
  final bool underline;
  final String imagePath;
  final String topText;
  final String subtitle;
  final Color subtitleTextColor;
  final Color subtitleBackgroundColor;
  final double subtitleFontSize;
  final FontStyle subtitleFontStyle;
  final FontWeight subtitleFontWeight;

  const ImageDescription({
    this.underline = false,
    required this.imagePath,
    required this.topText,
    required this.subtitle,
    this.subtitleTextColor = Colors.white70,
    this.subtitleBackgroundColor = Colors.transparent,
    this.subtitleFontSize = 14,
    this.subtitleFontStyle = FontStyle.normal,
    this.subtitleFontWeight = FontWeight.normal,
  });
}

// Default list of image descriptions
const List<ImageDescription> defaultDescriptions = [
  ImageDescription(
    underline: false,
    imagePath: 'assets/images/chess.png',
    topText: 'White text, black background, italic style',
    subtitle: 'This is an italic subtitle.',
    subtitleTextColor: Colors.white,
    subtitleBackgroundColor: Colors.black54,
    subtitleFontSize: 14,
    subtitleFontStyle: FontStyle.italic,
  ),
  ImageDescription(
    underline: false,
    imagePath: 'assets/images/chess.png',
    topText: 'Bold yellow text on black bg',
    subtitle: 'This subtitle is bold and yellow color',
    subtitleTextColor: Colors.yellow,
    subtitleBackgroundColor: Colors.black87,
    subtitleFontSize: 16,
    subtitleFontStyle: FontStyle.normal,
    subtitleFontWeight: FontWeight.bold,
  ),
  ImageDescription(
    underline: true, // This subtitle will be underlined
    imagePath: 'assets/images/chess.png',
    topText: 'Italic color text underline',
    subtitle: 'This subtitle is underlined.',
    subtitleTextColor: Colors.blueAccent,
    subtitleBackgroundColor: Colors.black38,
    subtitleFontSize: 15,
    subtitleFontStyle: FontStyle.normal,
    subtitleFontWeight: FontWeight.w500,
  ),
  ImageDescription(
    underline: false,
    imagePath: 'assets/images/chess.png',
    topText: 'Stylized color text, italic style',
    subtitle: 'A differently colored subtitle.',
    subtitleTextColor: Colors.redAccent,
    subtitleBackgroundColor: Colors.black26,
    subtitleFontSize: 14,
    subtitleFontStyle: FontStyle.italic,
    subtitleFontWeight: FontWeight.w600,
  ),
];
