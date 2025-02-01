import 'package:flutter/material.dart';
import 'package:minivid/utils/widget/custom_appbar.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GeneratedVideoScreen extends StatefulWidget {
  @override
  _GeneratedVideoScreenState createState() => _GeneratedVideoScreenState();
}

class _GeneratedVideoScreenState extends State<GeneratedVideoScreen> {
  List<VideoDetails> videoList = [
    VideoDetails(
      id: '001',
      name: 'Video One',
      description: 'Description for Video One',
      imageUrl:
          'https://th.bing.com/th/id/OIP.xGljq3ZFDLfF5jMV1kv5kwHaEJ?w=308&h=180&c=7&r=0&o=5&dpr=1.4&pid=1.7',
      videoUrl:
          'https://res.cloudinary.com/djc4fwyrc/video/upload/v1738164292/mOXWUrIShsghrgx2xIJ5I6nIFcA3/20250129_205449_final-sub-1738164282.9887745.mp4',
    ),
    VideoDetails(
      id: '002',
      name: 'Video Two',
      description: 'Description for Video Two',
      imageUrl:
          'https://th.bing.com/th/id/OIP.xGljq3ZFDLfF5jMV1kv5kwHaEJ?w=308&h=180&c=7&r=0&o=5&dpr=1.4&pid=1.7',
      videoUrl:
          'https://res.cloudinary.com/djc4fwyrc/video/upload/v1738235465/mOXWUrIShsghrgx2xIJ5I6nIFcA3/20250130_164050_final-sub-1738235438.967802.mp4',
    ),
    VideoDetails(
      id: '003',
      name: 'Video Three',
      description: 'Description for Video Three',
      imageUrl:
          'https://th.bing.com/th/id/OIP.xGljq3ZFDLfF5jMV1kv5kwHaEJ?w=308&h=180&c=7&r=0&o=5&dpr=1.4&pid=1.7',
      videoUrl:
          'https://res.cloudinary.com/djc4fwyrc/video/upload/v1738163205/mOXWUrIShsghrgx2xIJ5I6nIFcA3/20250129_203644_final-sub-1738163193.7279887.mp4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        color: Colors.black87,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: videoList.length,
                itemBuilder: (context, index) {
                  return VideoContainer(videoDetails: videoList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoContainer extends StatefulWidget {
  final VideoDetails videoDetails;

  const VideoContainer({Key? key, required this.videoDetails})
      : super(key: key);

  @override
  _VideoContainerState createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {
  late VideoPlayerController _controller;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoDetails.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _shareVideo() async {
    try {
      setState(() => _isDownloading = true);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = '${widget.videoDetails.id}.mp4';
      final filePath = '${directory.path}/$fileName';

      // Download video file
      final response = await http.get(Uri.parse(widget.videoDetails.videoUrl));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Share video file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: widget.videoDetails.description,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing video: $e')),
      );
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.tealAccent),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
            IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _isDownloading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.tealAccent,
                        strokeWidth: 2,
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.share, color: Colors.tealAccent),
                      onPressed: _shareVideo,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoDetails {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String videoUrl;

  VideoDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
  });
}
