class PlayerListResponse {
  final String teamId;
  final String seasonYear;
  final Map<String, PlayerBasicInfo> players;

  PlayerListResponse({
    required this.teamId,
    required this.seasonYear,
    required this.players,
  });

  factory PlayerListResponse.fromJson(Map<String, dynamic> json) {
    final playersMap = json['players'] as Map<String, dynamic>;
    final players = playersMap.map((key, value) => MapEntry(
      key,
      PlayerBasicInfo.fromJson(value as Map<String, dynamic>),
    ));

    return PlayerListResponse(
      teamId: json['team_id'],
      seasonYear: json['season_year'],
      players: players,
    );
  }
}

class PlayerBasicInfo {
  final String playerId;
  final String name;
  final String position;
  final int marketValue;
  final String currency;

  PlayerBasicInfo({
    required this.playerId,
    required this.name,
    required this.position,
    required this.marketValue,
    required this.currency,
  });

  factory PlayerBasicInfo.fromJson(Map<String, dynamic> json) {
    return PlayerBasicInfo(
      playerId: json['player_id'],
      name: json['name'],
      position: json['position'],
      marketValue: json['marketValue'],
      currency: json['currency'],
    );
  }
} 