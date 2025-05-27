import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k2_connect_flutter/src/shared/amount.dart';
import 'package:k2_connect_flutter/src/stk/models/stk_push_request.dart';
import 'package:k2_connect_flutter/src/stk/models/subscriber.dart';
import 'package:k2_connect_flutter/src/stk/services/stk_service.dart';

import 'package:k2_connect_flutter/src/stk/views/widgets/loading_request_payment.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_alert.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_section.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_status.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/success_request_payment.dart';

import '../../utils/utils.dart';

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
      accessToken: widget.accessToken,
    );

    final service = StkService(baseUrl: widget.baseUrl);

    final result = await service.requestPayment(stkRequest);

    if (result == null ||
        !(result.statusCode == 200 || result.statusCode == 201)) {
      final body = jsonDecode(result?.body ?? '{}');
      setState(() {
        errorMessage = body['error_message'] ?? 'Unknown error';
        _requestState = RequestState.errorRequestStatus;
      });
      return;
    }

    final location = result.headers['location'];
    if (location == null) {
      setState(() {
        errorMessage = 'Missing status location header';
        _requestState = RequestState.errorRequestStatus;
      });
      return;
    }

    setState(() => _requestState = RequestState.requestStatus);

    Future<void> checkStatus([int retryCount = 0]) async {
      final statusResponse = await service.requestStatus(
        uri: location,
        accessToken: widget.accessToken,
      );

      final status = statusResponse.attributes.status;

      if (status == 'Received') {
        setState(() => _requestState = RequestState.successfulRequestStatus);
      } else if (status == 'Failed') {
        setState(() {
          errorMessage =
              statusResponse.attributes.event?.errors ?? 'Payment failed';
          _requestState = RequestState.errorRequestStatus;
        });
      } else if (status == 'Pending') {
        if (retryCount <= 1) {
          setState(() => _requestState = RequestState.pendingRequestStatus);
          await Future.delayed(const Duration(seconds: 30));
          await checkStatus(retryCount + 1);
        } else {
          setState(() {
            errorMessage = 'Timed out while waiting for payment confirmation';
            _requestState = RequestState.errorRequestStatus;
          });
        }
      }
    }

    await Future.delayed(const Duration(seconds: 5));
    await checkStatus();
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
      case RequestState.requestStatus:
        return RequestPaymentStatus();
      case RequestState.successfulRequestStatus:
        return SuccessRequestPayment(
          companyName: widget.companyName,
          amount: widget.amount,
          onSuccess: widget.onSuccess,
        );
      case RequestState.pendingRequestStatus:
        return RequestPaymentAlert(
          iconColour: K2Colors.secondaryDarkBlue,
          label: 'Payment pending',
          description: 'Your payment is pending and wil be completed soon',
        );
      case RequestState.errorRequestStatus:
        return RequestPaymentAlert(
          iconColour: K2Colors.error,
          label: 'Payment declined',
          description: errorMessage ?? 'An error occurred.',
          action: widget.onError,
        );
    }
  }
}

enum RequestState {
  requestPayment,
  loadingRequestPayment,
  requestStatus,
  successfulRequestStatus,
  errorRequestStatus,
  pendingRequestStatus
}
