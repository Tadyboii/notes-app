import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/core/di/injection_container.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/edit_note_bloc.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_list_bloc.dart';

class EditNotePage extends StatelessWidget {
  const EditNotePage({super.key, this.note});

  final Note? note;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditNoteBloc>(param1: note),
      child: const EditNoteView(),
    );
  }
}

class EditNoteView extends StatefulWidget {
  const EditNoteView({super.key});

  @override
  State<EditNoteView> createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    final state = context.read<EditNoteBloc>().state;
    _titleController = TextEditingController(text: state.titleDraft);
    _contentController = TextEditingController(text: state.contentDraft);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditNoteBloc, EditNoteState>(
      listenWhen: (prev, curr) =>
          !prev.isSaved && curr.isSaved || prev.isDeleting != curr.isDeleting,
      listener: (context, state) async {
        if (state.isDeleting) {
          context.read<NoteListBloc>().add(
            NoteListEvent.deleteNote(state.noteId),
          );
          Navigator.of(context).pop();
        }
        if (state.isSaved) {
          if (state.isNewNote) {
            context.read<EditNoteBloc>().add(
              EditNoteEvent.addNote(
                Note(
                  title: state.titleDraft,
                  content: state.contentDraft,
                ),
              ),
            );
          } else {
            context.read<EditNoteBloc>().add(
              EditNoteEvent.updateNote(
                Note(
                  id: state.noteId,
                  title: state.titleDraft,
                  content: state.contentDraft,
                ),
              ),
            );
          }
          context.read<EditNoteBloc>().add(
            const EditNoteEvent.resetState(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note saved'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: BlocBuilder<EditNoteBloc, EditNoteState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.isNewNote ? 'New Note' : 'Edit Note'),
              actions: [
                if (state.isEdited && !state.isEmpty)
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      context.read<EditNoteBloc>().add(
                        const EditNoteEvent.saveNote(),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<EditNoteBloc>().add(
                      const EditNoteEvent.deleteNote(),
                    );
                  },
                ),
              ],
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  final noteListState = context.read<NoteListBloc>().state;
                  if (noteListState.query.isEmpty) {
                    context.read<NoteListBloc>().add(
                      const NoteListEvent.getAllNotes(),
                    );
                  } else {
                    context.read<NoteListBloc>().add(
                      NoteListEvent.searchNotes(noteListState.query),
                    );
                  }
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsetsGeometry.only(left: 32, right: 32),
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                    controller: _titleController,
                    onChanged: (value) => context.read<EditNoteBloc>().add(
                      EditNoteEvent.titleChanged(value),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  TextField(
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    controller: _contentController,
                    onChanged: (value) => context.read<EditNoteBloc>().add(
                      EditNoteEvent.contentChanged(value),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start typing',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
