import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:minivid/models/music_models.dart';

class BGMPlayer extends StatefulWidget {
  final String initialCategory;

  const BGMPlayer({Key? key, this.initialCategory = 'Travel'})
      : super(key: key);

  @override
  _BGMPlayerState createState() => _BGMPlayerState();
}

class _BGMPlayerState extends State<BGMPlayer> {
  late String selectedCategory;
  AudioPlayer? audioPlayer;
  String? currentlyPlayingUrl;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
    audioPlayer = AudioPlayer(); // Properly initializing
  }

  void playMusic(String url) async {
    if (audioPlayer == null) return; // Prevent null errors

    if (currentlyPlayingUrl == url) {
      await audioPlayer!.pause();
      setState(() => currentlyPlayingUrl = null);
    } else {
      await audioPlayer!.play(UrlSource(url));
      setState(() => currentlyPlayingUrl = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350, // Ensures it's constrained to avoid infinite height issue
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: CategoryChips(
              initialCategory: selectedCategory,
              onCategoryChanged: (category) {
                setState(() => selectedCategory = category);
              },
            ),
          ),
          Flexible(
            // Allows dynamic resizing without overflow issues
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: MusicList(
                category: selectedCategory,
                playMusic: playMusic,
                currentlyPlayingUrl: currentlyPlayingUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer?.dispose();
    super.dispose();
  }
}

class CategoryChips extends StatelessWidget {
  final String initialCategory;
  final Function(String) onCategoryChanged;

  const CategoryChips({
    Key? key,
    required this.initialCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Travel',
      'Fitness',
      'Education',
      'Entertainment',
      'Nature'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == initialCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onCategoryChanged(category);
              },
              selectedColor: Colors.tealAccent,
              backgroundColor: Colors.grey[800],
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MusicList extends StatelessWidget {
  final String category;
  final Function(String) playMusic;
  final String? currentlyPlayingUrl;

  const MusicList({
    Key? key,
    required this.category,
    required this.playMusic,
    required this.currentlyPlayingUrl,
  }) : super(key: key);

  Future<List<MusicElement>> _loadMusicData(BuildContext context) async {
    try {
      String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/json/music.json');
      final jsonData = json.decode(jsonString);
      return (jsonData['music'] as List)
          .map((item) => MusicElement.fromJson(item))
          .toList();
    } catch (e) {
      print("Error loading music data: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MusicElement>>(
      future: _loadMusicData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.tealAccent));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text("No music found",
                  style: TextStyle(color: Colors.white)));
        }

        final musicList = snapshot.data!
            .where((music) => music.category == category)
            .toList();

        return ListView.builder(
          itemCount: musicList.length,
          itemBuilder: (context, index) {
            final music = musicList[index];
            final isPlaying = currentlyPlayingUrl == music.musicUrl;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    music.id.toString(),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  'Music ${music.id}',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.tealAccent,
                  ),
                  onPressed: () {
                    if (music.musicUrl != null) {
                      playMusic(music.musicUrl!);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
