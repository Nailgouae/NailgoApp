import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emiratesController = TextEditingController();
  String userName = '';
  String userEmail = '';
  bool isLoggedIn = false;
  List<String> cities = [];
  //String? selectedCity;
  bool isLoading = false;

  String? selectedEmirates;
  List<String> paymentOptions = ['cashondelivery'.tr()];
  List<String> emirates = [
    'abudhabi'.tr(),
    'dubai'.tr(),
    'sharjah'.tr(),
    'ajman'.tr(),
    'ummal'.tr(),
    'rasal'.tr(),
    'fujairah'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    checkLoginStatus();

  }

Future<void> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      userName = prefs.getString('userName') ?? '';
      userEmail = prefs.getString('userEmail') ?? '';
      // Prefill controllers with values from SharedPreferences or default empty string
      firstNameController.text = userName;
      emailController.text = userEmail;
      
      // Call the API to get profile details
      fetchProfile();
    } else {
      addressController.text = 'noaddress'.tr();
    }
  });
}

Future<void> fetchProfile() async {
  try {
    final url = Uri.parse('http://nailgo.ae/api/v2/profile/getprofile');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var userData = data['data'][0]; // Assuming the data is in a list as in your example

      setState(() {
        firstNameController.text = userData['name'] ?? '';  // Prefill firstName
        emailController.text = userData['email'] ?? '';  // Prefill email
        phoneNumberController.text = userData['phone'] ?? '';  // Prefill phone number if available
    
        addressController.text = userData['address'] ?? '';  // Prefill address if available
       String? emiratesValue = userData['emirates'];
        if (emiratesValue != null) {
          // Find the translated emirates option that matches
          String? translatedEmirate = emirates.firstWhere(
            (e) => e.toLowerCase().contains(emiratesValue.toLowerCase()),
            orElse: () => '',
          );
          emiratesController.text = translatedEmirate;
          selectedEmirates = translatedEmirate;
        }
      

      });
    } else {
      // Handle error if API request fails
      _showDialog('error'.tr(), 'failedtofetchprofile'.tr());
    }
  } catch (e) {
    _showDialog('error'.tr(), 'erroroccured'.tr());
  }
}

Future<void> _saveProfile() async {
  if (firstNameController.text.isEmpty ||
      emailController.text.isEmpty ||
      phoneNumberController.text.isEmpty ||
      addressController.text.isEmpty) {
    _showDialog('error'.tr(), 'please'.tr());
    return;
  }

  try {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    String accessToken = prefs.getString('accessToken') ?? '';

    final url = Uri.parse('http://nailgo.ae/api/v2/profile/update');

    final body = {
      'id': userId,
      'name': firstNameController.text,
      'phone': phoneNumberController.text,
      'email': emailController.text,
      'address': addressController.text,
      'city': "",
      'emirates': emiratesController.text,
    };

    print('🔄 Posting Profile Update Body: $body'); // 👈 Print before posting

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('✅ Profile update successful. Response: ${response.body}'); // 👈 Print response
      await prefs.setString('userName', firstNameController.text);
      _showDialog('success'.tr(), 'profilesuccess'.tr());
    } else {
      print('❌ Profile update failed. Status: ${response.statusCode}, Response: ${response.body}'); // 👈 Print failure info
      _showDialog('error'.tr(), 'failedprofile'.tr());
    }
  } catch (e) {
    print('🔥 Error occurred while updating profile: $e'); // 👈 Print exception
    _showDialog('error'.tr(), 'erroroccured'.tr());
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  void _showDialog(String title, String content) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog first

            if (title == 'success'.tr()) {
              Navigator.pop(context); // Then pop again to go back or close the profile screen
            }
          },
          child: Text('ok'.tr()),
        ),
      ],
    ),
  );
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
                  _buildHeader('edit'.tr()),
                  _buildTextField('fn'.tr(), firstNameController),
                  _buildTextField('email'.tr(), emailController),
                  _buildTextField('phone'.tr(), phoneNumberController),
                
                  _buildTextField('address'.tr(), addressController),
                  _buildDropdown('emira'.tr(), emirates, selectedEmirates, emiratesController),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 185, 92, 4),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Column(
      children: [
        SizedBox(height: 5),
        Text(text, style: TextStyle(fontSize: 25)),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label.tr(),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedItem, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedItem,
          decoration: InputDecoration(
            hintText: label.tr(),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          ),
          onChanged: (newValue) {
            setState(() {
              selectedItem = newValue;
              controller.text = newValue ?? '';
            });
          },
          items: items.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
      onTap: _saveProfile,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 50,
          width: 400,
          child: Center(
            child: Text(
              'save'.tr(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 185, 92, 4),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }
}
