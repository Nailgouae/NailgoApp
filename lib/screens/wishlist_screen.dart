import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/providers/wishprovider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<List<Product>> _wishlistFuture;

  @override
  void initState() {
    super.initState();
    _wishlistFuture = fetchWishlistItems();
    Provider.of<WishlistProvider>(context, listen: false).fetchWishlist();
  }

  Future<List<Product>> fetchWishlistItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://nailgo.ae/api/v2/wishlists'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((item) => Product.fromJson(item['product'])).toList();
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(centerTitle: true, title: Text('wish'.tr())),
    body: FutureBuilder<List<Product>>(
      future: _wishlistFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(strokeWidth: 1));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final wishlistItems = snapshot.data!;
          
          // If the wishlist is empty, display a message
          if (wishlistItems.isEmpty) {
            return Center(child: Text('No wishlist items'));
          }

          return Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, _) {
              return ListView.builder(
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final product = wishlistItems[index];
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      height: 100,
                      width: 360,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: ListTile(
                          leading: Image.network(product.thumbnailImage),
                          title: Text(product.name),
                          subtitle: Text(
                            product.basePrice.replaceAll('Rs', ''),
                            style: TextStyle(color: Color(0xFFB95C04)),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await wishlistProvider.toggleWishlist(
                                  product.id.toString(), context);
                              setState(() {
                                wishlistItems.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    ),
  );
}
}



class Product {
  final int id;
  final String name;
  final String thumbnailImage;
  final String basePrice;
  final int rating;

  Product({
    required this.id,
    required this.name,
    required this.thumbnailImage,
    required this.basePrice,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      thumbnailImage: json['thumbnail_image'],
      basePrice: json['base_price'],
      rating: json['rating'],
    );
  }
}
