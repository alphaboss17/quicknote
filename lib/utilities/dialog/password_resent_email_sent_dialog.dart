import 'package:flutter/material.dart';
import 'package:quicknote/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content: 'We have sent you a passsword Reset link, please check your email',
    optionsBuilder: () => {'OK': null},
  );
}
