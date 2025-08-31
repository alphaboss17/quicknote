// ignore_for_file: unused_import
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quicknote/constants/routes.dart';
import 'package:quicknote/firebase_options.dart';
import 'package:quicknote/services/auth/auth_service.dart';
import 'package:quicknote/views/login_view.dart';
import 'package:quicknote/views/notes_view.dart';
import 'package:quicknote/views/register_view.dart';
import 'package:quicknote/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      routes: {
        //page routes
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
