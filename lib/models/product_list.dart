import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';

import '../utils/constants.dart';

class ProductList with ChangeNotifier {
  final String _token;
  final String _userId;
  final List<Product> _items;
  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((element) => element.isFavorite).toList();

  ProductList([this._token = '', this._userId = '', this._items = const []]);

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('${Constants.productsBaseUrl}.json?auth=$_token'),
      body: jsonEncode(
        {
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];

    final addedProduct = Product(
      id: id,
      name: product.name,
      price: product.price,
      description: product.description,
      imageUrl: product.imageUrl,
    );

    _items.add(addedProduct);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.lastIndexWhere((p) => p.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse(
            '${Constants.productsBaseUrl}/${product.id}.json?auth=$_token'),
        body: jsonEncode(
          {
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
          },
        ),
      );

      _items[index] = product;
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.lastIndexWhere((p) => p.id == product.id);

    if (index >= 0) {
      final product = _items[index];
      _items.removeAt(index);
      notifyListeners();

      final response = await http.delete(Uri.parse(
          '${Constants.productsBaseUrl}/${product.id}.json?auth=$_token'));

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();

        throw HttpException(
          message: 'N??o foi poss??vel excluir o produto!',
          statusCode: response.statusCode,
        );
      }
    }
  }

  Future<void> loadProducts() async {
    _items.clear();

    final response = await http
        .get(Uri.parse('${Constants.productsBaseUrl}.json?auth=$_token'));
    if (response.body == 'null') return;

    final favResponse = await http.get(
      Uri.parse('${Constants.userFavoritesBaseUrl}/$_userId.json?auth=$_token'),
    );

    Map<String, dynamic> favData =
        (favResponse.body == 'null') ? {} : jsonDecode(favResponse.body);

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      final isFavorite = favData[productId] ?? false;
      _items.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: isFavorite,
        ),
      );
    });
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }
}
