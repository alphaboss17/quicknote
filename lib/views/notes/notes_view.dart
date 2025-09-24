import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:quicknote/constants/routes.dart';
import 'package:quicknote/enums/menu_action.dart';
import 'package:quicknote/services/auth/auth_service.dart';
import 'package:quicknote/services/auth/bloc/auth_bloc.dart';
import 'package:quicknote/services/auth/bloc/auth_event.dart';
import 'package:quicknote/services/cloud/cloud_note.dart';
import 'package:quicknote/services/cloud/firebase_cloud_storage.dart';
import 'package:quicknote/utilities/dialog/logout_dialog.dart';
import 'package:quicknote/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    // _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    // _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Sign Out'),
                ),
              ];
            },
          ),
        ],
      ),

      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId), //
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Text('Waiting for all notes');
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                //snapshot.data as Iterable<DatabaseNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
                  },
                  onTap: (note) {
                    //make async
                    Navigator.of(
                      context,
                    ).pushNamed(createOrUpdateNoteRoute, arguments: note);
                  },
                );

                if (allNotes.isEmpty) {
                  return const Center(child: Text('No notes yet. create note'));
                }
              } else {
                return const CircularProgressIndicator(color: Colors.yellow);
              }
            default:
              return const CircularProgressIndicator(color: Colors.green);
          }
        },
      ),
    );
  }
}

// extension on Iterable<DatabaseNote> {
//   operator [](int other) {}
// }
