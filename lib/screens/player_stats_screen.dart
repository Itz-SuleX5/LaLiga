import 'package:flutter/material.dart';
import '../models/player_stats.dart';
import '../services/player_stats_service.dart';

class PlayerStatsScreen extends StatefulWidget {
  final String playerId;
  final String playerName;

  const PlayerStatsScreen({
    Key? key, 
    required this.playerId,
    required this.playerName,
  }) : super(key: key);

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> {
  late Future<PlayerStats> playerStatsFuture;

  @override
  void initState() {
    super.initState();
    print('Initializing PlayerStatsScreen with ID: ${widget.playerId}');
    playerStatsFuture = PlayerStatsService.getPlayerStats(widget.playerId);
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSeasonStats(String season, SeasonStats stats) {
    return ExpansionTile(
      title: Text('Temporada $season'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStatItem('Equipo', stats.teamName),
              _buildStatItem('Goles', stats.goles.toString()),
              _buildStatItem('Asistencias', stats.asistencias.toString()),
              _buildStatItem('Tarjetas Amarillas', stats.tarjetasAmarillas.toString()),
              _buildStatItem('Tarjetas Rojas', stats.tarjetasRojas.toString()),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas de ${widget.playerName}'),
      ),
      body: FutureBuilder<PlayerStats>(
        future: playerStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar las estadísticas',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          playerStatsFuture = PlayerStatsService.getPlayerStats(widget.playerId);
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final stats = snapshot.data!;
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información General',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatItem('Valor de Mercado', 
                            '${stats.marketValue.toString()} ${stats.currency}'),
                          _buildStatItem('Edad', stats.age.toString()),
                          _buildStatItem('Altura', stats.height),
                          _buildStatItem('Peso', stats.weight),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estadísticas Totales',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatItem('Goles', stats.goles.toString()),
                          _buildStatItem('Asistencias', stats.asistencias.toString()),
                          _buildStatItem('Tarjetas Amarillas', 
                            stats.tarjetasAmarillas.toString()),
                          _buildStatItem('Tarjetas Rojas', 
                            stats.tarjetasRojas.toString()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Estadísticas por Temporada',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...stats.estadisticasPorTemporada.entries
                    .where((entry) => entry.value.teamName != "No participó en el equipo")
                    .map((entry) => Card(
                      child: _buildSeasonStats(entry.key, entry.value),
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 