import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/models/addresmodel.dart';
import 'package:nailgonew/services/address_service.dart';
import 'package:nailgonew/screens/checkout.dart';
import 'package:nailgonew/screens/login.dart';
import 'package:nailgonew/screens/success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Address> _addresses = [];
  late AddressService _addressService;
  bool isLoggedIn = false;
  String userPhone = '';
  int? _selectedAddressId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    _loadAddresses();
  }

  void _createOrder() async {
    if (_selectedAddressId != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String accessToken = prefs.getString('accessToken') ?? '';
      String userId = prefs.getString('userId') ?? '';

      if (accessToken.isNotEmpty && userId != '') {
        Map<String, dynamic> requestBody = {
          "owner_id": userId,
          "user_id": userId,
          "payment_type": "cash_on_delivery"
        };

        Uri url = Uri.http('nailgo.ae', '/api/v2/order/store');

        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        };

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
                child: CircularProgressIndicator(
              color: Color.fromARGB(255, 185, 92, 4),
              strokeWidth: 1,
            ));
          },
        );

        try {
          final response = await http.post(
            url,
            headers: headers,
            body: jsonEncode(requestBody),
          );

          Navigator.pop(context);

          if (response.statusCode == 200) {
            print(response.body);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Success()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create order: ${response.statusCode}'),
              ),
            );
          }
        } catch (e) {
          print('Error creating order: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating order: $e'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Access token or user ID not available'),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('noaddress'.tr()),
            content: Text('chooseaddress'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('ok'.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _deleteAddress(int addressId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      print('Access Token: $accessToken');
      print('Address ID: $addressId');

      final response = await http.get(
        Uri.parse('http://nailgo.ae/api/v2/user/shipping/delete/$addressId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);

        setState(() {
          _addresses.removeWhere((address) => address.id == addressId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address removed'),
          ),
        );
      } else {
        print('Failed to delete address: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting address: $e');
    }
  }

  Future<void> _loadAddresses() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      _addressService = AddressService(accessToken);
      final addresses = await _addressService.getUserAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading addresses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectAddress(int addressId) {
    setState(() {
      _selectedAddressId = addressId;
    });
    _updateAddressInCart();
  }
Future<void> _updateAddressInCart() async {
  if (_selectedAddressId != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';
    String userId = prefs.getString('userId') ?? '';

    if (accessToken.isNotEmpty && userId.isNotEmpty) {
      final url = Uri.parse('http://nailgo.ae/api/v2/update-address-in-cart');
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode({
            'user_id': userId,
            'address_id': _selectedAddressId,  // Pass the selected address ID
          }),
        );

        if (response.statusCode == 200) {
          print(response.body);
          // Handle successful response
          print('Address updated in cart successfully');
        } else {
          // Handle error response
          print('Failed to update address in cart');
        }
      } catch (e) {
        print('Error updating address in cart: $e');
      }
    } else {
      print('Access token or user ID is missing');
    }
  } else {
    print('No address selected');
  }
}
  void _proceedToCheckout() {
    if (_selectedAddressId != null) {
      Address? selectedAddress = _addresses.firstWhere(
        (address) => address.id == _selectedAddressId,
      );

      if (selectedAddress != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckOut(
              selectedAddress: selectedAddress,
              phoneNumber: selectedAddress.phone,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'pleaseaddressvalid'.tr(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'pleaseaddress'.tr(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addAddress() async {
    final address = _addressController.text;
    final phone = _phoneController.text;
    try {
      await _addressService.addUserAddress(address, phone);
      _addressController.clear();
      _phoneController.clear();

      await _loadAddresses();
    } catch (e) {
      print('Error adding address: $e');
    }
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        userPhone = prefs.getString('userPhone') ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'address'.tr(),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading ? _buildLoadingWidget() : _buildAddressBody(),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(
        color: Color.fromARGB(255, 185, 92, 4),
        strokeWidth: 1,
      ),
    );
  }

  Widget _buildAddressBody() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: isLoggedIn ? buildAddressList() : buildLoginPrompt(),
          ),
          InkWell(
            onTap: () {
              if (isLoggedIn) {
                _showAddAddressDialog();
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text("addressnew".tr())),
              ),
            ),
          ),
          InkWell(
            onTap: _proceedToCheckout,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(255, 185, 92, 4)),
                child: Center(
                    child: Text(
                  "placeorder".tr(),
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildAddressList() {
    return ListView.builder(
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return GestureDetector(
          onTap: () {
            _selectAddress(address.id);
          },
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedAddressId == address.id
                    ? Color.fromARGB(255, 185, 92, 4)
                    : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(10),
            child: ListTile(
              minLeadingWidth: 5,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("address".tr(),
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.address != null
                                  ? address.address!
                                  : "noaddressavailable".tr(),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("phonee".tr(),
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      SizedBox(width: 20),
                      Text(
                        address.phone != null
                            ? address.phone!
                            : 'No phone available',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _deleteAddress(address.id);
                      }),
                  SizedBox(width: 10),
                  _selectedAddressId == address.id
                      ? Container(
                          height: 25,
                          width: 25,
                          child: Image.asset('assets/checked.png'),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLoginPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Please login to continue',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: Text('Login'),
        ),
      ],
    );
  }

  void _showAddAddressDialog() {
    _phoneController.text = userPhone;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            Container(
              height: 400.0,
              width: 350,
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      _buildTextFieldWithBorder('name'.tr(), nameController),
                      SizedBox(height: 10),
                      _buildTextFieldWithBorder(
                          'address'.tr(), _addressController,
                          height: 100.0),
                      SizedBox(height: 10),
                      _buildTextFieldWithBorder('phone'.tr(), _phoneController),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 185, 92, 4),
                      borderRadius: BorderRadius.circular(8.0)),
                  height: 50,
                  width: 270,
                  child: TextButton(
                    onPressed: () {
                      if (_validateFields()) {
                        _addAddress();
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'addaddress'.tr(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 50,
                  width: 270,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'cancel'.tr(),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  bool _validateFields() {
    if (nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showAlertDialog('please'.tr());
      return false;
    } else if (_phoneController.text.length != 10) {
      _showAlertDialog('phonemust'.tr());
      return false;
    }
    return true;
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('validation'.tr()),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('ok'.tr()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextFieldWithBorder(
      String label, TextEditingController controller,
      {double height = 50.0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                height: height,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  maxLines: label == 'Address' ? null : 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  TextEditingController nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
}
