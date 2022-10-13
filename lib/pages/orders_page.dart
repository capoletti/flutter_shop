import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/order_widget.dart';
import 'package:shop/models/order_list.dart';

import '../components/app_drawer.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
      ),
      body: FutureBuilder(
        future: Provider.of<OrderList>(context, listen: false).loadOrders(),
        builder: ((ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Consumer<OrderList>(
              builder: (ctx, orders, child) => ListView.builder(
                itemCount: orders.itemsCount,
                itemBuilder: (ctx, i) => OrderWidget(order: orders.items[i]),
              ),
            );
          }
        }),
      ),
      drawer: const AppDrawer(),
    );
  }
}
