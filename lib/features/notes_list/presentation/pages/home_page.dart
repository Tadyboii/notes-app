import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_list_bloc.dart';
import 'package:notes_app/features/notes_list/presentation/pages/edit_note_page.dart';
import 'package:notes_app/features/notes_list/presentation/widget/note_search_bar_widget.dart';
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          centerTitle: false,
        ),
        body: Column(
          children: [
            BlocBuilder<NoteListBloc, NoteListState>(
              builder: (context, state) {
                return NoteSearchBarWidget(
                  query: state.query,
                  onSearchChanged: (query) {
                    context.read<NoteListBloc>().add(
                      NoteListEvent.searchNotes(query),
                    );
                  },
                );
              },
            ),
            Expanded(
              child: BlocBuilder<NoteListBloc, NoteListState>(
                builder: (context, state) {
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
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () async {
                      if (state.query.isEmpty) {
                        context.read<NoteListBloc>().add(
                          const NoteListEvent.getAllNotes(),
                        );
                      } else {
                        context.read<NoteListBloc>().add(
                          NoteListEvent.searchNotes(state.query),
                        );
                      }
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      itemCount: state.notes.length,
                      itemBuilder: (_, i) {
                        final note = state.notes[i];
                        return OpenContainer(
                          closedBuilder: (context, action) {
                            return NoteTileWidget(
                              note: note,
                              onTap: action,
                              onLongPress: () => _showDeleteMenu(context, note),
                            );
                          },
                          openBuilder: (context, action) {
                            return EditNotePage(
                              note: note,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                          transitionType: ContainerTransitionType.fadeThrough,
                          closedElevation: 6,
                          openElevation: 0,
                          closedColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          openColor: Theme.of(context).colorScheme.surface,
                          middleColor: Theme.of(context).colorScheme.surface,
                        );
                      },
                      separatorBuilder: (_, _) => const Gap(6),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: OpenContainer(
          closedBuilder: (context, action) {
            return FloatingActionButton(
              onPressed: action,
              shape: const CircleBorder(),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add),
            );
          },
          openBuilder: (context, action) {
            return const EditNotePage();
          },
          closedShape: const CircleBorder(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionType: ContainerTransitionType.fadeThrough,
          closedElevation: 0,
          openElevation: 0,
          closedColor: Theme.of(context).colorScheme.primary,
          openColor: Theme.of(context).colorScheme.surface,
          middleColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Future<void> _showDeleteMenu(BuildContext context, Note note) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Delete Note',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  final noteId = note.id;
                  if (noteId == null) {
                    return;
                  }
                  context.read<NoteListBloc>().add(
                    NoteListEvent.deleteNote(noteId),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
