import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Variables
  Map<String, dynamic>? currentWeather;
  List<dynamic>? dailyForecast;
  bool _hasConnectionError = false;
  String? cityName = "Depok";
  String? apiKey = "ae8eb81d49ba610bc5513c3deb10edfb"; // Your OpenWeatherMap API key

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  // Fetch weather data (current + 3-day forecast)
  void fetchWeatherData() async {
    final urlCurrent = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName,ind&appid=$apiKey&units=metric');
    final urlForecast = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,ind&appid=$apiKey&units=metric');

    try {
      final responseCurrent = await http.get(urlCurrent);
      final responseForecast = await http.get(urlForecast);

      if (responseCurrent.statusCode == 200 &&
          responseForecast.statusCode == 200) {
        setState(() {
          _hasConnectionError = false;
          currentWeather = jsonDecode(responseCurrent.body);
          dailyForecast = jsonDecode(responseForecast.body)['list']
              .where((item) =>
          DateTime
              .parse(item['dt_txt'])
              .hour == 12) // Noon data for each day
              .toList()
              .sublist(0, 3); // Get the next 3 days
        });
      } else {
        setState(() {
          _hasConnectionError = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasConnectionError = true;
      });
    }
  }

  // Method to get the appropriate image based on the weather condition
  Widget getWeatherImage(String description, {required double height}) {
    if (description.contains("rain")) {
      return Image.asset('assets/foto/cloudrain2.png', height: height);
    } else if (description.contains("clear")) {
      return Image.asset('assets/foto/cloud2.png', height: height,
          alignment: Alignment.centerLeft);
    } else if (description.contains("cloud")) {
      return Image.asset('assets/foto/cloud2.png', height: height,
          alignment: Alignment.centerLeft);
    } else {
      return Image.asset(
          'assets/foto/cloud2.png', height: height); // Default image
    }
  }

  Widget gradientText(String text, double fontSize, FontWeight fontWeight) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          const LinearGradient(
            colors: [Color(0xFF0077B6), Color(0xFF023E8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  Widget gradientText2(String text, double fontSize, FontWeight fontWeight) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFF90E0EF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _hasConnectionError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 60.0, color: Colors.red),
            const SizedBox(height: 20.0),
            Text(
              "Failed to fetch weather data.",
              style: GoogleFonts.openSans(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                fetchWeatherData();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : currentWeather == null || dailyForecast == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFCAF0F8),
              const Color(0xFF0077B6).withOpacity(0.9),
              const Color(0xFF023E8A),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60.0),
            gradientText("Weather in $cityName", 24, FontWeight.bold),
            const SizedBox(height: 20.0),
            // Display weather image based on condition with larger size
            getWeatherImage(
                currentWeather!['weather'][0]['description'], height: 150),
            const SizedBox(height: 2.0),
            Text(
              "${currentWeather!['main']['temp']}°C",
              style: GoogleFonts.openSans(
                fontSize: 75.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "${currentWeather!['weather'][0]['description']}",
              style: GoogleFonts.openSans(
                fontSize: 20.0,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50.0),
            gradientText2("3-Day Forecast", 22, FontWeight.bold),
            Expanded(
              child: ListView.builder(
                itemCount: dailyForecast!.length,
                itemBuilder: (context, index) {
                  var forecast = dailyForecast![index];
                  var date = DateFormat('EEEE').format(
                      DateTime.parse(forecast['dt_txt']));
                  return Card(
                    color: Colors.transparent,
                    child: ListTile(
                      title: Text(
                        date,
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Display forecast image with smaller size
                          getWeatherImage(forecast['weather'][0]['description'],
                              height: 100),
                          Text(
                            "${forecast['main']['temp']}°C - ${forecast['weather'][0]['description']}",
                            style: GoogleFonts.openSans(
                              color: Colors.white70,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
