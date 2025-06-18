import 'package:flutter/material.dart';

void showProgressDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.lightBlue,
            backgroundColor: Colors.grey[100],
          ),
        ),
      );
    },
  );
}

void dismissProgressDialog(BuildContext context) {
  Navigator.pop(context);
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
  return;
}
