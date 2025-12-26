import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/core/di/injection_container.dart';
import 'package:notes_app/core/router/app_router.dart';
import 'package:notes_app/features/notes_list/presentation/bloc/note_bloc.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NoteBloc>(
          create: (_) => getIt<NoteBloc>()..add(const NoteEvent.getAllNotes()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Notes App',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
          ),
          useMaterial3: true,
        ),
      ),
    );
  }
}
