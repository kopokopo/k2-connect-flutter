import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/bottom_sheet_info.dart';

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
              'Payment declined',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 18.0),
            ),
            const SizedBox(height: 12.0),
            Text(description),
            Padding(
              padding: EdgeInsets.only(top: 32),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    action!();
                  },
                  child: Text('Done'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
