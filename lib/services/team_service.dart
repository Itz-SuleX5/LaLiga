import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';

class TeamService {
  static const String baseUrl = 'https://drop-api.ea.com/rating/fc-24';

  static Future<Map<String, dynamic>?> searchPlayerDetails(String playerName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?limit=100&search=${Uri.encodeComponent(playerName)}'),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data['items'] as List).cast<Map<String, dynamic>>();
        if (items.isNotEmpty) {
          for (var item in items) {
            final fullName = '${item['firstName'] ?? ''} ${item['lastName'] ?? ''}'.trim();
            if (fullName.toLowerCase() == playerName.toLowerCase()) {
              return item;
            }
          }
          return items.first;
        }
      }
      return null;
    } catch (e) {
      print('Error searching player details: $e');
      return null;
    }
  }

  static Future<List<Player>> getTeamPlayers(String teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?limit=100&team=$teamId'),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        final players = <Player>[];
        
        for (var json in items) {
          final playerName = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
          print('Buscando detalles para: $playerName');
          final detailedInfo = await searchPlayerDetails(playerName);
          print('Detalles encontrados: ${detailedInfo?['weight']} kg, ${detailedInfo?['height']} cm');
          
          players.add(Player(
            id: json['id'].toString(),
            name: playerName,
            imageUrl: json['avatarUrl'] ?? '',
            position: json['position']['shortLabel'] ?? '',
            overall: json['overallRating'] ?? 0,
            nationality: json['nationality']['label'] ?? '',
            teamId: json['team']['id'].toString(),
            weight: detailedInfo?['weight'],
            height: detailedInfo?['height'],
          ));
        }
        
        return players;
      } else {
        throw Exception('Failed to load players: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching players: $e');
      return [];
    }
  }
}
