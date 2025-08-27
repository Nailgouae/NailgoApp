import 'package:flutter/material.dart';

class ApplePayPage extends StatelessWidget {
  final String orderId;
   final double totalAmount;

  ApplePayPage({required this.orderId, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apple Pay'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Order ID: $orderId',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
             Text(
              'Total Amount: \$${totalAmount.toString()}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement the Apple Pay functionality here
                // Use the relevant Apple Pay Flutter packages or methods
                print('Initiating Apple Pay for order ID: $orderId');
              },
              child: Text('Pay with Apple Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
