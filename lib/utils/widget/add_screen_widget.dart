import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:minivid/presentation/screens/homescrren/add_screen.dart';
import 'package:minivid/utils/widget/custom_appbar.dart';

class AddScreenWidget extends StatefulWidget {
  const AddScreenWidget({super.key});

  @override
  State<AddScreenWidget> createState() => _AddScreenWidgetState();
}

class _AddScreenWidgetState extends State<AddScreenWidget> {
  final List<bool> _isHovered = [false, false, false, false]; // Hover states

  void _onHover(int index, bool isHovered) {
    setState(() {
      _isHovered[index] = isHovered;
    });
  }

  // Navigation logic for each card
  void _onCardTap(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddScreen(),
          ),
        );
        break;
      case 1:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const AddScreen()
        //   ),
        // );
        break;
      case 2:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const Page3(),
        //   ),
        // );
        break;
      case 3:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const Page4(),
        //   ),
        // );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 4 / 4,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _onCardTap(index), // Call the appropriate function
              child: MouseRegion(
                onEnter: (_) => _onHover(index, true),
                onExit: (_) => _onHover(index, false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isHovered[index]
                        ? [
                            BoxShadow(
                              color: Colors.tealAccent.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _getImageUrl(index),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image,
                                  color: Colors.white),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: _isHovered[index] ? 8 : 0,
                            sigmaY: _isHovered[index] ? 8 : 0,
                          ),
                          child: Container(
                            color: Colors.black
                                .withOpacity(_isHovered[index] ? 0.3 : 0.5),
                          ),
                        ),
                      ),
                      // Content
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getCardTitle(index),
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getCardDescription(index),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  String _getImageUrl(int index) {
    const images = [
      'https://img.freepik.com/premium-photo/cameraman-with-video-camera_1257223-85486.jpg',
      'https://th.bing.com/th/id/OIP.6oh8tS759orNIVSrL9M6-AHaJ4?w=1200&h=1600&rs=1&pid=ImgDetMain',
      'https://th.bing.com/th/id/OIP.NxiE2Fxw-6jGhr8RQ2lXeAHaFn?rs=1&pid=ImgDetMain',
      'https://th.bing.com/th/id/OIP.UclPF0TTewJycmGkCuJ4RQHaEH?w=1800&h=1001&rs=1&pid=ImgDetMain',
    ];
    return images[index % images.length];
  }

  String _getCardTitle(int index) {
    const titles = [
      "Generate mini video from stock videos",
      "Generate mini video from stock images",
      "Generate mini video from AI-generated images",
      "Generate mini video for marketing your product",
    ];
    return titles[index % titles.length];
  }

  String _getCardDescription(int index) {
    const descriptions = [
      "Trimmed and merged videos from free stock.",
      "Trimmed and merged images from free stock.",
      "AI-generated images based on the script.",
      "Product pictures included in the video.",
    ];
    return descriptions[index % descriptions.length];
  }
}
