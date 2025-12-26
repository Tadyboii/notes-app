import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/domain/repositories/i_note_repository.dart';

@injectable
class GetAllNotesUseCase implements UseCase<List<Note>, NoParams> {
  const GetAllNotesUseCase(this.repository);

  final INoteRepository repository;

  @override
  Future<Result<List<Note>, Failure>> call(NoParams params) async {
    return repository.getAllNotes();
  }
}
