import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/player_stats.dart';
import '../models/player_value_history.dart';

class PlayerStatsService {
  static const String baseUrl = 'https://api-samsung-devs-3158b0bedb61.herokuapp.com/api';
  
  static final Map<String, String> teamIds = {
    'FC Barcelona': '131',
    'Atlético de Madrid': '13',
    'Real Madrid': '418',
    'Rayo Vallecano': '367',
    'Athletic Club': '621',
    'Real Sociedad': '681',
    'Villarreal': '1050',
    'Real Betis': '150',
    'Mallorca': '237',
    'RC Celta': '940',
    'Valencia': '1049',
    'D. Alavés': '1108',
    'Las Palmas': '472',
    'Osasuna': '331',
    'Sevilla': '368',
    'Getafe': '3709',
    'Leganés': '1244',
    'Girona': '12321',
  };

  static Future<String?> getPlayerStatsId(String teamId, String playerName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/players/?team_id=$teamId&season_year=2024')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final players = data['players'] as Map<String, dynamic>;
        
        String normalizeText(String text) {
          return text
            .toLowerCase()
            .replaceAll(RegExp(r'[áàäâã]'), 'a')
            .replaceAll(RegExp(r'[éèëê]'), 'e')
            .replaceAll(RegExp(r'[íìïî]'), 'i')
            .replaceAll(RegExp(r'[óòöôõ]'), 'o')
            .replaceAll(RegExp(r'[úùüû]'), 'u')
            .replaceAll(RegExp(r'[ñ]'), 'n')
            .replaceAll(RegExp(r'[-]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        }

        final normalizedSearchName = normalizeText(playerName);
        print('Buscando jugador: "$playerName" (normalizado: "$normalizedSearchName")');
        print('Lista de jugadores disponibles:');
        players.forEach((key, value) {
          final normalizedName = normalizeText(value['name'].toString());
          print('- "${value['name']}" (normalizado: "$normalizedName")');
        });

        final playerEntry = players.entries.firstWhere(
          (entry) {
            final normalizedEntryName = normalizeText(entry.value['name'].toString());
            print('Comparando "$normalizedSearchName" con "$normalizedEntryName"');
            return normalizedEntryName == normalizedSearchName;
          },
          orElse: () => MapEntry('0', {'player_id': null}),
        );

        if (playerEntry.value['player_id'] == null) {
          print('No se encontró coincidencia exacta, buscando coincidencia parcial...');
          
          double calculateMatchScore(String searchName, String entryName) {
            final searchWords = searchName.split(' ');
            final entryWords = entryName.split(' ');
            
            double maxScore = 0;
            
            for (var searchWord in searchWords) {
              if (searchWord.length < 3) continue;
              
              for (var entryWord in entryWords) {
                if (entryWord.length < 3) continue;
                
                if (searchWord.startsWith(entryWord) || entryWord.startsWith(searchWord)) {
                  double wordScore = min(searchWord.length, entryWord.length) / 
                                   max(searchWord.length, entryWord.length);
                  maxScore = max(maxScore, wordScore);
                }
                
                int commonLength = longestCommonSubsequence(searchWord, entryWord);
                if (commonLength >= 4) {
                  double wordScore = commonLength / max(searchWord.length, entryWord.length);
                  maxScore = max(maxScore, wordScore);
                }
              }
            }
            
            return maxScore;
          }

          MapEntry<String, dynamic>? bestMatch;
          double bestMatchPercentage = 0;

          for (var entry in players.entries) {
            final normalizedEntryName = normalizeText(entry.value['name'].toString());
            print('Analizando: "$normalizedEntryName"');

            double matchScore = calculateMatchScore(normalizedSearchName, normalizedEntryName);
            print('Puntuación de coincidencia: ${(matchScore * 100).toStringAsFixed(1)}%');

            if (matchScore > bestMatchPercentage) {
              bestMatchPercentage = matchScore;
              bestMatch = entry;
            }
          }

          if (bestMatchPercentage >= 0.7) {
            print('Mejor coincidencia encontrada: ${bestMatch?.value['name']} con ${(bestMatchPercentage * 100).toStringAsFixed(1)}% de coincidencia');
            return bestMatch?.value['player_id']?.toString();
          }
          print('No se encontró una coincidencia suficientemente buena');
          return null;
        }

        print('Coincidencia exacta encontrada: ${playerEntry.value['name']}');
        return playerEntry.value['player_id']?.toString();
      }
      return null;
    } catch (e) {
      print('Error getting player stats ID: $e');
      return null;
    }
  }

  static Future<PlayerStats> getPlayerStats(String eaPlayerId, String playerName, String teamName) async {
    try {
      final teamId = teamIds[teamName];
      if (teamId == null) {
        throw Exception('No se encontró el ID para el equipo: $teamName');
      }
      final statsPlayerId = await getPlayerStatsId(teamId, playerName);
      
      if (statsPlayerId == null) {
        throw Exception('No se encontró el ID de estadísticas para el jugador: $playerName');
      }

      final url = '$baseUrl/player-info/$statsPlayerId/?team_id=$teamId&season_year=2024';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return PlayerStats.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load player stats: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching player stats: $e');
      rethrow;
    }
  }

  static int longestCommonSubsequence(String str1, String str2) {
    int maxLength = 0;
    for (int i = 0; i < str1.length; i++) {
      for (int j = 0; j < str2.length; j++) {
        int currentLength = 0;
        while (i + currentLength < str1.length && 
               j + currentLength < str2.length && 
               str1[i + currentLength] == str2[j + currentLength]) {
          currentLength++;
        }
        if (currentLength > maxLength) {
          maxLength = currentLength;
        }
      }
    }
    return maxLength;
  }

  static Future<PlayerValueHistory> getPlayerValueHistory(String playerId) async {
    print('Obteniendo historial para jugador ID: $playerId');
    final url = '$baseUrl/player-history-info/?player_id=$playerId';
    
    try {
      final response = await http.get(Uri.parse(url));
      print('Respuesta del historial: ${response.statusCode}');
      print('Contenido: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return PlayerValueHistory.fromJson(jsonList);
      } else {
        throw Exception('Failed to load player value history');
      }
    } catch (e) {
      print('Error fetching player value history: $e');
      rethrow;
    }
  }
} 