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

import '../../features/notes_list/data/datasources/hive_datasource.dart' as _i312;
import '../../features/notes_list/data/datasources/hive_datasource_impl.dart'
    as _i203;
import '../../features/notes_list/data/models/note_model.dart' as _i214;
import '../../features/notes_list/data/repositories/note_repository_impl.dart'
    as _i559;
import '../../features/notes_list/domain/repositories/note_repository.dart' as _i539;
import '../../features/notes_list/domain/usecases/add_note.dart' as _i760;
import '../../features/notes_list/domain/usecases/delete_note.dart' as _i567;
import '../../features/notes_list/domain/usecases/get_all_notes.dart' as _i522;
import '../../features/notes_list/domain/usecases/update_note.dart' as _i397;
import '../../features/notes_list/presentation/bloc/note_bloc.dart' as _i895;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.singletonAsync<_i986.Box<_i214.NoteModel>>(
      () => registerModule.notesBox,
      preResolve: true,
    );
    gh.lazySingleton<_i706.Uuid>(() => registerModule.uuid);
    gh.singleton<_i312.HiveDataSource>(
      () => _i203.HiveDataSourceImpl(
        notesBox: gh<_i979.Box<_i214.NoteModel>>(),
        uuid: gh<_i706.Uuid>(),
      ),
    );
    gh.singleton<_i539.NoteRepository>(
      () => _i559.NoteRepositoryImpl(gh<_i312.HiveDataSource>()),
    );
    gh.factory<_i522.GetAllNotes>(
      () => _i522.GetAllNotes(gh<_i539.NoteRepository>()),
    );
    gh.factory<_i760.AddNote>(() => _i760.AddNote(gh<_i539.NoteRepository>()));
    gh.factory<_i397.UpdateNote>(
      () => _i397.UpdateNote(gh<_i539.NoteRepository>()),
    );
    gh.factory<_i567.DeleteNote>(
      () => _i567.DeleteNote(gh<_i539.NoteRepository>()),
    );
    gh.factory<_i895.NoteBloc>(
      () => _i895.NoteBloc(
        gh<_i522.GetAllNotes>(),
        gh<_i760.AddNote>(),
        gh<_i567.DeleteNote>(),
        gh<_i397.UpdateNote>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
