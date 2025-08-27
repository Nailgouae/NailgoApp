import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nailgonew/providers/cartprovider.dart';
import 'package:nailgonew/screens/address_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoggedIn = false;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  cartProvider.fetchCartItems();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'cart'.tr(),
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoggedIn ? buildCartItemsList(context) : buildLoginPrompt(),
    );
  }

Widget buildCartItemsList(BuildContext context) {
  return Consumer<CartProvider>(
    builder: (context, cartProvider, _) {
        if (cartProvider.cartItems == null) {
        return Center(
          child: CircularProgressIndicator(), // Show loading indicator
        );
      }
      List<dynamic> cartItems = cartProvider.cartItems;

      if (cartItems.isEmpty) {
        return Center(
          child: Text('cartis'.tr()),
        );
      }

      double totalAmount = 0.0;
      double totalShippingFee = 0.0;

      // Iterate through cart items to calculate total amount and shipping fee
      for (var item in cartItems) {
        double totalAmountForItem = 0.0;
        double totalShippingFeeForItem = 0.0;

        for (var cartItem in item['cart_items']) {
          // Parse price from string to double if needed
          double price = parsePrice(cartItem['price'] ?? '0');
          int quantity = cartItem['quantity'] ?? 0;

          totalAmountForItem += price * quantity;

          // Parse shipping cost from string to double if needed
          double shippingFee = parsePrice(item['shipping_cost'] ?? '0');
          totalShippingFeeForItem += shippingFee;
        }

        totalAmount += totalAmountForItem;
        totalShippingFee += totalShippingFeeForItem;
      }

      double subtotal = totalAmount + totalShippingFee;

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                List<dynamic> productCartItems = cartItems[index]['cart_items'];
                return Column(
                  children: productCartItems.map((cartItem) {
                    return buildCartItemCard(context, cartItem, index);
                  }).toList(),
                );
              },
            ),
          ),
          Container(
            height: 300,
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(60),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'selected'.tr(),
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        '${cartProvider.grandTotal}', // Access grandTotal here
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'shipfee'.tr(),
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        '${totalShippingFee.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 5),
                Divider(color: Colors.grey),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'total'.tr(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      Spacer(),
                      Text(
                        '${cartProvider.grandTotal}',
                        style: TextStyle(color: Colors.grey, fontSize: 23),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => AddressPage()),
                    );
                  },
                  child: Container(
                    width: 340,
                    height: 50,
                    child: Center(
                        child: Text(
                      'continue'.tr(),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(45),
                        color: Color.fromARGB(255, 185, 92, 4)),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    },
  );
}

double parsePrice(String price) {
  try {
    // Remove any non-numeric characters except '.' and ','
    String cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.parse(cleanPrice);
  } catch (e) {
    print('Error parsing price: $e');
    return 0.0; // Return 0.0 if parsing fails
  }
}
Widget buildLoginPrompt() {
  return Center(
    child: Text(
      'Please login to see cart items',
      style: TextStyle(fontSize: 18.0),
    ),
  );
}

Widget buildCartItemCard(BuildContext context, dynamic cartItem, int index) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
      height: 130,
      width: 600,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              height: 100,
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  cartItem['product_thumbnail_image'] ?? '',
                ),
              ),
            ),
//             Container(
//   height: 100,
//   width: 100,
//   child: ClipRRect(
//     borderRadius: BorderRadius.circular(20),
//     child: Image.asset(
//       'assets/na.jpg', // Replace with your actual asset path
//       fit: BoxFit.cover,
//     ),
//   ),
// ),

            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cartItem['product_name'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${cartItem['price'] ?? ''}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color.fromARGB(255, 185, 92, 4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  height: 33,
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 15),
                          onPressed: () {
                            if (cartItem['quantity'] > 1) {
                              Provider.of<CartProvider>(context, listen: false)
                                  .updateCartItemQuantity(
                                      cartItem['id'].toString(),
                                      cartItem['quantity'] - 1);
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('rem'.tr()),
                                  content: Text('doyou'.tr()),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'cancel'.tr(),
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Provider.of<CartProvider>(context,
                                                listen: false)
                                            .removeItemFromCart(
                                                cartItem['id'].toString(), index);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'remove'.tr(),
                                        style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 185, 92, 4)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                        Text('${cartItem['quantity'] ?? ''}'),
                        IconButton(
                          icon: Icon(Icons.add, size: 15),
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .updateCartItemQuantity(cartItem['id'].toString(),
                                    cartItem['quantity'] + 1);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false)
                    .removeItemFromCart(cartItem['id'].toString(), index);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
}