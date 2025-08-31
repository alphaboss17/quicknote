// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:quicknote/constants/routes.dart';
import 'package:quicknote/utilities/show_error_dialogue.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LogIn'), backgroundColor: Colors.blue),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Please enter your email',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Please enter your password',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              if (email.trim().isEmpty || password.isEmpty) {
                devtools.log('Email and password must not be empty.');
                return;
              }
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                //check if a user is verified before logging in
                final user = FirebaseAuth.instance.currentUser;
                if (user?.emailVerified ?? false) {
                  //users email is verified
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                } else {
                  //users email isnt verified
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
                }
              } on FirebaseAuthException catch (e) {
                //devtools.log(e.toString());
                if (e.code == 'invalid-credential') {
                  await showErrorDialog(context, 'Invalid Email or Password');
                } else if (e.code == 'wrong-password') {
                  devtools.log(e.toString());
                  await showErrorDialog(context, 'Wrong Password!,');
                } else {
                  await showErrorDialog(context, 'Error: ${e.code}');
                }
              } catch (e) {
                await showErrorDialog(context, e.toString());
              }
            },
            child: Text('LogIn'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Not Registered yet? Register Here'),
          ),
        ],
      ),
    );
  }
}
