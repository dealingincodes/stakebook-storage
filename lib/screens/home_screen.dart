import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../services/backup_service.dart';
import '../state/stakebook_provider.dart';
import '../utils/format.dart';
import '../widgets/fund_dialog.dart';
import 'fund_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StakebookProvider>();
    final totalPl = p.bets.fold(0.0, (s, b) => s + b.profit);
    final won = p.bets.where((b) => b.status == BetStatus.won).length;
    final lost = p.bets.where((b) => b.status == BetStatus.lost).length;
    final settled = won + lost;
    final winRate = settled == 0 ? '-' : '${(won / settled * 100).round()}%';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stakebook'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'backup') BackupService.exportBackup(context);
              if (v == 'restore') BackupService.restoreBackup(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'backup', child: Text('Backup data')),
              PopupMenuItem(value: 'restore', child: Text('Restore data')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat('Total P/L', signed(totalPl), plColor(context, totalPl)),
                  _Stat('Bets', '${p.bets.length}', null),
                  _Stat('Win rate', winRate, null),
                ],
              ),
            ),
          ),
          if (p.funds.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                  child: Text('No funds yet. Tap "Fund" to create your first.')),
            ),
          for (final f in p.funds)
            ListTile(
              title: Text(f.name),
              subtitle: Text(
                  '${p.betsForFund(f.id).length} bets · started at ${money(f.startingBalance)}'),
              trailing: Text(money(p.fundBalance(f)),
                  style: Theme.of(context).textTheme.titleMedium),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FundScreen(fundId: f.id)),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
            context: context, builder: (_) => const FundDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Fund'),
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
