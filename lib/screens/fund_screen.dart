import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/stakebook_provider.dart';
import '../utils/format.dart';
import '../widgets/fund_dialog.dart';
import 'bet_form_screen.dart';

class FundScreen extends StatelessWidget {
  final String fundId;
  const FundScreen({super.key, required this.fundId});

  Future<bool> _confirm(BuildContext context, String title, String body) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StakebookProvider>();
    final fund = p.funds.where((f) => f.id == fundId).firstOrNull;
    if (fund == null) return const Scaffold(); // deleted

    final bets = p.betsForFund(fundId)
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    final pl = bets.fold(0.0, (s, b) => s + b.profit);

    return Scaffold(
      appBar: AppBar(
        title: Text(fund.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit fund',
            onPressed: () => showDialog(
                context: context, builder: (_) => FundDialog(existing: fund)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete fund',
            onPressed: () async {
              final provider = context.read<StakebookProvider>();
              final ok = await _confirm(context, 'Delete fund?',
                  'This also deletes its ${bets.length} bet(s). This cannot be undone.');
              if (!ok || !context.mounted) return;
              Navigator.pop(context);
              await provider.deleteFund(fundId);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat('Balance', money(p.fundBalance(fund)), null),
                  _Stat('Started', money(fund.startingBalance), null),
                  _Stat('P/L', signed(pl), plColor(context, pl)),
                ],
              ),
            ),
          ),
          Expanded(
            child: bets.isEmpty
                ? const Center(child: Text('No bets yet. Tap + to add one.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: bets.length,
                    itemBuilder: (context, i) {
                      final b = bets[i];
                      return Dismissible(
                        key: ValueKey(b.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red.shade400,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) =>
                            _confirm(context, 'Delete bet?', b.title),
                        onDismissed: (_) =>
                            context.read<StakebookProvider>().deleteBet(b.id),
                        child: ListTile(
                          title: Text(b.title),
                          subtitle: Text(
                              '${money(b.stake)} @ ${b.odds} · ${dateStr(b.placedAt)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(signed(b.profit),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: plColor(context, b.profit))),
                              Text(statusLabel(b.status),
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    BetFormScreen(fundId: fundId, bet: b)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add bet',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BetFormScreen(fundId: fundId)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}
