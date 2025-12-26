import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_bloc.dart';
import 'package:notes_app/features/notes_list/presentation/widget/note_search_bar_widget.dart';
import 'package:notes_app/features/notes_list/presentation/widget/note_tile_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NoteListView();
  }
}

class _NoteListView extends StatefulWidget {
  const _NoteListView();

  @override
  State<_NoteListView> createState() => _NoteListViewState();
}

class _NoteListViewState extends State<_NoteListView> {
  String _searchQuery = '';
  String _lastSearchQuery = '';
  List<Note>? _lastNotes;
  List<Note>? _lastFilteredNotes;

  List<Note> _filterNotes(List<Note> notes) {
    // Return cached results if the input list and query haven't changed.
    if (identical(notes, _lastNotes) &&
        _searchQuery == _lastSearchQuery &&
        _lastFilteredNotes != null) {
      return _lastFilteredNotes!;
    }

    if (_searchQuery.isEmpty) {
      _lastNotes = notes;
      _lastSearchQuery = _searchQuery;
      _lastFilteredNotes = notes;
      return notes;
    }

    final queryLower = _searchQuery.toLowerCase();
    final filtered = notes.where((note) {
      final titleLower = note.title.toLowerCase();
      final contentLower = note.content.toLowerCase();
      final titleMatch = titleLower.contains(queryLower);
      final contentMatch = contentLower.contains(queryLower);
      return titleMatch || contentMatch;
    }).toList();

    _lastNotes = notes;
    _lastSearchQuery = _searchQuery;
    _lastFilteredNotes = filtered;

    return filtered;
  }

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
            NoteSearchBarWidget(
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            Expanded(
              child: BlocBuilder<NoteBloc, NoteState>(
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    );
                  }

                  final filteredNotes = _filterNotes(state.notes);

                  if (filteredNotes.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        'No notes found',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    );
                  }

                  final sortedNotes = List<Note>.from(filteredNotes)
                    ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

                  return RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () async {
                      context.read<NoteBloc>().add(
                        const NoteEvent.getAllNotes(),
                      );
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      itemCount: sortedNotes.length,
                      itemBuilder: (_, i) {
                        final note = sortedNotes[i];
                        return NoteTileWidget(
                          note: note,
                          onTap: () async {
                            await context.push('/edit-note', extra: note);
                          },
                          onLongPress: () => _showDeleteMenu(context, note),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.push('/edit-note');
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showDeleteMenu(BuildContext context, Note note) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Note',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  final noteId = note.id;
                  if (noteId == null) {
                    return;
                  }
                  context.read<NoteBloc>().add(
                      NoteEvent.deleteNote(noteId),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
