import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  showWarningDialog(String message) {
    Dialogs.materialDialog(
      context: context,
      msg: message,
      color: Colors.white,
      actionsBuilder: (context) {
        return [
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            label: const Text('Warning'),
            icon: const Icon(Icons.warning_amber, color: Colors.orange),
          ),
        ];
      },
    );
  }

  showOkDialog(String message) {
    Dialogs.materialDialog(
      context: context,
      msg: message,
      color: Colors.white,
      actionsBuilder: (context) {
        return [
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            label: const Text('Success'),
            icon: const Icon(Icons.done),
          ),
        ];
      },
    );
  }

  showErrorDialog(String message) {
    Dialogs.materialDialog(
      context: context,
      msg: message,
      color: Colors.white,
      actionsBuilder: (context) {
        return [
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            label: const Text('Cancel'),
            icon: const Icon(Icons.error_outline, color: Colors.red),
          ),
        ];
      },
    );
  }
}
