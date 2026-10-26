import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../services/storage_service.dart';

class StakebookProvider extends ChangeNotifier {
  StakebookProvider(this._storage);

  final StorageService _storage;
  final List<Fund> _funds = [];
  final List<Bet> _bets = [];
  bool _loaded = false;

  bool get loaded => _loaded;
  UnmodifiableListView<Fund> get funds => UnmodifiableListView(_funds);
  UnmodifiableListView<Bet> get bets => UnmodifiableListView(_bets);

  AppData get snapshot =>
      AppData(funds: List.of(_funds), bets: List.of(_bets));

  List<Bet> betsForFund(String fundId) =>
      _bets.where((b) => b.fundId == fundId).toList();

  double fundBalance(Fund f) =>
      f.startingBalance +
      _bets.where((b) => b.fundId == f.id).fold(0.0, (s, b) => s + b.profit);

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ---- load ----
  Future<void> load() async {
    final data = await _storage.load();
    _funds
      ..clear()
      ..addAll(data.funds);
    _bets
      ..clear()
      ..addAll(data.bets);
    _loaded = true;
    notifyListeners();
  }

  // ---- funds ----
  Future<void> addFund(String name, double startingBalance) async {
    _funds.add(Fund(
      id: newId(),
      name: name,
      startingBalance: startingBalance,
      createdAt: DateTime.now(),
    ));
    await _commit();
  }

  Future<void> updateFund(Fund updated) async {
    final i = _funds.indexWhere((f) => f.id == updated.id);
    if (i == -1) return;
    _funds[i] = updated;
    await _commit();
  }

  /// Deleting a fund also deletes its bets.
  Future<void> deleteFund(String id) async {
    _funds.removeWhere((f) => f.id == id);
    _bets.removeWhere((b) => b.fundId == id);
    await _commit();
  }

  // ---- bets ----
  Future<void> addBet(Bet bet) async {
    _bets.add(bet);
    await _commit();
  }

  Future<void> updateBet(Bet updated) async {
    final i = _bets.indexWhere((b) => b.id == updated.id);
    if (i == -1) return;
    _bets[i] = updated;
    await _commit();
  }

  Future<void> deleteBet(String id) async {
    _bets.removeWhere((b) => b.id == id);
    await _commit();
  }

  // ---- restore ----
  Future<void> replaceAll(AppData data) async {
    _funds
      ..clear()
      ..addAll(data.funds);
    _bets
      ..clear()
      ..addAll(data.bets);
    await _commit();
  }

  // Serialize the full state after every change.
  Future<void> _commit() async {
    notifyListeners();
    await _storage.save(snapshot);
  }
}
