import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/models/addresmodel.dart';
import 'package:nailgonew/screens/applepay.dart';
import 'package:nailgonew/screens/payment.dart';
import 'package:nailgonew/screens/success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CheckOut extends StatefulWidget {
  final Address? selectedAddress;
  final String? phoneNumber;

  CheckOut({this.selectedAddress, this.phoneNumber});
  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
 
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emiratesController = TextEditingController();
   bool isLoading = false; 
  String userName = '';
  String userEmail = '';
  bool isLoggedIn = false;


List<Map<String, String>> paymentOptions = [];  // Correctly define as List of Maps
String? selectedPaymentOptionKey;


  @override
  void initState() {
    super.initState();
    checkLoginStatus();
   
  fetchPaymentTypes(); // Fetch payment types on init

  }
  




Future<void> fetchPaymentTypes() async {
  try {
    final response = await http.get(Uri.http('nailgo.ae', '/api/v2/payment-types'));
    print('API Response: ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      setState(() {
        paymentOptions = jsonData.map<Map<String, String>>((paymentType) {
          return {
            'payment_type_key': paymentType['payment_type_key'],
            'title': paymentType['title'],
            'image': paymentType['image'],
          };
        }).toList();

        // Add Apple Pay option for iOS
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          paymentOptions.add({
            'payment_type_key': 'Apple Pay',
            'title': 'CheckOut With Apple Pay',
            'image': 'assets/applepay.jpg', // Replace with the actual image path
          });
        }
      });
    } else {
      print('Failed to fetch payment types: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching payment types: $e');
  }
}


  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        userName = prefs.getString('userName') ?? '';
        userEmail = prefs.getString('userEmail') ?? '';

        firstNameController.text = userName;
        emailController.text = userEmail;
        phoneNumberController.text =
            widget.phoneNumber ?? 'No phone number available';

        if (widget.selectedAddress != null) {
          List<String> addressLines =
              widget.selectedAddress!.address!.split('\n');
          addressController.text = addressLines.join(', ');
        } else {
          addressController.text = 'No address selected';
        }
      }
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();

    emailController.dispose();
    phoneNumberController.dispose();
   
    addressController.dispose();
    emiratesController.dispose();
    super.dispose();
  }



 
  String errorMessage = '';

 

void _createOrder() async {
  print("🚀 _createOrder called");

  if (firstNameController.text.isEmpty ||
      emailController.text.isEmpty ||
      phoneNumberController.text.isEmpty ||
      addressController.text.isEmpty ||
      selectedEmirates == null ||
      selectedPaymentOptionKey == null) {
    print("⚠️ Missing required fields");
    _showFillFieldsDialog();
    return;
  }

  setState(() {
    isLoading = true;
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String accessToken = prefs.getString('accessToken') ?? '';
  String userId = prefs.getString('userId') ?? '';
  int? ownerId = prefs.getInt('ownerId');

  print("🔑 Access Token: $accessToken");
  print("👤 User ID: $userId");
  print("🏠 Owner ID: $ownerId");
  print("💳 Selected Payment Option: $selectedPaymentOptionKey");

  if (accessToken.isNotEmpty && userId.isNotEmpty) {
    try {
      print("📡 Fetching finger data...");
      final fingerResponse = await http.post(
        Uri.http('nailgo.ae', '/api/v2/getfingerdata'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({"id": userId}),
      );

      print("📥 Finger data response: ${fingerResponse.body}");

      if (fingerResponse.statusCode == 200) {
        var fingerData = jsonDecode(fingerResponse.body)['finger_data'];

        Map<String, dynamic> requestBody = {
          "owner_id": ownerId,
          "user_id": userId,
          "payment_type": selectedPaymentOptionKey,
          "finger_data": fingerData,
        };

        print("📝 Creating order with body: $requestBody");

        final response = await http.post(
          Uri.http('nailgo.ae', '/api/v2/order/store'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(requestBody),
        );

        print("📥 Order creation response: ${response.body}");

        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          var combinedOrderId = responseBody['combined_order_id'];
          var totalAmount = responseBody['order_amount'];

          if (selectedPaymentOptionKey == 'Cash on Delivery') {
            print("💵 COD selected — navigating to success page");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Success()));
          } 
          else if (selectedPaymentOptionKey == 'Apple Pay') {
            print("🍎 Apple Pay selected — navigating to Apple Pay page");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ApplePayPage(
                  orderId: combinedOrderId,
                  totalAmount: totalAmount,
                ),
              ),
            );
          } 
          else {
            print("💳 Other payment selected — calling getpaymentlink...");
            Map<String, dynamic> paymentRequestBody = {
              "id": userId,
              "order_id": combinedOrderId,
            };

            final paymentResponse = await http.post(
              Uri.http('nailgo.ae', '/api/v2/getpaymentlink'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
              body: jsonEncode(paymentRequestBody),
            );

            print("📥 Payment link response: ${paymentResponse.body}");

            if (paymentResponse.statusCode == 200) {
              var responseData = jsonDecode(paymentResponse.body);
              String paymentLink = responseData['payment_link'];
              String orderReference = responseData['order_reference'];
              String accessToken = responseData['access_token'];

              print("🌐 Navigating to WebView with link: $paymentLink");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewPage(
                    url: paymentLink,
                    orderReference: orderReference,
                    accessToken: accessToken,
                  ),
                ),
              );
            } else {
              print("❌ Failed to get payment link: ${paymentResponse.statusCode}");
              setState(() {
                errorMessage =
                    'Failed to get payment link: ${paymentResponse.statusCode}';
              });
            }
          }
        } else {
          print("❌ Failed to create order: ${response.statusCode}");
          setState(() {
            errorMessage = 'Failed to create order: ${response.statusCode}';
          });
        }
      } else {
        print("❌ Failed to get finger data: ${fingerResponse.statusCode}");
        setState(() {
          errorMessage = 'Failed to get finger data: ${fingerResponse.statusCode}';
        });
      }
    } catch (e) {
      print("🔥 Error in _createOrder: $e");
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  } else {
    print("❌ No access token or user ID found");
    setState(() {
      errorMessage = 'Access token or user ID not available';
      isLoading = false;
    });
  }
}



void _showFillFieldsDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.yellow, size: 40),
            SizedBox(width: 10),
          
          ],
        ),
        content: Text(
          'somefields'.tr(),
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('ok'.tr(), style: TextStyle(color: Colors.orange)),
          ),
        ],
      );
    },
  );
}



Future<List<String>> fetchCities() async {
  try {
    final response = await http.get(Uri.http('nailgo.ae', '/api/v2/cities'));
    print('API Response: ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is Map && jsonData.containsKey('data')) {
        return List<String>.from(jsonData['data'].map((city) => city['name']));
      } else {
        throw Exception('Invalid API response: "data" key not found');
      }
    } else {
      throw Exception('Failed to fetch cities: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching cities: $e');
    return []; // Return an empty list to handle errors gracefully
  }
}

 List<String> emirates = [
    'Abu Dhabi',
    'Dubai',
    'Sharjah',
    'Ajman',
    'Umm Al-Quwain',
    'Ras Al Khaimah',
    'Fujairah',
  ];
  String? selectedEmirates = 'Dubai';  // Default value

  void _handleSubmit() {
    print("Selected Emirates: $selectedEmirates");  // Check selected value
    // Add other submission logic here
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(),
    body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 5),
                Text(
                  'checkout'.tr(),
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(height: 40),

                // First Name
                _buildInputField(
                  label: 'fn'.tr(),
                  controller: firstNameController,
                  isDropdown: false,
                ),
                SizedBox(height: 10),

                // Email
                _buildInputField(
                  label: 'email'.tr(),
                  controller: emailController,
                  isDropdown: false,
                ),
                SizedBox(height: 10),

                // Phone Number
                _buildInputField(
                  label: 'phone'.tr(),
                  controller: phoneNumberController,
                  isDropdown: false,
                ),
                SizedBox(height: 10),

                // City Dropdown
             

                // Address
                _buildInputField(
                  label: 'address'.tr(),
                  controller: addressController,
                  isDropdown: false,
                ),
                SizedBox(height: 10),

                // Emirates Dropdown
          
          _buildInputField(
              label: 'Emirates',
              isDropdown: true,
              dropdownValue: selectedEmirates,
              items: emirates,
              onChanged: (value) {
                setState(() {
                  selectedEmirates = value;
                });
              },
            ),

                SizedBox(height: 10),

                // Payment Options Dropdown
              // Payment Options Dropdown
_buildInputField(
  label: 'Payment Option',
  isDropdown: true,
  dropdownValue: selectedPaymentOptionKey,
  items: paymentOptions
      .map((paymentType) => paymentType['title'] ?? '') // Default to empty string if null
      .where((value) => value.isNotEmpty) // Remove any empty values if needed
      .toList(),
  onChanged: (value) {
    setState(() {
      selectedPaymentOptionKey = value!; // Update selected value
    });
  },
  itemImages: paymentOptions
      .map((paymentType) => paymentType['image'] ?? '') // Assuming 'payment_image' holds image path
      .where((image) => image.isNotEmpty) // Remove any empty values if needed
      .toList(),
),


                SizedBox(height: 30),

                // Order Button
                InkWell(
                  onTap: _createOrder,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'orderrr'.tr(),
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 185, 92, 4),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Loader overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _buildInputField({
  required String label,
  TextEditingController? controller,
  bool isDropdown = false,
  String? dropdownValue,
  List<String>? items,
  ValueChanged<String?>? onChanged,
  List<String>? itemImages, // List of image paths (URLs or assets)
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      SizedBox(height: 5),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: isDropdown
              ? DropdownButtonFormField<String>(
                  value: dropdownValue,
                  decoration: InputDecoration(
                    hintText: 'Choose $label',
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                  items: items?.asMap().map((index, value) {
                    return MapEntry(
                      index,
                      DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            // Check if an image exists for the current item
                            if (itemImages != null && itemImages.length > index && itemImages[index].isNotEmpty) 
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.network(itemImages[index], width: 30, height: 30),
                              ),
                            // Text is always displayed
                            Text(value),
                          ],
                        ),
                      ),
                    );
                  }).values.toList(),
                )
              : TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
        ),
      ),
    ],
  );
}}