import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:k2_connect_flutter/src/shared/k2_connect_logger.dart';
import 'package:k2_connect_flutter/src/stk/models/stk_push_request.dart';
import 'package:k2_connect_flutter/src/stk/models/subscriber.dart';
import 'package:k2_connect_flutter/src/stk/services/stk_service.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/loading_request_payment.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_alert.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_section.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_status.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/success_request_payment.dart';

import '../../shared/k2_http_exception.dart';
import '../../utils/utils.dart';

class RequestPaymentBottomSheet extends StatefulWidget {
  final StkPushRequest stkPushRequest;
  final StkService stkService;

  const RequestPaymentBottomSheet({
    super.key,
    required this.stkPushRequest,
    required this.stkService,
  });

  @override
  State<RequestPaymentBottomSheet> createState() =>
      _RequestPaymentBottomSheetState();
}

class _RequestPaymentBottomSheetState extends State<RequestPaymentBottomSheet> {
  final TextEditingController _phoneNumberController = TextEditingController();
  RequestState _requestState = RequestState.requestPayment;
  String? errorMessage;
  StkService get stkService => widget.stkService;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _requestPaymentBody(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Powered by',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.0,
                      fontFamily: 'poppins',
                    )),
                const SizedBox(
                  width: 4.0,
                ),
                SvgPicture.asset(
                  'assets/logos/Kopo_Kopo_Logo.svg',
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
    final stkPushRequest = StkPushRequest(
      tillNumber: widget.stkPushRequest.tillNumber,
      subscriber: Subscriber(phoneNumber: phoneNumber),
      amount: widget.stkPushRequest.amount,
      callbackUrl: widget.stkPushRequest.callbackUrl,
      accessToken: widget.stkPushRequest.accessToken,
    );

    try {
      final String? locationUrl =
          await stkService.requestPayment(stkPushRequest: stkPushRequest);
      if (locationUrl == null) {
        _handleMissingLocationHeader();
        return;
      }
      await _processSuccessfulResponse(locationUrl);
    } on K2HttpException catch (e) {
      K2ConnectLogger.d('Request failed with error: $e');
      setState(() {
        errorMessage = e.body['error_message'] ??
            'An unknown error occured, please try again later.';
        _requestState = RequestState.errorRequestStatus;
      });
      return;
    } on Exception catch (e) {
      K2ConnectLogger.d('Request failed with error: ${e.toString()}');
      setState(() {
        errorMessage = 'An unknown error occured, please try again later.';
        _requestState = RequestState.errorRequestStatus;
      });
      return;
    }
  }

  void _handleMissingLocationHeader() {
    setState(() {
      errorMessage = 'Missing status location header';
      _requestState = RequestState.errorRequestStatus;
    });
    return;
  }

  Future<void> _processSuccessfulResponse(String location) async {
    setState(() => _requestState = RequestState.requestStatus);
    await Future.delayed(const Duration(seconds: 10));
    await checkStatus(location);
  }

  Future<void> checkStatus(String location, [int retryCount = 0]) async {
    final statusResponse = await stkService.requestStatus(
      uri: location,
      accessToken: widget.stkPushRequest.accessToken,
    );

    final status = statusResponse.attributes.status;

    if (status == 'Success') {
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
        await checkStatus(location, retryCount + 1);
      } else {
        setState(() {
          errorMessage = 'Timed out while waiting for payment confirmation';
          _requestState = RequestState.errorRequestStatus;
        });
      }
    }
  }

  Widget _requestPaymentBody() {
    switch (_requestState) {
      case RequestState.requestPayment:
        return RequestPaymentSection(
          amount: widget.stkPushRequest.amount.value,
          requestPayment: _requestPayment,
          phoneNumberController: _phoneNumberController,
        );
      case RequestState.loadingRequestPayment:
        return LoadingRequestPayment();
      case RequestState.requestStatus:
        return RequestPaymentStatus();
      case RequestState.successfulRequestStatus:
        return SuccessRequestPayment(
          companyName: widget.stkPushRequest.companyName ?? '',
          amount: widget.stkPushRequest.amount.value,
          onSuccess: widget.stkPushRequest.onSuccess,
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
          description: errorMessage ??
              'An unknown error occured, please try again later.',
          action: widget.stkPushRequest.onError,
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
