class PlayerStats {
  final String playerId;
  final String name;
  final String position;
  final int marketValue;
  final String currency;
  final int age;
  final String height;
  final String weight;
  final int goles;
  final int asistencias;
  final int golesEnPropia;
  final int tarjetasAmarillas;
  final int tarjetasRojas;
  final int tarjetasRojasAmarillas;
  final Map<String, SeasonStats> estadisticasPorTemporada;

  PlayerStats({
    required this.playerId,
    required this.name,
    required this.position,
    required this.marketValue,
    required this.currency,
    required this.age,
    required this.height,
    required this.weight,
    required this.goles,
    required this.asistencias,
    required this.golesEnPropia,
    required this.tarjetasAmarillas,
    required this.tarjetasRojas,
    required this.tarjetasRojasAmarillas,
    required this.estadisticasPorTemporada,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    final estadisticas = json['estadisticas'] as Map<String, dynamic>;
    final estadisticasPorTemporada = json['estadisticas_por_temporada'] as Map<String, dynamic>;
    
    return PlayerStats(
      playerId: estadisticas['player_id'],
      name: estadisticas['name'],
      position: estadisticas['position'],
      marketValue: estadisticas['marketValue'],
      currency: estadisticas['currency'],
      age: int.parse(estadisticas['age'].toString()),
      height: estadisticas['height'],
      weight: estadisticas['weight'] == 'Unknown' ? 'Desconocido' : estadisticas['weight'],
      goles: estadisticas['goles'],
      asistencias: estadisticas['asistencias'],
      golesEnPropia: estadisticas['goles_en_propia'],
      tarjetasAmarillas: estadisticas['tarjetas_amarillas'],
      tarjetasRojas: estadisticas['tarjetas_rojas'],
      tarjetasRojasAmarillas: estadisticas['tarjetas_rojasamarillas'],
      estadisticasPorTemporada: Map.fromEntries(
        estadisticasPorTemporada.entries.map(
          (e) => MapEntry(e.key, SeasonStats.fromJson(e.value as Map<String, dynamic>))
        ),
      ),
    );
  }
}

class SeasonStats {
  final int goles;
  final int asistencias;
  final int golesEnPropia;
  final int tarjetasAmarillas;
  final int tarjetasRojas;
  final int tarjetasRojasAmarillas;
  final String teamName;

  SeasonStats({
    required this.goles,
    required this.asistencias,
    required this.golesEnPropia,
    required this.tarjetasAmarillas,
    required this.tarjetasRojas,
    required this.tarjetasRojasAmarillas,
    required this.teamName,
  });

  factory SeasonStats.fromJson(Map<String, dynamic> json) {
    return SeasonStats(
      goles: json['goles'],
      asistencias: json['asistencias'],
      golesEnPropia: json['goles_en_propia'],
      tarjetasAmarillas: json['tarjetas_amarillas'],
      tarjetasRojas: json['tarjetas_rojas'],
      tarjetasRojasAmarillas: json['tarjetas_rojasamarillas'],
      teamName: json['team_name'],
    );
  }
} 