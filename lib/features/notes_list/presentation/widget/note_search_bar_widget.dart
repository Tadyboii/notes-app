import 'package:flutter/material.dart';

class NoteSearchBarWidget extends StatefulWidget {
  const NoteSearchBarWidget({
    required this.onSearchChanged,
    required this.query,
    super.key,
  });

  final ValueChanged<String> onSearchChanged;
  final String query;

  @override
  State<NoteSearchBarWidget> createState() => _NoteSearchBarWidgetState();
}

class _NoteSearchBarWidgetState extends State<NoteSearchBarWidget> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NoteSearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query &&
        _searchController.text != widget.query) {
      _searchController.text = widget.query;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: widget.onSearchChanged,
      ),
    );
  }
}
