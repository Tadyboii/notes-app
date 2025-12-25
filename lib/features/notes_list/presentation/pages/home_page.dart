import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_bloc.dart';
import 'package:notes_app/features/notes_list/presentation/widget/note_dialog_widget.dart';
import 'package:notes_app/features/notes_list/presentation/widget/note_tile_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NoteListView();
  }
}

class _NoteListView extends StatelessWidget {
  const _NoteListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: false,
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          // if (state.isLoading) {
          //   return Center(
          //     child: CircularProgressIndicator(
          //       color: Theme.of(context).colorScheme.primary,
          //     ),
          //   );
          // }
          if (state.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          if (state.notes.isEmpty) {
            return Center(
              child: Text(
                'No notes available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              context.read<NoteBloc>().add(const NoteEvent.getAllNotes());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.notes.length,
              itemBuilder: (_, i) {
                final sortedNotes = List<Note>.from(
                  state.notes,
                )
                ..sort(
                  (a, b) => b.updatedAt!.compareTo(a.updatedAt!),
                );
                final note = sortedNotes[i];
                return NoteTileWidget(
                  note: note,
                  onDelete: () {
                    context.read<NoteBloc>().add(
                      NoteEvent.deleteNote(note.id!),
                    );
                  },
                  onTap: () => _openNoteDialog(context, note),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openNoteDialog(BuildContext context, [Note? note]) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<NoteBloc>(),
          child: NoteDialogWidget(note: note),
        );
      },
    );
  }
}
