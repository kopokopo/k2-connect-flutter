import 'stk_push_request.dart';

class StkPushRequestValidator {
  static void validate(StkPushRequest request) {
    if (request.amount.value.isEmpty) {
      throw ArgumentError('Amount is required.');
    }

    if (request.metadata != null && request.metadata!.length > 5) {
      throw ArgumentError(
          'Metadata can contain a maximum of 5 key-value pairs.');
    }
  }
}
