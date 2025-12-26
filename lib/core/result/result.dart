import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:notes_app/core/error/failures.dart';

part 'result.freezed.dart';

@freezed
class Result<T, F extends Failure> with _$Result<T, F> {
  const factory Result(T value) = ResultSuccess<T, F>;

  const factory Result.failure(F failure) = ResultFailure<T, F>;
}
