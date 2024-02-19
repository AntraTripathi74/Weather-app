import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/weather_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true)
          .copyWith(appBarTheme: const AppBarTheme()),
      home: FutureBuilder(
        future: _initialization,
        builder: (contex, snapshot) {
          if (snapshot.hasError) {
            print('Error');
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return const WeatherScreen();
          }
          return const CircularProgressIndicator.adaptive();
        },
      ),
    );
  }
}
