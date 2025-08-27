import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/models/product_mini_response.dart';
import 'package:nailgonew/screens/cart.dart';
import 'package:nailgonew/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final List<Product> products;
  final int selectedProductIndex;

  const ProductDetailScreen({
    Key? key,
    required this.products,
    required this.selectedProductIndex,
    required int id,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  List<Product> cartItems = [];
  bool isLoading = false;

  Future<void> _addToCart(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  if (!isLoggedIn) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("login_required".tr()),
      content: Text("login_prompt".tr()),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text("cancell".tr()),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red, // Text color for Cancel
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 185, 92, 4), // Brown background
            foregroundColor: Colors.white, // Text color
          ),
          child: Text("login".tr()),
        ),
      ],
    ),
  );
  return;
}



      Product selectedProduct = widget.products[widget.selectedProductIndex];

      String userId = prefs.getString('userId') ?? '';
      String accessToken = prefs.getString('accessToken') ?? '';

      Product productToAdd = Product(
        id: selectedProduct.id,
        name: selectedProduct.name,
        thumbnail_image: selectedProduct.thumbnail_image,
        hasDiscount: selectedProduct.hasDiscount,
        discount: selectedProduct.discount,
        strokedPrice: selectedProduct.strokedPrice,
        mainPrice: selectedProduct.mainPrice,
        rating: selectedProduct.rating,
        sales: selectedProduct.sales,
        quantity: quantity,
      );

      print('accessToken: $accessToken');
      print('id: ${productToAdd.id}');
      print('variant: None');
      print('userId: $userId');
      print('quantity: ${productToAdd.quantity}');

      final apiUrl = 'http://nailgo.ae/api/v2/carts/add';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      final requestBody = {
        'id': productToAdd.id,
        'variant': '',
        'user_id': userId,
        'quantity': productToAdd.quantity,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Product added to cart successfully.');

        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Expanded(
                    child: Text('addedtocart'.tr()),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(),
                        ),
                      );
                    },
                    child: Text(
                      'gotocart'.tr(),
                      style: TextStyle(color: Color.fromARGB(255, 185, 92, 4)),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print('Unexpected response format: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unexpected response format. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        final responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['message'] ?? 'Failed to add to Cart';
        print('Failed to add product to cart: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error, stackTrace) {
      print('Error during addToCart: $error');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to Cart. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Product product = widget.products[widget.selectedProductIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 430,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(product.thumbnail_image!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0),
                  ),
                ),
              ),
//               Container(
//   width: MediaQuery.of(context).size.width,
//   height: 430,
//   decoration: BoxDecoration(
//     image: DecorationImage(
//       image: AssetImage('assets/na.jpg'), // your dummy image path
//       fit: BoxFit.cover,
//     ),
//     borderRadius: BorderRadius.only(
//       bottomLeft: Radius.circular(50.0),
//       bottomRight: Radius.circular(50.0),
//     ),
//   ),
// ),

              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '${product.mainPrice!.replaceAll('Rs', '')}',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: Color.fromARGB(255, 134, 34, 3),
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Text(
                      product.name!,
                      style: TextStyle(
                        fontSize: 23.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'description'.tr(),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  'Product description goes here. This is a sample description of the product.',
                  style: TextStyle(fontSize: 11.0, fontFamily: 'Montserrat'),
                ),
              ),
              SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          updateQuantity(-1);
                        },
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          updateQuantity(1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40.0),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              centerTitle: true,
              title: Text(
                'product'.tr(),
                style: TextStyle(
                    fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () {
                _addToCart(context);
              },
              child: Container(
                height: 65,
                width: 170,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 185, 92, 4),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: Center(
                  child: Text(
                    'add'.tr(),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
            ),
          ),
          isLoading
              ? Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 185, 92, 4)),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  void updateQuantity(int change) {
    setState(() {
      quantity += change;
      if (quantity < 1) {
        quantity = 1;
      }
    });
  }
}
