import 'package:example/utils/secure_storage_helper.dart';
import 'package:example/utils/secure_storage_keys.dart';
import 'package:example/utils/utilities.dart';
import 'package:example/widgets/access_token_card.dart';
import 'package:example/widgets/request_payment_card.dart';
import 'package:example/widgets/revoke_access_token_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:k2_connect_flutter/k2_connect_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _accessTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _initializeK2Connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'K2 Connect Flutter Demo App',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Request access token',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.0),
                AccessTokenCard(
                  controller: _accessTokenController,
                  requestAccessToken: _requestAccessToken,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Revoke access token',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.0),
                RevokeAccessTokenCard(
                  revokeAccessToken: _revokeAccessToken,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Request payment',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.0),
                RequestPaymentCard(
                  showRequestPaymentBottomSheet: _showRequestPaymentBottomSheet,
                ),
              ],
            ),
          ),
        ),
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
  }

  void _requestAccessToken() async {
    showProgressDialog(context);
    final TokenService tokenService = K2ConnectFlutter.tokenService();
    final tokenResponse = await tokenService.requestAccessToken();

    await SecureStorageHelper.saveValue(
      key: SecureStorageKeys.authToken,
      value: tokenResponse.accessToken,
    );

    setState(() {
      dismissProgressDialog(context);
      _accessTokenController.text = tokenResponse.accessToken;
    });
  }

  void _revokeAccessToken() async {
    showProgressDialog(context);
    final String? accessToken =
        await SecureStorageHelper.getValue(SecureStorageKeys.authToken);

    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        showSnackBar(context, "Please generate an access token first");
      });
      return;
    }

    final TokenService tokenService = K2ConnectFlutter.tokenService();
    await tokenService.revokeAccessToken(accessToken);

    await SecureStorageHelper.deleteValue(SecureStorageKeys.authToken);

    setState(() {
      dismissProgressDialog(context);
      _accessTokenController.text = '';
      showSnackBar(context, "Token revoked successfully");
    });
  }

  void _showRequestPaymentBottomSheet() async {
    final String? accessToken =
        await SecureStorageHelper.getValue(SecureStorageKeys.authToken);

    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        showSnackBar(context, "Please generate an access token first");
      });
      return;
    }

    final request = StkPushRequest(
      companyName: 'Diba Med',
      tillNumber: 'K676719',
      amount: Amount(currency: 'KES', value: '1.00'),
      callbackUrl: 'https://webhook.site/your-callback-url',
      metadata: {'source': 'flutter-app'},
      onSuccess: () => debugPrint('🟢 Payment success'),
      onError: (error) => debugPrint('🔴 Payment error: $error'),
      accessToken: accessToken,
    );

    final stkService = K2ConnectFlutter.stkService();

    // ignore: use_build_context_synchronously
    await stkService.requestPaymentBottomSheet(context, request: request);
  }
}
