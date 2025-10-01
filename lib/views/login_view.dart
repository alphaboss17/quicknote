// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote/services/auth/auth_exceptions.dart';
import 'package:quicknote/services/auth/bloc/auth_bloc.dart';
import 'package:quicknote/services/auth/bloc/auth_event.dart';
import 'package:quicknote/services/auth/bloc/auth_state.dart';
import 'package:quicknote/utilities/dialog/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // bool _isPasswordVisible = false; ////Visibility toggle

  /// visibility toggle

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException ||
              state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context,
              'Cannot find a user with the entered credentials',
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('LogIn'), backgroundColor: Colors.blue),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Please log into your Account'),
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
                // obscureText: !_isPasswordVisible, ///// visibility toggle
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Please enter your password',
                  // suffixIcon: IconButton(
                  //   // Visibility toggle
                  //   onPressed: () {
                  //     setState(() {
                  //       _isPasswordVisible = !_isPasswordVisible;
                  //     });
                  //   },
                  //   icon: Icon(
                  //     _isPasswordVisible
                  //         ? Icons.visibility
                  //         : Icons.visibility_off,
                  //   ),
                  // ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                },
                child: Text('LogIn'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventForgotPassword());
                },
                child: const Text('I forgot my password'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text('Not Registered yet? Register Here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
