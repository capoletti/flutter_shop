class Constants {
  static const baseUrl = '';

  static const token = '';

  static const productsBaseUrl = '$baseUrl/products';

  static const ordersBaseUrl = '$baseUrl/orders';

  static const userFavoritesBaseUrl = '$baseUrl/userFavorites';

  static const signUpBaseUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$token';

  static const signInBaseUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$token';
}
