import 'package:flutter/material.dart';

import '../../../utils/utils.dart';

class K2OutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final TextStyle? style;

  const K2OutlinedButton(
      {super.key, required this.label, required this.onPressed, this.style});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: K2Colors.turquoise,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: K2Colors.turquoise, width: 1.5),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: style ??
              TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'poppins',
                  color: K2Colors.materialDarkBlue[500]),
        ),
      ),
    );
  }
}
