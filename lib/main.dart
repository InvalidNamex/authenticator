import 'dart:convert'; // Import for JSON encoding

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authenticator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Authentication(),
    );
  }
}

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final formkey = GlobalKey<FormState>();
  final userNameTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final apiUrlTextEditingController = TextEditingController();
  final apiKeyTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: formkey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo.jpeg',
                      width: 250,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  _buildTextField(
                      'Username', userNameTextEditingController, false),
                  _buildTextField(
                      'Password', passwordTextEditingController, true),
                  _buildTextField(
                      'API URL', apiUrlTextEditingController, false),
                  _buildTextField(
                      'Secret Key', apiKeyTextEditingController, true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Validate inputs, can't be empty
                      if (formkey.currentState!.validate()) {
                        final Map<String, String> loginData = {
                          'username': userNameTextEditingController.text,
                          'password': passwordTextEditingController.text,
                          'apiURL': apiUrlTextEditingController.text,
                          'secretKey': apiKeyTextEditingController.text,
                        };

                        // Encode loginData as JSON
                        final String qrData = json.encode(loginData);

                        // Display QR code in a dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Center(
                                child:
                                    Text(userNameTextEditingController.text)),
                            content: DisplayQR(qrData: qrData),
                            actions: [
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('Generate QR'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      String _url = 'assets/eit.apk';
                      await _launchInBrowser(Uri.parse(_url));
                    },
                    child: const Text(
                      'Download app',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(
      String label, TextEditingController controller, bool obsecure) {
    return Card(
      child: ListTile(
        leading: Text(label),
        title: TextFormField(
          obscureText: obsecure,
          controller: controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ),
    );
  }
}

class DisplayQR extends StatelessWidget {
  const DisplayQR({
    super.key,
    required this.qrData,
  });

  final String qrData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: QrImageView(
        data: qrData, // QR code content
        version: QrVersions.auto,
        size: 200.0,
      ),
    );
  }
}

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}
