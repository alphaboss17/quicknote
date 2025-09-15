import 'package:flutter/material.dart';
import 'package:quicknote/services/auth/auth_service.dart';
import 'package:quicknote/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();

    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }



  Future<DatabaseNote?> createNewNote() async {
    try {
      final existingNote = _note;
      if (existingNote != null) {
        return existingNote;
      }

      
      final currentUser = AuthService.firebase().currentUser!;
      final email = currentUser.email!;

      // Force reopen the database
      await _notesService.forceReopenDatabase();

      final owner = await _notesService.getOrCreateUser(email: email);

      final newNote = await _notesService.createNote(
        owner: owner,
        text: '',
        ownerUserId: owner.id,
      );

      return newNote;
    } catch (e) {
      return null;
    }
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        backgroundColor: Colors.blue,
      ),
    
      body: FutureBuilder<DatabaseNote?>(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.data == null) {
                return const Center(child: Text('Failed to create note'));
              }

              _note = snapshot.data!;
              _setupTextControllerListener();

              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...',
                  border: OutlineInputBorder(),
                ),
              );

            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
