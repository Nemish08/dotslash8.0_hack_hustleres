import 'dart:convert';

Music musicFromJson(String str) => Music.fromJson(json.decode(str));

String musicToJson(Music data) => json.encode(data.toJson());

class Music {
  final List<MusicElement>? music;

  Music({
    this.music,
  });

  factory Music.fromJson(Map<String, dynamic> json) => Music(
        music: json["music"] == null
            ? []
            : List<MusicElement>.from(
                json["music"]!.map((x) => MusicElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "music": music == null
            ? []
            : List<dynamic>.from(music!.map((x) => x.toJson())),
      };
}

class MusicElement {
  final String? id;
  final String? category;
  final String? musicUrl;

  MusicElement({
    this.id,
    this.category,
    this.musicUrl,
  });

  factory MusicElement.fromJson(Map<String, dynamic> json) => MusicElement(
        id: json["id"],
        category: json["category"],
        musicUrl: json["music_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category": category,
        "music_url": musicUrl,
      };
}
