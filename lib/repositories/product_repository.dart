import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nailgonew/helpers/shared_value_helper.dart';
import 'package:nailgonew/models/product_mini_response.dart';



class ProductRepository {
  Future<ProductMiniResponse> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('http://nailgo.ae/api/v2/products/search?query=$query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${access_token.$}',
      },
    );
    print(response.body); 
    final productMiniResponse = ProductMiniResponse.fromJson(json.decode(response.body));
    return productMiniResponse;
  }

  Future<ProductMiniResponse> getTodaysDealProducts() async {
    final response = await http.get(
      Uri.parse('http://nailgo.ae/api/v2/products/todays-deal'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print(response.body); 
    final productMiniResponse = ProductMiniResponse.fromJson(json.decode(response.body));
    return productMiniResponse;
  }

  Future<ProductMiniResponse> getBestSellingProducts() async {
    final response = await http.get(
      Uri.parse('http://nailgo.ae/api/v2/products/best-seller'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${access_token.$}'
      },
    );
    print(response.body); 
    return ProductMiniResponse.fromJson(json.decode(response.body));
  }
}