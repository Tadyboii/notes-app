import 'package:flutter/material.dart';

import 'package:notes_app/features/notes_list/domain/entities/note.dart';

class NoteTileWidget extends StatelessWidget {

  const NoteTileWidget({required this.note, super.key, this.onTap, this.onDelete});
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(
        note.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
    );
  }
}
