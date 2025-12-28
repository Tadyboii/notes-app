import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/repositories/i_note_repository.dart';

@injectable
class AddNoteUseCase implements UseCase<Note, Note> {
  const AddNoteUseCase(this.repository);

  final INoteRepository repository;

  @override
  Future<Result<Note, Failure>> call(Note note) async {
    return repository.addNote(note);
  }
}
