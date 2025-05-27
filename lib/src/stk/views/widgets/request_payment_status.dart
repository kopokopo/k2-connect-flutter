import 'package:flutter/material.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/bottom_sheet_info.dart';

import '../../../utils/utils.dart';

class RequestPaymentStatus extends StatefulWidget {
  const RequestPaymentStatus({super.key});

  @override
  State<RequestPaymentStatus> createState() => _RequestPaymentStatusState();
}

class _RequestPaymentStatusState extends State<RequestPaymentStatus> {
  @override
  Widget build(BuildContext context) {
    return BottomSheetInfo(
      topIcon: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                color: K2Colors.lightBlue,
                backgroundColor: K2Colors.materialDarkBlue.shade300,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      description: 'Processing payment',
      bottomWidget: SizedBox(height: 28),
    );
  }
}
