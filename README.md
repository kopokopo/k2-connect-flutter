<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

To get started, you will need to set up the required credentials. We recommend storing these
credentials as environment variables in a `.env` file as shown below;

```dotenv
CLIENT_ID=''
CLIENT_SECRET=''
API_KEY=''
```

Next, you will need to initialize the `K2ConnectFlutter` SDK. This class is a singleton and should
maintain its state across the entire app lifecycle. The class is initialized by calling its
`initialize` method.

```dart
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

Once initialized, you can get instances of various services as shown below;

- [TokensService](...): `K2ConnectFlutter.tokenService();`

## Usage

### Tokens

An access token is needed for all K2Connect requests. You will need to maintain this token and pass
it when making requests to Kopo Kopo APIs.

To get the access token, use the `TokenService` as shown below;

```dart
// Ensure K2ConnectFlutter is initialized
await K2ConnectFlutter.initialize(
  baseUrl: 'sandbox.kopokopo.com',
  credentials: K2ConnectCredentials(
    clientId: 'YOUR_CLIENT_ID',
    clientSecret: 'YOUR_CLIENT_SECRET',
    apiKey: 'YOUR_API_KEY',
  ),
  loggingEnabled: true, // Optionally enable logging. This is disabled by default
);

// Get the token service using K2ConnectFlutter
final TokenService tokenService = K2ConnectFlutter.tokenService();

// Get the access token using the token service
final TokenResponse tokenResponse = await tokenService.requestAccessToken();

// Print the response
print("Token response: $tokenResponse");
```

### STK Push Payments

To initiate an M-Pesa STK Push payment using K2 Connect, first create a [StkPushRequest] and pass it to the `stkService()` method along with a valid access token.

The returned service exposes the following methods:

#### 1. `requestPaymentBottomSheet(BuildContext context)`

- Launches a modal bottom sheet where the customer can confirm and complete the payment.
- Internally uses the request details to populate the UI:
  - `companyName`: Optional display name.
  - `accessToken`: Auth token.
  - `baseUrl`: API environment URL.
  - `tillNumber`: The recipient business till.
  - `currency`: Currency code (e.g., "KES").
  - `amount`: Amount to charge.
  - `callbackUrl`: Your webhook URL.
  - `metadata`: Optional payload.
  - `onSuccess`: Callback on success.
  - `onError`: Callback on failure.

#### 2. `requestPayment(StkPushRequest request)`

- Sends the STK Push request directly to the K2 API without showing any UI.
- Use this for background operations or fully custom flows.

#### `StkPushRequest`

Defines the payload required to initiate an M-Pesa STK Push request.

Fields:

- `accessToken` (String): A valid access token required to authorize the request.
- `paymentChannel` (String, default: "M-PESA STK PUSH"): The payment channel to use.
- `tillNumber` (String): The till number that will receive the payment.
- `subscriber` (Subscriber?): Object containing the customer's phone number.
- `amount` (Amount): Object specifying the value and currency (e.g., KES).
- `callbackUrl` (String): The URL to receive asynchronous status updates.
- `metadata` (Map<String, dynamic>?, optional): Any additional information to associate with the request.
- `companyName` (String?, optional): Display name shown in the bottom sheet UI.
- `onSuccess` (Function?, optional): Callback invoked when the payment flow completes successfully.
- `onError` (Function?, optional): Callback invoked when an error occurs.

The `StkPushRequest` is validated on creation to ensure required fields are present and well-formed.

#### 3. `requestStatus({ required String uri, required String accessToken })`

- Checks the status of a previously initiated STK Push request.
- Expects a `String` URI — typically from the `Location` header of a successful `requestPayment()` response.
- Makes a `GET` request to check the current state of the transaction.
- Does not display any UI — best suited for background polling or post-payment verification.
- Returns a strongly typed `StkPushRequestStatus` object with status, timestamps, metadata, and links.

#### `StkPushRequestStatus`

Response structure returned when checking the status of an STK Push request.

Fields:

- `id` (String): Unique ID of the transaction.
- `type` (String): The type of object, typically `"incoming_payment"`.
- `attributes` (StkPushRequestAttributes): Nested object with full status details.

#### `StkPushRequestAttributes`

Fields:

- `initiationTime` (String): Timestamp of request initiation.
- `status` (String): The current status (`Received`, `Failed`, or `Pending`).
- `event` (Event?): Optional event metadata with errors or updates.
- `metadata` (Map<String, dynamic>?): Custom user metadata.
- `links` (Links): Object containing callback and self URLs.

For more information, please read <https://api-docs.kopokopo.com/#receive-payments-from-m-pesa-users-via-stk-push>

**Example:**

```dart
final statusUri = initResponse.headers['location']!;
final status = await stkService.requestStatus(
  uri: statusUri,
  accessToken: token.accessToken,
);

if (status.attributes.status == 'Received') {
  print('Payment confirmed or updated');
}
```

### Types

#### `Amount`

Represents the monetary value and its currency to be used in the STK Push request.

Fields:

- `value` (String): The transaction amount (e.g., '100.00'). This field is required.
- `currency` (String, optional): ISO 4217 currency code (e.g., 'KES'). Defaults to `'KES'` if not specified.

Example:

```dart
Amount(value: '150.00'); // Uses default currency 'KES'
Amount(value: '150.00', currency: 'KES');
```

#### `Subscriber`

Represents the customer who will receive the STK Push request.

Fields:

- `phoneNumber` (String): **Required.** The customer's phone number in international format (e.g., `'254712345678'`).
- `firstName` (String?, optional): The customer's first name. Useful for record keeping or personalization.
- `lastName` (String?, optional): The customer's last name.
- `email` (String?, optional): The customer's email address.

**Example:**

```dart
Subscriber(phoneNumber: '254712345678');

Subscriber(
  phoneNumber: '254712345678',
  firstName: 'Jane',
  lastName: 'Doe',
  email: 'jane.doe@example.com',
);
```

#### `Event`

Optional event attached to the status response.

Fields:

- `type` (String): Describes the event (e.g., "Incoming Payment Request").
- `resource` (dynamic): Associated resource.
- `errors` (dynamic): Any error messages or details.

#### `Links`

Fields:

- `callbackUrl` (String): Your registered webhook URL.
- `self` (String): URL to poll the status of this transaction.

**Preconditions**

- Ensure you have called `K2ConnectFlutter.initialize(...)`.
- You must get an access token using `K2ConnectFlutter.tokenService().requestAccessToken()`.

**Example:**

```dart
final tokenService = K2ConnectFlutter.tokenService();
final token = await tokenService.requestAccessToken();

final request = StkPushRequest(
  companyName: 'Acme Corp',
  tillNumber: 'K000123',
  amount: Amount(value: '100.00'),
  callbackUrl: 'https://webhook.site/your-url',
  metadata: {'order_id': '1234'},
  accessToken: token.accessToken,
);

final stkService = K2ConnectFlutter.stkService();

// Launch bottom sheet
await stkService.requestPaymentBottomSheet(context, request: request);

// Or perform background request
final response = await stkService.requestPayment(request);
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
