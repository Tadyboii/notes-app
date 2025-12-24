import 'package:injectable/injectable.dart';
import 'package:notes_app/core/error/failures.dart';
import 'package:notes_app/core/result/result.dart';
import 'package:notes_app/core/usecase/usecase.dart';
import 'package:notes_app/features/notes_list/domain/repositories/note_repository.dart';

@injectable
class DeleteNote implements UseCase<void, String> {
  final NoteRepository repository;

  const DeleteNote(this.repository);

  @override
  Future<Result<void, Failure>> call(String id) async {
    return await repository.deleteNote(id);
  }
}
