import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/stakebook_provider.dart';
import '../utils/format.dart';

/// Add a bet (bet == null) or edit an existing one.
class BetFormScreen extends StatefulWidget {
  final String fundId;
  final Bet? bet;
  const BetFormScreen({super.key, required this.fundId, this.bet});

  @override
  State<BetFormScreen> createState() => _BetFormScreenState();
}

class _BetFormScreenState extends State<BetFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.bet?.title ?? '');
  late final _stake = TextEditingController(
      text: widget.bet == null ? '' : widget.bet!.stake.toString());
  late final _odds = TextEditingController(
      text: widget.bet == null ? '' : widget.bet!.odds.toString());
  late final _notes = TextEditingController(text: widget.bet?.notes ?? '');
  late BetStatus _status = widget.bet?.status ?? BetStatus.pending;
  late DateTime _date = widget.bet?.placedAt ?? DateTime.now();

  @override
  void dispose() {
    _title.dispose();
    _stake.dispose();
    _odds.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final p = context.read<StakebookProvider>();
    final stake = parseNumber(_stake.text)!;
    final odds = parseNumber(_odds.text)!;
    if (widget.bet == null) {
      p.addBet(Bet(
        id: p.newId(),
        fundId: widget.fundId,
        title: _title.text.trim(),
        stake: stake,
        odds: odds,
        status: _status,
        placedAt: _date,
        notes: _notes.text.trim(),
      ));
    } else {
      p.updateBet(widget.bet!.copyWith(
        title: _title.text.trim(),
        stake: stake,
        odds: odds,
        status: _status,
        placedAt: _date,
        notes: _notes.text.trim(),
      ));
    }
    Navigator.pop(context);
  }

  String? _positive(String? v) {
    final n = v == null ? null : parseNumber(v);
    return (n == null || n <= 0) ? 'Enter a number above 0' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bet == null ? 'New bet' : 'Edit bet'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  const InputDecoration(labelText: 'Bet (e.g. Team A to win)'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stake,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Stake'),
                    validator: _positive,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _odds,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Odds (decimal)'),
                    validator: (v) {
                      final n = v == null ? null : parseNumber(v);
                      return (n == null || n <= 1) ? 'Must be above 1' : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Result', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in BetStatus.values)
                  ChoiceChip(
                    label: Text(statusLabel(s)),
                    selected: _status == s,
                    onSelected: (_) => setState(() => _status = s),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(dateStr(_date)),
              subtitle: const Text('Date placed'),
              onTap: _pickDate,
            ),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
      ),
    );
  }
}
