import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/core/di/injection_container.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_list_bloc.dart';
import 'package:notes_app/features/notes_list/presentation/pages/home_page.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NoteBloc>(
          create: (_) =>
              getIt<NoteBloc>()..add(const NoteListEvent.getAllNotes()),
        ),
      ],
      child: MaterialApp(
        title: 'Notes App',
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
      ),
    );
  }
}
