import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_app/core/di/injection_container.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  preferRelativeImports: true,
)
FutureOr<void> configureDependencies({String? environment}) {
  return getIt.init(environment: environment);
}
