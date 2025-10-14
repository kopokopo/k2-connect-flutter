# Kopokopo Flutter SDK

This is a package to assist developers in consuming Kopokopo's API

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Installation

To install run the following command on your project's directory:

```
flutter pub add k2_connect_flutter
```

## Initialisation
The `K2ConnectFlutter` class is a singleton that maintains state across your app lifecycle.

```dart
import 'package:k2_connect_flutter/k2_connect_flutter.dart';

// Do not hard code your credentials. We recommend storing them in a .env file(see example app)

await K2ConnectFlutter.initialize(
  baseUrl: 'sandbox.kopokopo.com',
  credentials: K2ConnectCredentials(
    clientId: 'YOUR_CLIENT_ID',
    clientSecret: 'YOUR_CLIENT_SECRET',
    apiKey: 'YOUR_API_KEY',
  ),
  loggingEnabled: true, // Optionally enable logging. This is disabled by default
);
```

### After initialization, you can get instances of offered services as follows:

- [Tokens](#tokenservice) : `final TokenService tokenService = K2ConnectFlutter.tokenService();`
- [STK PUSH](#stkservice) : `final StkService stkService = K2ConnectFlutter.stkService();`

## Usage

### Tokens

To send any requests to Kopokopo's API you'll need an access token. You will need to securely maintain this token and pass
it when making requests to Kopo Kopo APIs.

```dart
final TokenService tokenService = K2ConnectFlutter.tokenService();

// Get the access token using the token service
final TokenResponse tokenResponse = await tokenService.requestAccessToken();

// Print the response
print("Token response: $tokenResponse");

// Securely store the tokenResponse and track expiry
```

### STK PUSH

- Initiating a payment request with UI

```dart
final stkPushRequest = StkPushRequest(
  companyName: 'Test Company',
  tillNumber: 'K12345',
  amount: Amount(currency: 'KES', value: '1.00'),
  callbackUrl: 'https://webhook.site/your-callback-url',
  metadata: {'source': 'flutter-app'},
  onSuccess: () => print('Payment success'),
  onError: (error) => print('Payment error: $error'),
  accessToken: 'myRand0mAcc3ssT0k3n', // the access token you requested
);

final stkService = K2ConnectFlutter.stkService();

await stkService.requestPaymentBottomSheet(context, stkPushRequest: stkPushRequest);
```

- Initiating a payment request without UI

```dart
final stkPushRequest = StkPushRequest(
  tillNumber: 'K12345',
  subscriber: Subscriber(phoneNumber: '0712345678'),
  amount: Amount(value: '10.00', currency: 'KES'),
  callbackUrl: 'https://webhook.site/your-callback-url',
  accessToken: 'myRand0mAcc3ssT0k3n', // the access token you requested
);

final stkService = K2ConnectFlutter.stkService();

final String locationUrl = await stkService.requestPayment(stkPushRequest: stkPushRequest);
```

- To get the status of the STK push request 

```dart
final stkService = K2ConnectFlutter.stkService();

final StkPushRequestStatus stkPushRequestStatus = await stkService.requestStatus(
  uri: 'https://sandbox.kopokopo.com/api/v1/incoming_payments/d76265cd-0951-e511-80da-0aa34a9b2388',
  accessToken: 'myRand0mAcc3ssT0k3n', // Use the already generated token
);

// Print the response
print("StkPushRequestStatus: $stkPushRequestStatus");
```

## Services

The methods are asynchronous.

The only supported ISO currency code at the moment is: `KES`

### `TokenService`

- `tokenService.requestAccessToken()` to get an access token.

  - The response will contain: `accessToken`, `tokenType`, `expiresIn` and `createdAt`

NB: The access token is required to send subsequent requests

- `tokenService.revokeAccessToken('my_access_token')` to revoke an access token.

  - The response will be an empty body

NB: A revoked access token cannot be used on subsequent requests

### `StkService`

#### Initiate an STK push request

To initiate an M-Pesa STK Push payment, build a [StkPushRequest](#stkpushrequest) and call the STK service.

There are two ways to initiate an STK push request:

- `requestPaymentBottomSheet(BuildContext context, { StkPushRequest stkPushRequest })`
  - Launches a modal bottom sheet where the customer can enter their details and complete the payment.

- `requestPayment({ StkPushRequest stkPushRequest })`
  - Sends the STK Push request directly to the API without showing any UI.
  - Use this for background operations or fully custom flows.

##### StkPushRequest
- `tillNumber` (String): Your M-Pesa OR online payments till number from Kopo Kopo's Dashboard **REQUIRED**.
- `subscriber` (Subscriber?): Object containing the customer's details.
  - `phoneNumber` (String): The customer's phone number in international format (e.g., `'254712345678'`).  **REQUIRED for** `requestPayment`
  - `firstName` (String?): The customer's first name. Useful for record keeping or personalization.
  - `lastName` (String?): The customer's last name.
  - `email` (String?): The customer's email address.
- `amount` (Amount): Object specifying the value and currency (e.g., KES). **REQUIRED**
  - `value` (String): The transaction amount (e.g., '100.00'). **REQUIRED**
  - `currency` (String): ISO 4217 currency code. Defaults to `'KES'` if not specified. **REQUIRED**
- `callbackUrl` (String): The URL to receive asynchronous status updates. **REQUIRED**
- `paymentChannel` (String, default: "M-PESA STK PUSH"): The payment channel to use.
- `metadata` (Map<String, dynamic>?): Any additional information to associate with the request.
- `companyName` (String?): Display name shown in the bottom sheet UI. **RECOMMENDED for** `requestPaymentBottomSheet`
- `onSuccess` (Function?): Callback invoked when the payment flow completes successfully. **RECOMMENDED for** `requestPaymentBottomSheet`
- `onError` (Function?(String error)): Callback invoked when an error occurs. **RECOMMENDED for** `requestPaymentBottomSheet`.
- `accessToken`: Gotten from the [`TokenService`](#tokenservice) response **REQUIRED**
- `metadata`: (Map<String, dynamic>?) A map containing a maximum of 5 key value pairs

#### Query the status of an STK Push request
- `requestStatus({ required String uri, required String accessToken })`
  - `uri`: The location url you got from the [requestPayment()](#initiate-an-stk-push-request) response. **REQUIRED**
  - `accessToken`: Gotten from the [`TokenService`](#tokenservice) response **REQUIRED**

Returns a strongly typed [StkPushRequestStatus](#stkpushrequeststatus)

##### `StkPushRequestStatus`
- `id` (String): Unique reference of the request.
- `type` (String): The type of request (e.g., "incoming_payment").
- `attributes` (StkPushRequestAttributes):
  - `initiationTime` (String): The time the request was initiated at.
  - `status` (String): The status of the request.
  - `event` (Event?):
    - `type` (String): Describes the event (e.g., "Incoming Payment Request").
    - `resource` (dynamic): Associated resource, if payment is complete it will contain the transaction details.
    - `errors` (String): If the request failed, this will contain the error message.
  - `metadata` (Map<String, dynamic>?): Metadata that you sent with the request.
  - `links` (Links): Object containing callback and self URLs.
    - `callbackUrl` (String): The URL you provided when initiating the request.
    - `self` (String): The location URL to for the request.

For more information, please read <https://api-docs.kopokopo.com/#receive-payments-from-m-pesa-users-via-stk-push>


### Responses and Results

- All the post requests are asynchronous apart from `TokenService`. This means that the result will be posted to your custom callback url when the request is complete. The immediate response of the post requests contain the `location` url of the request you have sent which you can use to query the status.

Note: The asynchronous results are processed like webhooks.

## Contributing

We welcome contributions from the community!

See the [Contributing Guide](https://github.com/kopokopo/k2-connect-flutter/CONTRIBUTING.md) for details on:
- How to set up your environment
- Branching and commit guidelines
- Running tests and submitting PRs

## Issues & Support

- Report bugs or request features on the issue tracker
- Include Flutter/Dart version, reproduction steps, and logs where possible
- Response times are on a best-effort basis
- For urgent production issues, please use official Kopo Kopo support channels

## Changelog

See the [CHANGELOG.md](https://github.com/kopokopo/k2-connect-flutter/CHANGELOG.md) for release history.

Latest release:

#### 0.0.1 - Initial Release
- Initial release of `k2_connect_flutter`
- Basic SDK setup for K2 Connect
- Token management (access token retrieval)
- STK Push payment initiation:
  - `requestPaymentBottomSheet` (with UI)
  - `requestPayment` (direct API call)
  - `requestStatus` (query request status)
- Example Flutter app demonstrating integration
