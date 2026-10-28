import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/backup_service.dart';

/// Dialog previewing or restoring JSON backups.
class BackupRestoreDialog extends StatefulWidget {
  const BackupRestoreDialog({super.key});

  @override
  State<BackupRestoreDialog> createState() => _BackupRestoreDialogState();
}

class _BackupRestoreDialogState extends State<BackupRestoreDialog> {
  int _selectedTab = 0; // 0 = Export Backup, 1 = Import Backup
  String _exportedJson = 'Generating backup...';
  final TextEditingController _importController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExport();
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _loadExport() async {
    final jsonStr = await BackupService.exportBackupJson();
    if (mounted) {
      setState(() {
        _exportedJson = jsonStr;
      });
    }
  }

  Future<void> _performRestore() async {
    final text = _importController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste a valid JSON backup text first.')),
      );
      return;
    }

    final success = await BackupService.restoreBackupJson(text);
    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data backup restored successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to restore backup. Invalid JSON payload.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.cloud_sync, color: Colors.indigo),
          SizedBox(width: 10),
          Text('Backup & Restore Data'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Export Payload'), icon: Icon(Icons.download)),
                ButtonSegment(value: 1, label: Text('Import & Restore'), icon: Icon(Icons.upload)),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (val) => setState(() => _selectedTab = val.first),
            ),
            const SizedBox(height: 16),
            if (_selectedTab == 0)
              Container(
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(_exportedJson, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                ),
              )
            else
              TextField(
                controller: _importController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Paste your exported JSON backup code here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_selectedTab == 0)
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _exportedJson));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON Backup copied to clipboard!'), behavior: SnackBarBehavior.floating),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy JSON'),
          )
        else
          FilledButton.icon(
            onPressed: _performRestore,
            icon: const Icon(Icons.restore),
            label: const Text('Restore Data'),
          ),
      ],
    );
  }
}
