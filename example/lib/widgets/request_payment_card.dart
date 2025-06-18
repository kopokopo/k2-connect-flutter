import 'package:flutter/material.dart';

class RequestPaymentCard extends StatelessWidget {
  final VoidCallback showRequestPaymentBottomSheet;

  const RequestPaymentCard({
    super.key,
    required this.showRequestPaymentBottomSheet,
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
              'Click the button below to show the request payment bottom sheet',
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
              onPressed: showRequestPaymentBottomSheet,
              child: Text(
                'Request payment',
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
