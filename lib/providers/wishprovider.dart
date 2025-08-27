import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProvider with ChangeNotifier {
  Set<String> _wishlist = Set<String>();

  Set<String> get wishlist => _wishlist;

  bool isProductInWishlist(String productId) {
    return _wishlist.contains(productId);
  }

  Future<void> fetchWishlist() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String accessToken = prefs.getString('accessToken') ?? '';

      final response = await http.get(
        Uri.parse('http://nailgo.ae/api/v2/wishlists'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        _wishlist = data
            .map((item) => item['product']['id'].toString())
            .toSet();

        notifyListeners();
      } else {
        throw Exception('Failed to load wishlist items');
      }
    } catch (e) {
      print('Error fetching wishlist: $e');
    }
  }

  Future<void> toggleWishlist(String productId, BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';
      String accessToken = prefs.getString('accessToken') ?? '';

      bool isAdded = _wishlist.contains(productId);
      final url = Uri.http(
        'nailgo.ae',
        isAdded
            ? '/api/v2/wishlists-remove-product'
            : '/api/v2/wishlists-add-product',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'product_id': productId,
        }),
      );

   if (response.statusCode == 200) {
  if (isAdded) {
    _wishlist.remove(productId);
  } else {
    _wishlist.add(productId);
    
    // Show custom snackbar when product is added
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Product added to wishlist',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 209, 180, 137),
        duration: Duration(seconds: 2),
      ),
    );
  }
  notifyListeners();
}

    } catch (e) {
      print('Error toggling wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
