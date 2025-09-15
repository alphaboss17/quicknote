import 'package:flutter/material.dart';
import 'package:quicknote/constants/routes.dart';
import 'package:quicknote/enums/menu_action.dart';
import 'package:quicknote/services/auth/auth_service.dart';
import 'package:quicknote/services/crud/notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
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
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(
                      // ignore: use_build_context_synchronously
                      context,
                    ).pushNamedAndRemoveUntil(loginRoute, (_) => false);
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

      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text('Waiting for all notes');
                    case ConnectionState.active:
                      // if (snapshot.hasData) {
                      //   final allNotes = snapshot.data as List<DatabaseNote>;
                      //   return ListView.builder(
                      //     itemCount: allNotes.length,
                      //     itemBuilder: (context, index) {
                      //       return const Text('Item');
                      //     },
                      //   );
                      // } else {
                      //   return const CircularProgressIndicator(
                      //     color: Colors.yellow,
                      //   );
                      // }  Option 1

                      if (snapshot.hasData) {
                        final allNotes =
                            snapshot.data as Iterable<DatabaseNote>;
                        // new addition to check
                        if (allNotes.isEmpty) {
                          return const Center(
                            child: Text('No notes yet. create note'),
                          );
                        } // new addition to check
                        return ListView.builder(
                          itemCount: allNotes.length,
                          itemBuilder: (context, index) {
                            final note = allNotes.elementAt(
                              index,
                            ); // new addition to check
                            return ListTile(
                              title: Text(
                                note.text,
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator(
                          color: Colors.yellow,
                        );
                      }
                    default:
                      return const CircularProgressIndicator(
                        color: Colors.green,
                      );
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

// extension on Iterable<DatabaseNote> {
//   operator [](int other) {}
// }

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
