// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:k2_connect_flutter/k2_connect_flutter.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    _initializeK2Connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ElevatedButton(
        onPressed: () async {
          final TokenService tokenService = K2ConnectFlutter.tokenService();
          final tokenResponse = await tokenService.requestAccessToken();

          final request = StkPushRequest(
            companyName: 'Diba Med',
            tillNumber: 'K676719',
            amount: Amount(currency: 'KES', value: '1.00'),
            callbackUrl: 'https://webhook.site/your-callback-url',
            metadata: {'source': 'flutter-app'},
            onSuccess: () => print('🟢 Payment success'),
            onError: (error) => print('🔴 Payment error: $error'),
            accessToken: tokenResponse.accessToken,
          );

          final stkService = K2ConnectFlutter.stkService(
          );

          // ignore: use_build_context_synchronously
          await stkService.requestPaymentBottomSheet(context, request: request);
        },
        child: const Text('Pay now'),
      ),
    );
  }

  void _initializeK2Connect() async {
    await K2ConnectFlutter.initialize(
      baseUrl: dotenv.env['BASE_URL'] ?? '',
      credentials: K2ConnectCredentials(
        clientId: dotenv.env['CLIENT_ID'] ?? '',
        clientSecret: dotenv.env['CLIENT_SECRET'] ?? '',
        apiKey: dotenv.env['API_KEY'] ?? '',
      ),
      loggingEnabled: true,
    );

    final TokenService tokenService = K2ConnectFlutter.tokenService();
    final tokenResponse = await tokenService.requestAccessToken();

    print("Token response: $tokenResponse");
  }
}
