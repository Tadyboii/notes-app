import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/core/di/injection_container.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_bloc.dart';
import 'package:notes_app/features/notes_list/presentation/pages/home_page.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<NoteBloc>(
            create: (_) =>
                getIt<NoteBloc>()..add(const NoteEvent.getAllNotes()),
          ),
        ],
        child: const HomePage(),
      ),
    );
  }
}
