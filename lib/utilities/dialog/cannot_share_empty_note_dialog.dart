import 'package:flutter/material.dart';
import 'package:quicknote/utilities/dialog/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty Note',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
