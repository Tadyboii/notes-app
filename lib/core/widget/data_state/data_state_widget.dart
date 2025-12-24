import 'package:flutter/material.dart';

import 'package:notes_app/core/widget/data_state/data_state.dart';

typedef DataWidgetBuilder<T> = Widget Function(BuildContext context, T data);
typedef ErrorWidgetBuilder =
    Widget Function(BuildContext context, Object error, StackTrace stackTrace);

class DataStateWidget<T> extends StatelessWidget {

  const DataStateWidget({
    required this.state, required this.childBuilder, required this.loadingBuilder, required this.errorBuilder, super.key,
  });
  final DataState<T> state;
  final DataWidgetBuilder<T> childBuilder;
  final WidgetBuilder loadingBuilder;
  final ErrorWidgetBuilder errorBuilder;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      DataStateLoaded<T>(:final data) => childBuilder(context, data),
      DataStateLoading<T>() => loadingBuilder(context),
      DataStateError<T>(:final error, :final stackTrace) => errorBuilder(
        context,
        error,
        stackTrace,
      ),
    };
  }
}
