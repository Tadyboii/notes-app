import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/features/notes_list/domain/entities/note.dart';
import 'package:notes_app/features/notes_list/presentation/pages/edit_note_page.dart';
import 'package:notes_app/features/notes_list/presentation/pages/home_page.dart';

part 'routes.g.dart';

@TypedGoRoute<HomePageRoute>(
  path: '/',
  routes: [
    TypedGoRoute<EditNotePageRoute>(
      path: 'edit-note',
      name: 'edit_note',
    ),
  ],
)
@immutable
class HomePageRoute extends GoRouteData {
  const HomePageRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const HomePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // When EditNotePage is pushed, HomePage slides left and fades
        final slideOut =
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.1, 0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeInOutCubic,
              ),
            );

        final fadeOut =
            Tween<double>(
              begin: 1,
              end: 0.8,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeInOutCubic,
              ),
            );

        return SlideTransition(
          position: slideOut,
          child: FadeTransition(
            opacity: fadeOut,
            child: child,
          ),
        );
      },
    );
  }
}

@immutable
class EditNotePageRoute extends GoRouteData {
  const EditNotePageRoute({
    this.$extra,
  });

  final Note? $extra;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: EditNotePage(note: $extra),
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideIn =
            Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              ),
            );
        return SlideTransition(
          position: slideIn,
          child: child,
        );
      },
    );
  }
}
