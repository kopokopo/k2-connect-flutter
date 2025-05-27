import 'package:k2_connect_flutter/src/shared/amount.dart';
import 'package:k2_connect_flutter/src/stk/models/stk_push_request_validator.dart';
import 'package:k2_connect_flutter/src/stk/models/subscriber.dart';

class StkPushRequest {
  final String accessToken;
  final String paymentChannel;
  final String tillNumber;
  final Subscriber? subscriber;
  final Amount amount;
  final Map<String, dynamic>? metadata;
  final String callbackUrl;
  final String? companyName;
  final Function? onSuccess;
  final Function? onError;

  StkPushRequest({
    required this.accessToken,
    this.paymentChannel = 'M-PESA STK PUSH',
    required this.tillNumber,
    this.subscriber,
    required this.amount,
    this.metadata,
    required this.callbackUrl,
    this.companyName,
    this.onSuccess,
    this.onError,
  }) {
    StkPushRequestValidator.validate(this);
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_channel': paymentChannel,
      'till_number': tillNumber,
      'subscriber': subscriber?.toJson(),
      'amount': amount.toJson(),
      'metadata': metadata,
      '_links': {
        'callback_url': callbackUrl,
      },
    };
  }
}
