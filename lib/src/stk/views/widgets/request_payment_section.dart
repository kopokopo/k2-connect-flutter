import 'package:flutter/material.dart';

import '../../../shared/k2_phone_number_form_field.dart';
import '../../../utils/utils.dart';
import 'k2_elevated_button.dart';

class RequestPaymentSection extends StatelessWidget {
  final String amount;
  final Function requestPayment;
  final TextEditingController phoneNumberController;
  const RequestPaymentSection({
    super.key,
    required this.amount,
    required this.requestPayment,
    required this.phoneNumberController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lipa na M-PESA',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'poppins',
                  color: K2Colors.materialDarkBlue[500]),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.close,
                size: 24.0,
              ),
            )
          ],
        ),
        const SizedBox(height: 32.0),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: K2Colors.grey.shade50.withValues(alpha: .2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount to pay',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'poppins',
                    color: K2Colors.materialNavyBlue[400]),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${AppConfig.defaultDisplayCurrency} $amount',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'poppins'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24.0),
        K2PhoneNumberFormField(
          controller: phoneNumberController,
          label: 'Enter M-PESA phone number',
        ),
        const SizedBox(height: 32.0),
        K2ElevatedButton(
          label: 'Proceed to pay',
          onPressed: () => requestPayment(),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}
