import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var temparature = null;
  String location = "İstanbul";
  int woeid = 2344116;
  String weather = "clear";

  String searchApiPath = "/api/location/search/?query=";
  String locationApiPath = "/api/location/";
  String iconApiPath = "/static/img/weather/png/";
  String abrv = "c";
  String errorMessage = "";
  String host = "https://www.metaweather.com";
  String iconUrl = "https://www.metaweather.com/static/img/weather/png/c.png";

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  void onTextSubmitted(String input) async {
    await fetchSearch(input);
    await fetchLocation();
  }

  Future<void> fetchSearch(String input) async {
    try {
      var searchResult =
          await http.get(Uri.parse(host + searchApiPath + input));
      var result = json.decode(searchResult.body)[0];
      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = "";
      });
    } catch (error) {
      setState(() {
        errorMessage = "Sorry, We don't have this city";
      });
    }
  }

  Future<void> fetchLocation() async {
    var locationResult =
        await http.get(Uri.parse(host + locationApiPath + woeid.toString()));
    var result = json.decode(locationResult.body);
    var data = result["consolidated_weather"][0];

    setState(() {
      temparature = data["the_temp"]?.round();
      weather = data["weather_state_name"]?.replaceAll(" ", "").toLowerCase();
      abrv = data["weather_state_abbr"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/$weather.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: temparature == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Image.network(
                            host + iconApiPath + abrv + ".png",
                            width: 100,
                          ),
                        ),
                        Center(
                          child: Text(
                            temparature.toString() + "C",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            location.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: 300,
                      child: TextField(
                        onSubmitted: (String input) {
                          onTextSubmitted(input);
                        },
                        style: TextStyle(color: Colors.white, fontSize: 25),
                        decoration: InputDecoration(
                            hintText: "Search Another Location",
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 20),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.white)),
                      ),
                    ),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
