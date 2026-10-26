import 'dart:convert';

enum BetStatus { pending, won, lost, voided }

class Fund {
  final String id;
  final String name;
  final double startingBalance;
  final DateTime createdAt;

  const Fund({
    required this.id,
    required this.name,
    required this.startingBalance,
    required this.createdAt,
  });

  Fund copyWith({String? name, double? startingBalance}) => Fund(
        id: id,
        name: name ?? this.name,
        startingBalance: startingBalance ?? this.startingBalance,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startingBalance': startingBalance,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Fund.fromJson(Map<String, dynamic> j) => Fund(
        id: j['id'] as String,
        name: j['name'] as String,
        startingBalance: (j['startingBalance'] as num).toDouble(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class Bet {
  final String id;
  final String fundId;
  final String title;
  final double stake;
  final double odds; // decimal odds, e.g. 1.85
  final BetStatus status;
  final DateTime placedAt;
  final String notes;

  const Bet({
    required this.id,
    required this.fundId,
    required this.title,
    required this.stake,
    required this.odds,
    required this.status,
    required this.placedAt,
    this.notes = '',
  });

  /// Net profit/loss for this bet (0 while pending or voided).
  double get profit {
    switch (status) {
      case BetStatus.won:
        return stake * (odds - 1);
      case BetStatus.lost:
        return -stake;
      case BetStatus.pending:
      case BetStatus.voided:
        return 0;
    }
  }

  Bet copyWith({
    String? fundId,
    String? title,
    double? stake,
    double? odds,
    BetStatus? status,
    DateTime? placedAt,
    String? notes,
  }) =>
      Bet(
        id: id,
        fundId: fundId ?? this.fundId,
        title: title ?? this.title,
        stake: stake ?? this.stake,
        odds: odds ?? this.odds,
        status: status ?? this.status,
        placedAt: placedAt ?? this.placedAt,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fundId': fundId,
        'title': title,
        'stake': stake,
        'odds': odds,
        'status': status.name,
        'placedAt': placedAt.toIso8601String(),
        'notes': notes,
      };

  factory Bet.fromJson(Map<String, dynamic> j) => Bet(
        id: j['id'] as String,
        fundId: j['fundId'] as String,
        title: j['title'] as String,
        stake: (j['stake'] as num).toDouble(),
        odds: (j['odds'] as num).toDouble(),
        status: BetStatus.values.byName(j['status'] as String),
        placedAt: DateTime.parse(j['placedAt'] as String),
        notes: (j['notes'] as String?) ?? '',
      );
}

/// The complete persisted state: funds + bets.
class AppData {
  static const int schemaVersion = 1;

  final List<Fund> funds;
  final List<Bet> bets;

  const AppData({this.funds = const [], this.bets = const []});

  static const AppData empty = AppData();

  Map<String, dynamic> toJson() => {
        'app': 'stakebook',
        'version': schemaVersion,
        'funds': funds.map((f) => f.toJson()).toList(),
        'bets': bets.map((b) => b.toJson()).toList(),
      };

  String toJsonString() => jsonEncode(toJson());

  /// Parses and validates. Throws [FormatException] on anything invalid.
  factory AppData.parse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Root is not a JSON object');
      }
      final version = decoded['version'];
      if (version is! int || version > schemaVersion) {
        throw const FormatException('Unsupported data version');
      }
      final funds = (decoded['funds'] as List)
          .map((e) => Fund.fromJson(e as Map<String, dynamic>))
          .toList();
      final bets = (decoded['bets'] as List)
          .map((e) => Bet.fromJson(e as Map<String, dynamic>))
          .toList();

      final fundIds = funds.map((f) => f.id).toSet();
      if (fundIds.length != funds.length) {
        throw const FormatException('Duplicate fund ids');
      }
      if (bets.map((b) => b.id).toSet().length != bets.length) {
        throw const FormatException('Duplicate bet ids');
      }
      if (bets.any((b) => !fundIds.contains(b.fundId))) {
        throw const FormatException('Bet references a missing fund');
      }
      return AppData(funds: funds, bets: bets);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid or corrupt Stakebook data');
    }
  }
}
