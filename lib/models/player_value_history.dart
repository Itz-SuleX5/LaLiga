class PlayerValueHistory {
  final List<ValueHistoryEntry> historialValor;

  PlayerValueHistory({
    required this.historialValor,
  });

  factory PlayerValueHistory.fromJson(List<dynamic> json) {
    final historialValor = json.map((item) => ValueHistoryEntry.fromJson(item)).toList();
    return PlayerValueHistory(historialValor: historialValor);
  }

  Map<String, int> getValoresPorTemporada() {
    final filteredHistory = historialValor
      .where((entry) {
        final year = int.tryParse(entry.seasonID.split('/').first);
        return year != null && year >= 17;
      })
      .toList()
      ..sort((a, b) => b.seasonID.compareTo(a.seasonID));
    
    return Map.fromEntries(
      filteredHistory.map((entry) => MapEntry(entry.seasonID, entry.marketValue))
    );
  }
}

class ValueHistoryEntry {
  final String age;
  final int marketValue;
  final String currency;
  final String clubName;
  final String clubImage;
  final String seasonID;

  ValueHistoryEntry({
    required this.age,
    required this.marketValue,
    required this.currency,
    required this.clubName,
    required this.clubImage,
    required this.seasonID,
  });

  factory ValueHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ValueHistoryEntry(
      age: json['age'],
      marketValue: json['marketValueUnformatted'],
      currency: json['marketValueCurrency'],
      clubName: json['clubName'],
      clubImage: json['clubImage'],
      seasonID: json['seasonID'],
    );
  }
} 