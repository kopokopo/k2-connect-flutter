import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k2_connect_flutter/src/shared/amount.dart';
import 'package:k2_connect_flutter/src/stk/models/stk_push_request.dart';
import 'package:k2_connect_flutter/src/stk/models/subscriber.dart';
import 'package:k2_connect_flutter/src/stk/services/stk_service.dart';

import 'package:k2_connect_flutter/src/stk/views/widgets/error_request_payment.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/loading_request_payment.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_section.dart';

class RequestPaymentBottomSheet extends StatefulWidget {
  final String tillNumber;
  final String? currency;
  final String amount;
  final String callbackUrl;
  final Map<String, dynamic>? metadata;
  final String accessToken;
  final String baseUrl;
  final String companyName;
  final Function? onSuccess;
  final Function? onError;

  const RequestPaymentBottomSheet(
      {super.key,
      required this.tillNumber,
      required this.currency,
      required this.amount,
      required this.callbackUrl,
      this.metadata,
      required this.accessToken,
      required this.baseUrl,
      required this.companyName,
      this.onSuccess,
      this.onError});

  @override
  State<RequestPaymentBottomSheet> createState() =>
      _RequestPaymentBottomSheetState();
}

class _RequestPaymentBottomSheetState extends State<RequestPaymentBottomSheet> {
  final TextEditingController _phoneNumberController = TextEditingController();
  RequestState _requestState = RequestState.requestPayment;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 40),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBody(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Powered by'),
                const SizedBox(
                  width: 4.0,
                ),
                SvgPicture.asset(
                  'assets/Kopo_Kopo_Logo.svg',
                  height: 20,
                  package: 'k2_connect_flutter',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _requestPayment() async {
    setState(() => _requestState = RequestState.loadingRequestPayment);

    final phoneNumber = _phoneNumberController.text.replaceAll(' ', '');
    final stkRequest = StkPushRequest(
      tillNumber: widget.tillNumber,
      subscriber: Subscriber(phoneNumber: phoneNumber),
      amount: Amount(value: widget.amount, currency: widget.currency),
      callbackUrl: widget.callbackUrl,
      accessToken: widget.accessToken
    );

    final service = StkService(
      baseUrl: widget.baseUrl,
    );
    final result = await service.requestPayment(stkRequest);

    if (result == null ||
        (result.statusCode != 200 && result.statusCode != 201)) {
      final body = jsonDecode(result?.body ?? '{}');
      setState(() {
        errorMessage = body['error_message'] ?? 'Unknown error';
        _requestState = RequestState.errorRequestStatus;
      });
      return;
    }
  }

  Widget _buildBody() {
    switch (_requestState) {
      case RequestState.requestPayment:
        return RequestPaymentSection(
          amount: widget.amount,
          requestPayment: _requestPayment,
          phoneNumberController: _phoneNumberController,
        );
      case RequestState.loadingRequestPayment:
        return LoadingRequestPayment();
      case RequestState.errorRequestStatus:
        return ErrorRequestPayment(
          error: errorMessage,
          onError: widget.onError,
        );
    }
  }
}

enum RequestState {
  requestPayment,
  loadingRequestPayment,
  errorRequestStatus
}
