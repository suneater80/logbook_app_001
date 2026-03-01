import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTimestamp(DateTime ts) {
    final day = ts.day.toString().padLeft(2, '0');
    final month = ts.month.toString().padLeft(2, '0');
    final year = ts.year.toString();
    final hour = ts.hour.toString().padLeft(2, '0');
    final minute = ts.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Color _categoryColor(BuildContext context, String category) {
    final colors = Theme.of(context).colorScheme;
    switch (category) {
      case 'Pekerjaan':
        return Colors.blue.shade50;
      case 'Urgent':
        return Colors.red.shade50;
      case 'Pribadi':
      default:
        return colors.secondaryContainer.withValues(alpha: 0.35);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _categoryColor(context, log.category),
      child: ListTile(
        title: Text(
          log.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(log.description),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withValues(alpha: 0.06),
              ),
              child: Text(
                log.category,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatTimestamp(log.timestamp),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Hapus',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
