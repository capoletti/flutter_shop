import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/order_widget.dart';
import 'package:shop/models/order_list.dart';

import '../components/app_drawer.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrderList orders = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
      ),
      body: ListView.builder(
          itemCount: orders.itemsCount,
          itemBuilder: (ctx, i) => OrderWidget(order: orders.items[i])),
      drawer: const AppDrawer(),
    );
  }
}
