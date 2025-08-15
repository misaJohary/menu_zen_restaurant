import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/datasources/models/token.dart';
import '../../features/datasources/models/user_restaurant_model.dart';

abstract class DbService {
  Future saveUserRestaurant(UserRestaurantModel userRestaurant);
  Future<UserRestaurantModel?> getUserRestaurant();
  Future<int?> getRestaurantId();
  Future saveToken(Token token);
  Future<Token?> getToken();
  Future<bool> checkAuth();
  Future<bool> deleteAll();
}

@Singleton(as: DbService)
class DbServiceImp implements DbService {
  final SharedPreferencesAsync prefs;

  DbServiceImp({required this.prefs});

  @override
  Future saveUserRestaurant(UserRestaurantModel userRestaurant) async {
    await prefs.setString('userRestaurant', json.encode(userRestaurant.toJson()));
  }

  @override
  Future<UserRestaurantModel?> getUserRestaurant() async {
    final userResString = await prefs.getString('userRestaurant');
    if (userResString != null) {
      return UserRestaurantModel.fromJson(json.decode(userResString));
    }
    return null;
  }

  @override
  Future<Token?> getToken() async {
    final tokenString = await prefs.getString('token');
    if (tokenString != null) {
      return Token.fromJson(json.decode(tokenString));
    }
    return null; // Return a default Token or handle as needed
  }

  @override
  Future saveToken(Token token) async{
    await prefs.setString('token', json.encode(token.toJson()));
  }

  @override
  Future<bool> checkAuth() async {
    final json = await prefs.getString('token');
    return json != null;
  }

  @override
  Future<int?> getRestaurantId() async {
    final userRest = await getUserRestaurant();
    return userRest?.restaurant.id;
  }

  @override
  Future<bool> deleteAll() async {
    await prefs.remove('token');
    await prefs.remove('userRestaurant');
    return true;
  }
}