// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive/hive.dart' as _i979;
import 'package:hive_flutter/hive_flutter.dart' as _i986;
import 'package:injectable/injectable.dart' as _i526;
import 'package:uuid/uuid.dart' as _i706;

import '../../features/notes_list/data/datasources/note_local_datasource.dart'
    as _i482;
import '../../features/notes_list/data/datasources/note_local_datasource_impl.dart'
    as _i370;
import '../../features/notes_list/data/models/note_model.dart' as _i568;
import '../../features/notes_list/data/repositories/note_repository_impl.dart'
    as _i331;
import '../../features/notes_list/di/note_module.dart' as _i760;
import '../../features/notes_list/domain/repositories/i_note_repository.dart'
    as _i425;
import '../../features/notes_list/domain/usecases/add_note_usecase.dart'
    as _i194;
import '../../features/notes_list/domain/usecases/delete_note_usecase.dart'
    as _i616;
import '../../features/notes_list/domain/usecases/get_all_notes_usecase.dart'
    as _i238;
import '../../features/notes_list/domain/usecases/update_note_usecase.dart'
    as _i201;
import '../../features/notes_list/presentation/bloc/note_bloc.dart' as _i851;
import 'core_module.dart' as _i154;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final noteModule = _$NoteModule();
    final coreModule = _$CoreModule();
    await gh.singletonAsync<_i986.Box<_i568.NoteModel>>(
      () => noteModule.notesBox,
      preResolve: true,
    );
    gh.lazySingleton<_i706.Uuid>(() => coreModule.uuid);
    gh.singleton<_i482.NoteLocalDataSource>(() => _i370.NoteLocalDataSourceImpl(
          notesBox: gh<_i979.Box<_i568.NoteModel>>(),
          uuid: gh<_i706.Uuid>(),
        ));
    gh.singleton<_i425.INoteRepository>(
        () => _i331.NoteRepositoryImpl(gh<_i482.NoteLocalDataSource>()));
    gh.factory<_i201.UpdateNoteUseCase>(
        () => _i201.UpdateNoteUseCase(gh<_i425.INoteRepository>()));
    gh.factory<_i616.DeleteNoteUseCase>(
        () => _i616.DeleteNoteUseCase(gh<_i425.INoteRepository>()));
    gh.factory<_i194.AddNoteUseCase>(
        () => _i194.AddNoteUseCase(gh<_i425.INoteRepository>()));
    gh.factory<_i238.GetAllNotesUseCase>(
        () => _i238.GetAllNotesUseCase(gh<_i425.INoteRepository>()));
    gh.factory<_i851.NoteBloc>(() => _i851.NoteBloc(
          gh<_i238.GetAllNotesUseCase>(),
          gh<_i194.AddNoteUseCase>(),
          gh<_i616.DeleteNoteUseCase>(),
          gh<_i201.UpdateNoteUseCase>(),
        ));
    return this;
  }
}

class _$NoteModule extends _i760.NoteModule {}

class _$CoreModule extends _i154.CoreModule {}
