import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_app/features/notes_list/data/models/note_model.dart';
import 'package:uuid/uuid.dart';

@module
abstract class RegisterModule {
  @preResolve
  @singleton
  Future<Box<NoteModel>> get notesBox async =>
      await Hive.openBox<NoteModel>('notesBox');

  @lazySingleton
  Uuid get uuid => const Uuid();
}
