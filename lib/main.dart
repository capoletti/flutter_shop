import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/order_list.dart';
import 'package:shop/pages/cart_page.dart';
import 'package:shop/pages/orders_page.dart';
import 'package:shop/pages/product_detail_page.dart';
import 'package:shop/pages/product_form_page.dart';
import 'package:shop/pages/products_page.dart';
import 'package:shop/pages/products_overview_page.dart';
import 'package:shop/models/product_list.dart';
import 'package:shop/utils/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductList(),
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderList(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Lato',
          primarySwatch: Colors.purple,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.purple,
          ).copyWith(
            tertiary: Colors.greenAccent,
            secondary: Colors.deepOrange,
          ),
        ),
        home: const ProductsOverviewPage(),
        routes: {
          AppRoutes.home: ((context) => const ProductsOverviewPage()),
          AppRoutes.productDetail: ((context) => const ProductDetailPage()),
          AppRoutes.cart: ((context) => const CartPage()),
          AppRoutes.orders: ((context) => const OrderPage()),
          AppRoutes.products: ((context) => const ProductsPage()),
          AppRoutes.productForm: ((context) => const ProductFormPage()),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
