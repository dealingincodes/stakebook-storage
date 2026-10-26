import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models.dart';
import '../state/stakebook_provider.dart';

class BackupService {
  /// Writes JSON to a temp file and opens the share sheet
  /// (user can save to Downloads, Drive, etc.).
  static Future<void> exportBackup(BuildContext context) async {
    final provider = context.read<StakebookProvider>();
    try {
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final file = File('${dir.path}/stakebook_backup_$stamp.json');
      await file.writeAsString(provider.snapshot.toJsonString(), flush: true);

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Stakebook backup',
      ));
    } catch (e) {
      if (context.mounted) _snack(context, 'Backup failed: $e');
    }
  }

  /// Pick JSON -> validate -> confirm -> replace current data.
  static Future<void> restoreBackup(BuildContext context) async {
    final provider = context.read<StakebookProvider>();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return; // cancelled

      final picked = result.files.single;
      final String raw;
      if (picked.bytes != null) {
        raw = utf8.decode(picked.bytes!);
      } else if (picked.path != null) {
        raw = await File(picked.path!).readAsString();
      } else {
        throw const FormatException('Could not read the selected file');
      }

      final data = AppData.parse(raw); // throws FormatException if invalid

      if (!context.mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Replace all data?'),
          content: Text(
            'This backup contains ${data.funds.length} fund(s) and '
            '${data.bets.length} bet(s).\n\n'
            'Your current data (${provider.funds.length} fund(s), '
            '${provider.bets.length} bet(s)) will be permanently replaced.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Replace')),
          ],
        ),
      );
      if (ok != true) return;

      await provider.replaceAll(data);
      if (context.mounted) _snack(context, 'Backup restored');
    } on FormatException catch (e) {
      if (context.mounted) _snack(context, 'Invalid backup: ${e.message}');
    } catch (e) {
      if (context.mounted) _snack(context, 'Restore failed: $e');
    }
  }

  static void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
