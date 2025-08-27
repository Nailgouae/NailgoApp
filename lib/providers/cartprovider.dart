import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  List<dynamic> _cartItems = [];
  bool _isLoggedIn = false;
   String _grandTotal = '0.00';
    String get grandTotal => _grandTotal;
  int _cartItemCount = 0;
  bool _isRequestPending = false;
  Queue<Function> _requestQueue = Queue();
  double _totalAmount = 0.0;
  double get totalAmount => _totalAmount;
   
  List<dynamic> get cartItems => _cartItems;
  int get cartItemCount => _cartItemCount;
  bool get isLoggedIn => _isLoggedIn;
   bool _loading = true;
bool get isLoading => _loading;

  CartProvider() {
    checkLoginStatus();
    fetchCartItems();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }


  
 Future<void> fetchCartItems() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';
    if (accessToken.isEmpty) {
      print('Access token is empty!');
      return;
    }

    final response = await http.post(
      Uri.parse('http://nailgo.ae/api/v2/cartslist'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['data'] != null && responseData['data'] is List) {
        List<dynamic> cartData = responseData['data'];

        if (cartData.isNotEmpty) {
          int ownerId = cartData[0]['owner_id'];
          print('ownerId: $ownerId');  // Add this to verify the ownerId

          // Store ownerId in SharedPreferences
          await prefs.setInt('ownerId', ownerId);

          // Check if the ownerId is successfully stored
          print('Stored ownerId: ${prefs.getInt('ownerId')}');
        }

        // Update _grandTotal with the value from the response
        _grandTotal = responseData['grand_total'] ?? '0.00';

        _cartItems = cartData;
        _updateCartItemCount();
        notifyListeners();
        _processRequestQueue();
      } else {
        print('No data found in the response');
      }
    } else {
      print('Failed to fetch cart items: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (error) {
    print('Error fetching cart items: $error');
  }
}




  void _updateCartItemCount() {
    _cartItemCount = _cartItems.length;
  }

  void _addToRequestQueue(Function requestFunction) {
    _requestQueue.add(requestFunction);
    if (!_isRequestPending) {
      _processRequestQueue();
    }
  }

  void _processRequestQueue() async {
    if (_requestQueue.isEmpty) {
      _isRequestPending = false;
      return;
    }
    _isRequestPending = true;
    Function request = _requestQueue.removeFirst();
    await request();
    _processRequestQueue();
  }

  Future<void> updateCartItemQuantity(String cartId, int quantity) async {
    _addToRequestQueue(() async {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String accessToken = prefs.getString('accessToken') ?? '';
        if (accessToken.isEmpty) {
          print('Access token is empty!');
          return;
        }

        final response = await http.post(
          Uri.parse('http://nailgo.ae/api/v2/carts/process'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'cart_ids': cartId,
            'cart_quantities': quantity.toString(),
          }),
        );

        if (response.statusCode == 200) {
          print('Cart item quantity updated successfully');
          fetchCartItems();
        } else {
          print('Failed to update cart item quantity: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (error) {
        print('Error updating cart item quantity: $error');
      }
    });
  }

  Future<void> removeItemFromCart(String itemId, int index) async {
    _addToRequestQueue(() async {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String accessToken = prefs.getString('accessToken') ?? '';
        if (accessToken.isEmpty) {
          print('Access token is empty!');
          return;
        }

        final response = await http.post(
          Uri.parse('http://nailgo.ae/api/v2/removecart'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'id': itemId,
          }),
        );

        if (response.statusCode == 200) {
          print('Item removed successfully');
          fetchCartItems();
        } else {
          print('Failed to remove item from cart: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (error) {
        print('Error removing item from cart: $error');
      }
    });
  }
}
