import 'package:notes_app/app/app.dart';
import 'package:notes_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const NotesApp());
}
