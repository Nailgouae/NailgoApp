import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({Key? key}) : super(key: key);

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  final List<Map<String, dynamic>> _orders = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchOrders();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        _fetchOrders();
      }
    });
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      final response = await http.get(
        Uri.parse("http://nailgo.ae/api/v2/purchase-history?page=$_currentPage"),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> newOrders = json['data'];
        final String? nextPageUrl = json['links']['next'];

        setState(() {
          _orders.addAll(newOrders.cast<Map<String, dynamic>>());
          _hasMore = nextPageUrl != null;
          if (_hasMore) _currentPage++;
        });
      } else {
        throw Exception('failedorders'.tr());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'error'.tr()}: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('myorders'.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _orders.isEmpty && _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: _orders.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _orders.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 185, 92, 4),
                          strokeWidth: 1,
                        ),
                      ),
                    );
                  }

                  final order = _orders[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OrderItem(
                      code: order['code'],
                      date: order['date'],
                      paymentStatus: order['payment_status_string'],
                      deliveryStatus: order['delivery_status_string'],
                      grandTotal: order['grand_total'],
                    ),
                  );
                },
              ),
      ),
    );
  }
}


class OrderItem extends StatelessWidget {
  final String code;
  final String date;
  final String paymentStatus;
  final String deliveryStatus;
  final String grandTotal;

  const OrderItem({
    required this.code,
    required this.date,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$code',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Color.fromARGB(255, 185, 92, 4),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.calendar_month, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(date),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.payment, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Payment Status :- $paymentStatus',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      paymentStatus == 'Paid'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color:
                          paymentStatus == 'Paid' ? Colors.green : Colors.red,
                      size: 15,
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.delivery_dining, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Delivery Status :- $deliveryStatus',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'grandtotal'.tr(),
                      style: TextStyle(color: Color.fromARGB(255, 185, 92, 4)),
                    ),
                    Text(
                      grandTotal,
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
