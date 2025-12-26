import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_bloc.dart';

class EditNotePage extends StatefulWidget {
  const EditNotePage({super.key, this.note});

  final Note? note;

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      return;
    }

    if (widget.note != null) {
      context.read<NoteBloc>().add(
        NoteEvent.updateNote(
          Note(
            id: widget.note!.id,
            title: title,
            content: content,
          ),
        ),
      );
    } else {
      context.read<NoteBloc>().add(
        NoteEvent.addNote(
          Note(
            title: title,
            content: content,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _save();
            context.go('/');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(
                  color: Colors.white24,
                ),
                border: InputBorder.none,
              ),
            ),
            const Gap(16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Start typing',
                hintStyle: TextStyle(
                  color: Colors.white24,
                ),
                border: InputBorder.none,
                alignLabelWithHint: true,
              ),
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }
}
