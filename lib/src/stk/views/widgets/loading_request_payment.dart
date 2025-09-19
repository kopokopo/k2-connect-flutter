import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/bottom_sheet_info.dart';

import '../../../utils/utils.dart';
import 'k2_outlined_button.dart';

class LoadingRequestPayment extends StatelessWidget {
  const LoadingRequestPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomSheetInfo(
      topIcon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: K2Colors.grey.shade50.withValues(alpha: .2),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: K2Colors.grey.shade100.withValues(alpha: .4),
          ),
          child: SvgPicture.asset(
            'assets/icons/phone_01.svg',
            height: 38,
            package: 'k2_connect_flutter',
          ),
        ),
      ),
      title: 'Enter your M-PESA PIN when prompted to complete payment',
      bottomWidget: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: K2Colors.lightBlue,
              backgroundColor: K2Colors.materialDarkBlue.shade300,
            ),
          ),
          const SizedBox(height: 32),
          K2OutlinedButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
