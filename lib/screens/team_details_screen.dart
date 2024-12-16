import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../services/team_service.dart';
import '../services/player_stats_service.dart';
import '../models/player_stats.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/player_value_history.dart';
import '../utils/country_translations.dart';

class TeamDetailsScreen extends StatefulWidget {
  final Team team;

  const TeamDetailsScreen({Key? key, required this.team}) : super(key: key);

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  List<Player> players = [];
  bool isLoading = true;
  String? selectedPosition;
  Future<PlayerStats>? playerStatsFuture;
  Future<PlayerValueHistory>? playerValueHistoryFuture;

  @override
  void initState() {
    super.initState();
    loadPlayers();
  }

  Future<void> loadPlayers() async {
    setState(() => isLoading = true);
    try {
      final teamPlayers = await TeamService.getTeamPlayers(widget.team.id);
      setState(() {
        players = teamPlayers;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los jugadores: $e')),
      );
    }
  }

  List<Player> getFilteredPlayers() {
    if (selectedPosition == null) return players;
    return players.where((player) => player.position == selectedPosition).toList();
  }

  void _showPlayerDetails(Player player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          playerStatsFuture = PlayerStatsService.getPlayerStats(
            player.id,
            player.name,
            widget.team.name,
          );
          playerStatsFuture?.then((stats) {
            setState(() {
              playerValueHistoryFuture = PlayerStatsService.getPlayerValueHistory(stats.playerId);
            });
          });
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      Hero(
                        tag: 'player-${player.id}',
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(player.imageUrl),
                              fit: BoxFit.contain,
                              onError: (e, s) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoChip(player.position, Icons.sports_soccer),
                          const SizedBox(width: 8),
                          _buildInfoChip(CountryTranslations.translate(player.nationality), Icons.flag),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  player.overall.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FutureBuilder<PlayerStats>(
                        future: playerStatsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error al cargar estadísticas: ${snapshot.error}'),
                            );
                          }
                          
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }
                          
                          final stats = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatsGrid([
                                StatsItem('Edad', '${stats.age}'),
                                StatsItem('Altura', stats.height),
                                StatsItem('Peso', player.weight != null ? '${player.weight} kg' : 'Desconocido'),
                                StatsItem('Valor', '${(stats.marketValue/1000000).round()}M Eur'),
                                StatsItem('Goles', '${stats.goles}'),
                                StatsItem('Asistencias', '${stats.asistencias}'),
                              ]),
                              const SizedBox(height: 24),
                              _buildGeneralStatsChart(stats),
                              const SizedBox(height: 24),
                              FutureBuilder<PlayerValueHistory>(
                                future: playerValueHistoryFuture,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return const SizedBox();
                                  
                                  return _buildValueHistoryChart(snapshot.data!);
                                },
                              ),
                              _buildStatChart(
                                stats.estadisticasPorTemporada,
                                'Goles por Temporada',
                                Colors.blue,
                                (stats) => stats.goles,
                              ),
                              _buildStatChart(
                                stats.estadisticasPorTemporada,
                                'Asistencias por Temporada',
                                Colors.purple,
                                (stats) => stats.asistencias,
                              ),
                              _buildStatChart(
                                stats.estadisticasPorTemporada,
                                'Goles en Propia por Temporada',
                                Colors.red,
                                (stats) => stats.golesEnPropia,
                              ),
                              _buildStatChart(
                                stats.estadisticasPorTemporada,
                                'Tarjetas Amarillas por Temporada',
                                Colors.amber,
                                (stats) => stats.tarjetasAmarillas,
                              ),
                              _buildStatChart(
                                stats.estadisticasPorTemporada,
                                'Tarjetas Rojas por Temporada',
                                Colors.red[900]!,
                                (stats) => stats.tarjetasRojas,
                              ),
                              _buildStatChart(
                                stats.estadisticasPorTemporada,
                                'Tarjetas Roja-Amarillas por Temporada',
                                Colors.orange,
                                (stats) => stats.tarjetasRojasAmarillas,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(List<StatsItem> items) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      children: items.map((item) => _buildStatItem(item)).toList(),
    );
  }

  Widget _buildStatItem(StatsItem item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChart(
    Map<String, SeasonStats> stats,
    String title,
    Color color,
    int Function(SeasonStats) getValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: stats.values.map((s) => getValue(s)).reduce((a, b) => a > b ? a : b).toDouble() + 2,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                  left: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: stats.entries.map((entry) {
                return BarChartGroupData(
                  x: int.parse(entry.key),
                  barRods: [
                    BarChartRodData(
                      toY: getValue(entry.value).toDouble(),
                      color: color,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralStatsChart(PlayerStats stats) {
    final data = [
      StatData('Goles', stats.goles, Colors.blue),
      StatData('Asistencias', stats.asistencias, Colors.purple),
      StatData('Goles Propia', stats.golesEnPropia, Colors.red),
      StatData('T. Amarillas', stats.tarjetasAmarillas, Colors.amber),
      StatData('T. Rojas', stats.tarjetasRojas, Colors.red[900]!),
      StatData('T. Roja-Am.', stats.tarjetasRojasAmarillas, Colors.orange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas Generales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: data.map((d) => d.value).reduce((a, b) => a > b ? a : b).toDouble() + 2,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= data.length) return const SizedBox();
                      return Transform.rotate(
                        angle: -0.5,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            data[value.toInt()].label,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                  left: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: List.generate(
                data.length,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data[index].value.toDouble(),
                      color: data[index].color,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueHistoryChart(PlayerValueHistory history) {
    final valoresPorTemporada = history.getValoresPorTemporada();
    
    if (valoresPorTemporada.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial de Valor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'No hay datos históricos disponibles',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Valor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: valoresPorTemporada.values.reduce((a, b) => a > b ? a : b).toDouble() + 2000000,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= valoresPorTemporada.length) {
                        return const SizedBox();
                      }
                      final year = valoresPorTemporada.keys.elementAt(value.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          year,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value/1000000).toStringAsFixed(0)}M',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                  left: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5000000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: valoresPorTemporada.entries.map((entry) {
                return BarChartGroupData(
                  x: valoresPorTemporada.keys.toList().indexOf(entry.key),
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      color: Colors.green,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${(rod.toY/1000000).toStringAsFixed(0)}M',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String position) {
              setState(() {
                selectedPosition = position == 'Todos' ? null : position;
              });
            },
            itemBuilder: (BuildContext context) {
              final positions = ['Todos', ...players.map((p) => p.position).toSet()];
              return positions.map((String position) {
                return PopupMenuItem<String>(
                  value: position,
                  child: Text(position),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: getFilteredPlayers().length,
              itemBuilder: (context, index) {
                final player = getFilteredPlayers()[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Hero(
                      tag: 'player-${player.id}',
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(player.imageUrl),
                        onBackgroundImageError: (e, s) => const Icon(Icons.error),
                      ),
                    ),
                    title: Text(player.name),
                    subtitle: Text(
                      '${player.position} - ${CountryTranslations.translate(player.nationality)}',
                    ),
                    trailing: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(17.5),
                      ),
                      child: Center(
                        child: Text(
                          player.overall.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    onTap: () => _showPlayerDetails(player),
                  ),
                );
              },
            ),
    );
  }
}

class StatsItem {
  final String label;
  final String value;

  StatsItem(this.label, this.value);
}

class StatData {
  final String label;
  final int value;
  final Color color;

  StatData(this.label, this.value, this.color);
}
