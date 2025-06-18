import 'package:flutter/material.dart';

class RevokeAccessTokenCard extends StatelessWidget {
  final VoidCallback revokeAccessToken;

  const RevokeAccessTokenCard({
    super.key,
    required this.revokeAccessToken,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Click the button below to revoke the access token generated',
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ButtonStyle(
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  EdgeInsets.all(12.0),
                ),
              ),
              onPressed: revokeAccessToken,
              child: Text(
                'Revoke access token',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
