import 'package:flutter/material.dart';

class AccessTokenCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback requestAccessToken;

  const AccessTokenCard({
    super.key,
    required this.controller,
    required this.requestAccessToken,
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
              'Click the button below to request an access token',
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
              onPressed: requestAccessToken,
              child: Text(
                'Request access token',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              keyboardType: TextInputType.text,
              readOnly: true,
              controller: controller,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14.0,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(
                      color: Colors.white,
                    )),
                filled: true,
                fillColor: Colors.grey[100],
                hintText: "Your access token will be shown here",
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.0,
                ),
              ),
              textCapitalization: TextCapitalization.none,
            ),
          ],
        ),
      ),
    );
  }
}
