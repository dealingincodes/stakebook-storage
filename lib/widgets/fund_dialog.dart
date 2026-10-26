import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/stakebook_provider.dart';
import '../utils/format.dart';

/// Add a fund (existing == null) or edit one.
class FundDialog extends StatefulWidget {
  final Fund? existing;
  const FundDialog({super.key, this.existing});

  @override
  State<FundDialog> createState() => _FundDialogState();
}

class _FundDialogState extends State<FundDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _balance = TextEditingController(
      text: widget.existing == null
          ? ''
          : widget.existing!.startingBalance.toString());

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final provider = context.read<StakebookProvider>();
    final name = _name.text.trim();
    final balance = parseNumber(_balance.text.isEmpty ? '0' : _balance.text)!;
    if (widget.existing == null) {
      provider.addFund(name, balance);
    } else {
      provider.updateFund(
          widget.existing!.copyWith(name: name, startingBalance: balance));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'New fund' : 'Edit fund'),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            TextFormField(
              controller: _balance,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Starting balance'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null; // = 0
                final n = parseNumber(v);
                return (n == null || n < 0) ? 'Enter a valid amount' : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
