import 'package:flutter/material.dart';
import '../services/financial_health_service.dart';

/// Modal dialog showcasing the Gamification Achievement Badges gallery.
class BadgesDialog extends StatelessWidget {
  final List<AchievementBadge> badges;

  const BadgesDialog({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.amber),
          SizedBox(width: 10),
          Text('Achievement Badges'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final opacity = badge.isUnlocked ? 1.0 : 0.4;

            return Opacity(
              opacity: opacity,
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: badge.color.withValues(alpha: 0.2),
                    child: Icon(badge.icon, color: badge.color),
                  ),
                  title: Text(
                    badge.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(badge.description, style: const TextStyle(fontSize: 12)),
                  trailing: badge.isUnlocked
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.lock_outline, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
