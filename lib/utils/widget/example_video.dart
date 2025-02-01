import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String caption;

  const SimpleVideoPlayer(
      {Key? key, required this.videoUrl, required this.caption})
      : super(key: key);

  @override
  _SimpleVideoPlayerState createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Colors.tealAccent,
                          ),
                        ),
                  if (_showControls)
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                ],
              ),
            ),
          ),
        ),
        Text(
          widget.caption,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class DualVideoScreen extends StatelessWidget {
  final List<String> videoUrls = [
    'https://res.cloudinary.com/djc4fwyrc/video/upload/v1738164292/mOXWUrIShsghrgx2xIJ5I6nIFcA3/20250129_205449_final-sub-1738164282.9887745.mp4',
    'https://res.cloudinary.com/djc4fwyrc/video/upload/v1738163205/mOXWUrIShsghrgx2xIJ5I6nIFcA3/20250129_203644_final-sub-1738163193.7279887.mp4',
    'https://res.cloudinary.com/djc4fwyrc/video/upload/v1738235465/mOXWUrIShsghrgx2xIJ5I6nIFcA3/20250130_164050_final-sub-1738235438.967802.mp4',
  ];
  final List<String> caption = [
    'Landscapes Video 16:9',
    'Vertical Video 9:16',
    'Customize Subtitles',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SimpleVideoPlayer(
            videoUrl: videoUrls[0],
            caption: caption[0],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SimpleVideoPlayer(
                  videoUrl: videoUrls[1],
                  caption: caption[1],
                ),
                SimpleVideoPlayer(
                  videoUrl: videoUrls[2],
                  caption: caption[2],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
