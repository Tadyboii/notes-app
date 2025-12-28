import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';

class NoteTileWidget extends StatelessWidget {
  const NoteTileWidget({
    required this.note,
    super.key,
    this.onTap,
    this.onLongPress,
  });

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.onInverseSurface,
      title: Text(
        note.title.isEmpty ? 'Untitled' : note.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(4),
          Text(
            note.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(6),
          Text(
            _formatDate(note.updatedAt ?? note.createdAt),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('MMM d, y • h:mm a').format(dateTime);
  }
}
