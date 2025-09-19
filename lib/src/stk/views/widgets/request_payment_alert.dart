import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/bottom_sheet_info.dart';

import '../../../utils/utils.dart';
import 'k2_outlined_button.dart';

class RequestPaymentAlert extends StatelessWidget {
  final Color iconColour;
  final String label;
  final String description;
  final Function? action;
  const RequestPaymentAlert({
    super.key,
    required this.iconColour,
    required this.label,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return BottomSheetInfo(
      topIcon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconColour.withValues(alpha: .2),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColour,
          ),
          child: SvgPicture.asset(
            'assets/icons/alert-circle.svg',
            height: 30,
            package: 'k2_connect_flutter',
          ),
        ),
      ),
      bottomWidget: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'poppins',
                  color: K2Colors.materialDarkBlue[500]),
            ),
            const SizedBox(height: 12.0),
            Text(
              description,
              style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: K2Colors.materialDarkBlue[400]),
            ),
            const SizedBox(height: 32.0),
            K2OutlinedButton(
              label: 'Done',
              onPressed: () {
                Navigator.pop(context);
                if (action != null) {
                  action!(description);
                }
              },
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
