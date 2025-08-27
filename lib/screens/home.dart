import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:nailgonew/drawer.dart';
import 'package:nailgonew/helpers/custom_widgets.dart';
import 'package:nailgonew/models/product_mini_response.dart';
import 'package:nailgonew/my_theme.dart';
import 'package:nailgonew/repositories/product_repository.dart';
import 'package:nailgonew/screens/product_detail_screen.dart';
import 'package:nailgonew/screens/profile_screen.dart';
import 'package:nailgonew/providers/wishprovider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  ProductMiniResponse? _todaysDealProducts;
  ProductMiniResponse? _bestSellingProducts;

  late Future<ProductMiniResponse> _todaysDealFuture;
  late Future<ProductMiniResponse> _bestSellingFuture;

  @override
  void initState() {
    super.initState();
    _todaysDealFuture = ProductRepository().getTodaysDealProducts();
    _bestSellingFuture = ProductRepository().getBestSellingProducts();
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        final bool isLoggedIn = snapshot.data ?? false;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: buildAppBar(statusBarHeight, context, isLoggedIn),
          drawer: isLoggedIn ? MainDrawer() : null,
          body: SafeArea(
            child: Column(
              children: [
                buildHomeSearchBox(context),
                Expanded(
                  child: _searchQuery.isEmpty
                      ? CustomScrollView(
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildListDelegate([
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'just'.tr(),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      SizedBox(
                                        height: 300,
                                        child: FutureBuilder<ProductMiniResponse>(
                                          future: _todaysDealFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.black,
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text('Error: ${snapshot.error}'));
                                            } else {
                                              _todaysDealProducts = snapshot.data;
                                              return buildHomeExplore();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 0.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "explore".tr(),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      SizedBox(
                                        height: 120,
                                        child: FutureBuilder<ProductMiniResponse>(
                                          future: _bestSellingFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.black,
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text('Error: ${snapshot.error}'));
                                            } else {
                                              _bestSellingProducts = snapshot.data;
                                              return buildHomeNewCollection();
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 70),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        )
                      : FutureBuilder<ProductMiniResponse>(
                          future: ProductRepository().searchProducts(_searchQuery),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              final List<Product>? filteredProducts =
                                  snapshot.data?.products
                                      ?.where((product) => product.name!
                                          .toLowerCase()
                                          .contains(_searchQuery.toLowerCase()))
                                      .toList();

                              return ListView.builder(
                                itemCount: filteredProducts?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts?[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ProductDetailScreen(
                                              products: filteredProducts ?? [],
                                              selectedProductIndex: index,
                                              id: product!.id!,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        height: 70,
                                        width: 300,
                                        child: Center(
                                          child: ListTile(
                                            leading: CachedNetworkImage(
                                              imageUrl: product?.thumbnail_image ?? '',
                                              placeholder: (context, url) =>
                                                  Image.asset('assets/placeholder.jpeg'),
                                              errorWidget: (context, _, url) =>
                                                  Image.asset('assets/placeholder.jpeg'),
                                            ),
                                            title: Text(product?.name ?? ''),
                                            trailing: Text(
                                                '${product!.mainPrice!.replaceAll('Rs', '')}'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildHomeExplore() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _todaysDealProducts?.products?.length ?? 0,
      itemExtent: 200,
      itemBuilder: (context, index) {
        final item = _todaysDealProducts?.products?[index];
        return Container(
          margin: EdgeInsets.only(right: 16),
          child: ProductCard(product: item!, products: _todaysDealProducts?.products ?? []),
        );
      },
    );
  }

  Widget buildHomeNewCollection() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _bestSellingProducts?.products?.length ?? 0,
      itemExtent: 300,
      itemBuilder: (context, index) {
        final item = _bestSellingProducts?.products?[index];
        return NewCollectionCard(
          product: item!,
          products: _bestSellingProducts?.products ?? [],
        );
      },
    );
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context, bool isLoggedIn) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              MyTheme.white,
              MyTheme.white.withOpacity(0.9),
              MyTheme.white.withOpacity(0.7),
              MyTheme.white.withOpacity(0.6),
              MyTheme.white,
            ],
          ),
        ),
      ),
      leading: isLoggedIn
          ? GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Image.asset('assets/nav_bar_icon.png'),
              ),
            )
          : null,
      centerTitle: true,
      title: SizedBox(
        height: 25,
        width: 100,
        child: Image.asset('assets/nailgoooo.jpg'),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: isLoggedIn
          ? <Widget>[
              const SizedBox(width: 8.0),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfileScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Image.asset('assets/profile_top_bar.png'),
                ),
              ),
              const SizedBox(width: 8.0),
            ]
          : [],
    );
  }

  Widget buildHomeSearchBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'search...'.tr(),
          hintStyle: TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.textfield_grey, width: 0.5),
            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.textfield_grey, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              CupertinoIcons.search,
              color: MyTheme.textfield_grey,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------- ProductCard ----------------------
class ProductCard extends StatefulWidget {
  final Product product;
  final List<Product> products;

  const ProductCard({required this.product, required this.products});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isAddedToWishlist = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<WishlistProvider>(context, listen: false).fetchWishlist(),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = EasyLocalization.of(context)!.locale!.languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: MyTheme.light_grey, width: 2.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    margin: EdgeInsets.all(16),
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16), bottom: Radius.zero),
                      child: CachedNetworkImage(
                        imageUrl: widget.product.thumbnail_image!,
                        placeholder: (context, url) =>
                            Image.asset('assets/placeholder.jpeg', fit: BoxFit.cover),
                        errorWidget: (context, _, url) =>
                            Image.asset('assets/placeholder.jpeg', fit: BoxFit.cover),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  FutureBuilder<bool>(
                    future: _checkLoginStatus(),
                    builder: (context, snapshot) {
                      final isLoggedIn = snapshot.data ?? false;
                      if (!isLoggedIn) return SizedBox.shrink();
                      return Consumer<WishlistProvider>(
                        builder: (context, wishlistProvider, child) {
                          final isInWishlist = wishlistProvider
                              .isProductInWishlist(widget.product.id.toString());
                          return Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                wishlistProvider.toggleWishlist(
                                    widget.product.id.toString(), context);
                              },
                              child: Image.asset(
                                isInWishlist
                                    ? 'assets/icons-34.png'
                                    : 'assets/explore_fav.png',
                                height: 60,
                                width: 60,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name!,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              Text(
                                '${widget.product.mainPrice!.replaceAll('Rs', '')}',
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Color(0xff24293d),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isRTL)
                        Container(
                          height: 36,
                          width: 36,
                          margin: EdgeInsets.only(left: 16, bottom: 8),
                          child: FloatingActionButton(
                            onPressed: () {
                              int selectedProductIndex =
                                  widget.products.indexOf(widget.product);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    products: widget.products,
                                    selectedProductIndex: selectedProductIndex,
                                    id: widget.product.id!,
                                  ),
                                ),
                              );
                            },
                            child: Image.asset('assets/add_ic.png'),
                            backgroundColor: Colors.brown.shade100,
                            elevation: 0,
                          ),
                        ),
                    ],
                  ),
                  if (!isRTL)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 36,
                        width: 36,
                        margin: EdgeInsets.only(right: 20, bottom: 8),
                        child: FloatingActionButton(
                          onPressed: () {
                            int selectedProductIndex =
                                widget.products.indexOf(widget.product);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  products: widget.products,
                                  selectedProductIndex: selectedProductIndex,
                                  id: widget.product.id!,
                                ),
                              ),
                            );
                          },
                          child: Image.asset('assets/add_ic.png'),
                          backgroundColor: Colors.brown.shade100,
                          elevation: 0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------- NewCollectionCard ----------------------
class NewCollectionCard extends StatelessWidget {
  final Product product;
  final List<Product> products;

  const NewCollectionCard({required this.product, required this.products});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        int selectedProductIndex = products.indexOf(product);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              products: products,
              selectedProductIndex: selectedProductIndex,
              id: product.id!,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: MyTheme.light_grey, width: 2.0),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16), bottom: Radius.zero),
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail_image!,
                      placeholder: (context, url) =>
                          Image.asset('assets/placeholder.jpeg', fit: BoxFit.cover),
                      errorWidget: (context, _, url) =>
                          Image.asset('assets/placeholder.jpeg', fit: BoxFit.cover),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name!,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        '${product.mainPrice!}',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Color(0xff24293d),
                          fontSize: 10,
                                                  fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(top: 32),
                  child: Image.asset(
                    'assets/right_arrow.png',
                  ),
                ),
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

