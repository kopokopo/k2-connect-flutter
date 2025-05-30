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

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
