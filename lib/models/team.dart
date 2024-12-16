import 'player.dart';

class Team {
  final String id;
  final String name;
  final String imageUrl;
  final String league;
  List<Player> players;

  Team({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.league,
    this.players = const [],
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'].toString(),
      name: json['label'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      league: json['league'] ?? '',
      players: [],
    );
  }

  void updatePlayers(List<Player> newPlayers) {
    players = newPlayers;
  }
}
