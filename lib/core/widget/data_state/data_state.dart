import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_state.freezed.dart';

@freezed
sealed class DataState<T> with _$DataState<T> {
  const factory DataState(T data) = DataStateLoaded<T>;

  const factory DataState.loading() = DataStateLoading<T>;

  const factory DataState.error({
    required Object error,
    @Default(StackTrace.empty) StackTrace stackTrace,
  }) = DataStateError<T>;
}
