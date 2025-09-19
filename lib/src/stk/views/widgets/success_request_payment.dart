import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/bottom_sheet_info.dart';

import '../../../utils/utils.dart';
import 'k2_outlined_button.dart';

class SuccessRequestPayment extends StatefulWidget {
  final String companyName;
  final Function? onSuccess;
  final String amount;

  const SuccessRequestPayment({
    super.key,
    required this.companyName,
    this.onSuccess,
    required this.amount,
  });

  @override
  State<SuccessRequestPayment> createState() => _SuccessRequestPaymentState();
}

class _SuccessRequestPaymentState extends State<SuccessRequestPayment> {
  int _secondsRemaining = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _countdown();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetInfo(
      topIcon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: K2Colors.turquoise.withValues(alpha: .2),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: K2Colors.turquoise,
          ),
          child: SvgPicture.asset(
            'assets/icons/check.svg',
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
            RichText(
              text: TextSpan(
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                    fontFamily: 'poppins',
                    color: K2Colors.materialDarkBlue[400]),
                children: <TextSpan>[
                  TextSpan(
                    text: 'You have paid ${AppConfig.defaultDisplayCurrency} ',
                  ),
                  TextSpan(
                      text: widget.amount,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          fontFamily: 'poppins')),
                  TextSpan(text: ' to ${widget.companyName}.'),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            RichText(
              text: TextSpan(
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0,
                    fontFamily: 'poppins',
                    color: K2Colors.materialDarkBlue[400]),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Redirecting ',
                  ),
                  TextSpan(
                      text:
                          '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.0,
                          fontFamily: 'poppins')),
                ],
              ),
            ),
            const SizedBox(height: 32),
            K2OutlinedButton(
              label: 'Done',
              onPressed: () {
                Navigator.pop(context);
                if (widget.onSuccess != null) {
                  widget.onSuccess!();
                }
              },
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  void _countdown() {
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        Navigator.pop(context);
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }
}
