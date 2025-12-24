import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/repositories/i_note_repository.dart';

@injectable
class DeleteNoteUseCase implements UseCase<void, String> {

  const DeleteNoteUseCase(this.repository);
  final INoteRepository repository;

  @override
  Future<Result<void, Failure>> call(String id) async {
    return repository.deleteNote(id);
  }
}
