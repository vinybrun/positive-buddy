import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/backup_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../notifications/local_notification_service.dart';

/// Profile-page section that hangs the Backup / Restore UI off the side
/// of normal profile editing. The backup file is the dev safety net —
/// Android auto-backup covers the production case, this covers reinstalls
/// during iteration.
class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  bool _busy = false;
  String? _lastStatus;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final repo = ref.read(backupRepositoryProvider);
      final json = await repo.exportJson();
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final file = File('${dir.path}/positive_buddy_backup_$stamp.json');
      await file.writeAsString(json);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Positive Buddy backup',
        ),
      );
      if (mounted) setState(() => _lastStatus = 'Exported.');
    } catch (e) {
      if (mounted) setState(() => _lastStatus = 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final picked = await FilePicker.pickFile(type: FileType.any);
    if (picked == null) return;
    final path = picked.path;
    if (path == null) {
      setState(() => _lastStatus = 'Picked file has no path.');
      return;
    }
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
            'This wipes your current habits, logs, and profile and '
            'replaces them with the file you picked. There is no undo.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Restore')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(backupRepositoryProvider);
      final json = await File(path).readAsString();
      final result = await repo.importJson(json);
      // Rebuild the scheduling state after a successful restore — the new
      // habit rows need to land in the alarm queue.
      final notif = ref.read(localNotificationServiceProvider);
      final db = ref.read(appDbProvider);
      await notif.reconcile(db);
      if (mounted) setState(() => _lastStatus = result.toString());
    } on BackupFormatException catch (e) {
      if (mounted) setState(() => _lastStatus = e.message);
    } catch (e) {
      if (mounted) setState(() => _lastStatus = 'Restore failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Backup & restore', style: text.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Android already backs you up via Google Drive when you sign in. '
          'These buttons are the manual escape hatch — useful between '
          'reinstalls during development.',
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Export to JSON'),
            ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _import,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Restore from JSON'),
            ),
          ],
        ),
        if (_lastStatus != null) ...[
          const SizedBox(height: 8),
          Text(_lastStatus!,
              style:
                  text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
        ],
      ],
    );
  }
}
