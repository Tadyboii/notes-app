import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';

@module
abstract class NoteModule {
  @preResolve
  @singleton
  Future<Box<NoteModel>> get notesBox async =>
      Hive.openBox<NoteModel>('notesBox');
}
