// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/additional_information_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Kanpur';
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occured';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Kanpur',
            style: TextStyle(fontSize: 20),
          ),
          centerTitle: true,
          actions: [
            // InkWell(
            //     onTap: () {
            //       print('refresh');
            //     },
            //     child: const Icon(Icons.refresh)),

            IconButton(
                onPressed: () {
                  setState(() {
                    weather = getCurrentWeather();
                  });
                },
                icon: const Icon(Icons.refresh))
          ]),
      body: Center(
        child: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator.adaptive();
            }

            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            //weather variables

            final data = snapshot.data!;
            final currentWeatherData = data['list'][0];
            final currentTemp = currentWeatherData['main']['temp'];
            String ct = (currentTemp - 273.15).toStringAsFixed(2);
            final currentSky = currentWeatherData['weather'][0]['main'];
            final pressure = currentWeatherData['main']['pressure'];
            final speed = currentWeatherData['wind']['speed'];
            final humidity = currentWeatherData['main']['humidity'];

            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text('$ct °C',
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.normal)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Icon(
                                      currentSky == 'Clouds' ||
                                              currentSky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 60),
                                  const SizedBox(height: 10),
                                  Text(currentSky,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal))
                                ],
                              ),
                            ),
                          ),
                        )),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // weather forecast card- 12 hours
                  const Text('Hourly Weather Forecast',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal)),
                  const SizedBox(height: 10),

                  //forecast cards
                  ////list view builder for hourly forecast so that it will only create widget when we scroll so as not to affect the performance

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        final hourly = data['list'][index + 1];
                        final hourlySky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final hourlyTemp = hourly['main']['temp'];
                        String hourtemp =
                            (hourlyTemp - 273.15).toStringAsFixed(2);
                        final time = DateTime.parse(hourly['dt_txt']);

                        return HourlyForecastItem(
                            time: DateFormat('j').format(time),
                            icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                ? Icons.cloud
                                : Icons.sunny,
                            temperature: hourtemp);
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  //additional information
                  const Text('Additional Information',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal)),
                  const SizedBox(height: 10),

                  //information cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalnformationItem(
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: humidity.toString()),
                      AdditionalnformationItem(
                          icon: Icons.air,
                          label: 'Wind Speed',
                          value: speed.toString()),
                      AdditionalnformationItem(
                          icon: Icons.beach_access,
                          label: 'Pressure',
                          value: pressure.toString()),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
