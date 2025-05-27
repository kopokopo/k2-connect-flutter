import 'package:flutter/material.dart';

import '../../../shared/k2_phone_number_form_field.dart';
import '../../../utils/utils.dart';

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
              'Lipa na MPESA',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontSize: 20.0),
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
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 4.0),
              Text(
                '${AppConfig.defaultDisplayCurrency} $amount',
                style: Theme.of(context).textTheme.headlineLarge,
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: K2Colors.turquoise,
              foregroundColor: Colors.white,
            ),
            onPressed: () => requestPayment(),
            child: Text('Proceed to pay'),
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}
