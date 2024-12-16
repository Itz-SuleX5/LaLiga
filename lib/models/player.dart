class Player {
  final String id;
  final String name;
  final String imageUrl;
  final String position;
  final int overall;
  final String nationality;
  final String teamId;
  final int? weight;
  final int? height;
  bool isFavorite;

  Player({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.position,
    required this.overall,
    required this.nationality,
    required this.teamId,
    this.weight,
    this.height,
    this.isFavorite = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'].toString(),
      name: '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      imageUrl: json['avatarUrl'] ?? '',
      position: json['position']['shortLabel'] ?? '',
      overall: json['overallRating'] ?? 0,
      nationality: json['nationality']['label'] ?? '',
      teamId: json['team']['id'].toString(),
      weight: json['weight'],
      height: json['height'],
    );
  }
}
