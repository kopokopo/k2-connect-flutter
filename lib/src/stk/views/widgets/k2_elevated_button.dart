import 'package:flutter/material.dart';

import '../../../utils/utils.dart';

class K2ElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final TextStyle? style;

  const K2ElevatedButton(
      {super.key, required this.label, required this.onPressed, this.style});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: K2Colors.turquoise,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: style ??
              const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'poppins',
              ),
        ),
      ),
    );
  }
}
