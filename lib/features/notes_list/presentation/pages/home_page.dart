import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_bloc.dart';
import 'package:notes_app/features/notes_list/presentation/widget/note_tile_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes'), centerTitle: false),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (state.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          } else if (state.notes.isEmpty) {
            return Center(
              child: Text(
                'No notes available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          } else {
            return RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: () async {
                context.read<NoteBloc>().add(const NoteEvent.getAllNotes());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notes.length,
                itemBuilder: (_, i) {
                  return NoteTileWidget(
                    note: state.notes[i],
                    onDelete: () {
                      context.read<NoteBloc>().add(
                        NoteEvent.deleteNote(state.notes[i].id!),
                      );
                    },
                    onTap: () => _showNoteDialog(context, state.notes[i]),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, [Note? note]) {
    final noteController = TextEditingController();
    final titleController = TextEditingController();
    noteController.text = note?.content ?? '';
    titleController.text = note?.title ?? '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Write Note'),
        content: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Enter title'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'Enter your note here',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = noteController.text.trim();
              if (title.isEmpty && content.isEmpty) {
                Navigator.pop(context);
                return;
              }
              if (note != null) {
                final updatedNote = Note(
                  id: note.id,
                  title: titleController.text,
                  content: noteController.text,
                );
                context.read<NoteBloc>().add(NoteEvent.updateNote(updatedNote));
              } else {
                final newNote = Note(
                  title: titleController.text,
                  content: noteController.text,
                );
                context.read<NoteBloc>().add(NoteEvent.addNote(newNote));
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
