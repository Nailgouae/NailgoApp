import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/screens/home.dart';
import 'package:nailgonew/screens/notsucces.dart';
import 'package:nailgonew/screens/success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String orderReference;
  final String accessToken;

  WebViewPage({
    required this.url,
    required this.orderReference,
    required this.accessToken,
  });

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _webViewController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _onPageStarted,
          onPageFinished: _onPageFinished,
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('order/success')) {
              setState(() {
                _isLoading = true;
              });

              _checkPaymentStatus().then((response) {
                setState(() {
                  _isLoading = false;
                });

                if (response['payment_status'] == "1") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Success()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => NotSuccess()),
                  );
                }
              }).catchError((error) {
                setState(() {
                  _isLoading = false;
                });
              });

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<Map<String, dynamic>> _checkPaymentStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';

    final url = Uri.parse('http://nailgo.ae/api/v2/checkpaymentstatus');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final body = jsonEncode({
      'payment_reference': widget.orderReference,
      'access_token': widget.accessToken,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check payment status');
    }
  }

  void _onPageStarted(String url) {
    print('Page started loading: $url');
  }

  void _onPageFinished(String url) {
    print('Page finished loading: $url');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Network International'),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
