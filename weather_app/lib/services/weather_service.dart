import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  Future<String> getLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Future.error("error");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Future.error("konum izni");
      }
    }
    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    final String? city = placemark[0].administrativeArea;
    if (city == null) Future.error("bir sorun ");
    return city!;
  }

  Future<List<WeatherModel>> getWeatherData() async {
    final String city = await getLocation();

    final String url =
        "https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=$city";

    const Map<String, dynamic> headers = {
      "authorization": "apikey 0EwetK24kkB2rL9EScADW8:6kqiRsiTNjqklnscACr6J8",
      "content-type": "aplication/json"
    };

    final dio = Dio();
    final response = await dio.get(url, options: Options(headers: headers));
    if (response.statusCode != 200) {
      return Future.error("bir sorun acr");
    }
    final List list = response.data["result"];
    final List<WeatherModel> weatherList =
        list.map((e) => WeatherModel.fromJson(e)).toList();
    return weatherList;
  }
}
