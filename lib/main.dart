import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Ghibli films search API'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final searchTextController = TextEditingController();
  List<GhibliSearchEntity> searchList = [];

  void _search() {
    String str = searchTextController.text;
    RequestService.query(str).then((WikiSearchResponse? response) {
      setState(() {
        searchList = response!.query.search;
      });
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                  child: TextField(
                    controller: searchTextController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'TextField',
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: 60,
                  child: OutlinedButton(
                    onPressed: _search,
                    child: Text("Search"),
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    primary: false,
                    itemBuilder: (BuildContext context, int index) => new WikiSearchItemWidget(searchList[index]),
                    itemCount: searchList.length,
                    shrinkWrap: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WikiSearchItemWidget extends StatelessWidget {
  final GhibliSearchEntity _entity;

  WikiSearchItemWidget(this._entity);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        _entity.title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: SingleChildScrollView(
        child: Html(data: _entity.description),
      ),
      onTap: () {},
    );
  }
}

//desde aqui abajo cambia el codigo
class RequestService {
  static Future<WikiSearchResponse?> query(String search) async {
    var response = await http.get(Uri.parse("https://ghibliapi.herokuapp.com/films"));
    // Check if response is success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var map = json.decode(response.body);
      return WikiSearchResponse.fromJson(map);
    } else {
      print("Query failed: ${response.body} (${response.statusCode})");
      return null;
    }
  }
}

class WikiSearchResponse {
  String batchComplete;
  WikiQueryResponse query;
  WikiSearchResponse({required this.batchComplete, required this.query});

  factory WikiSearchResponse.fromJson(Map<String, dynamic> json) => WikiSearchResponse(batchComplete: json["batchcomplete"], query: WikiQueryResponse.fromJson(json["query"]));
}

class WikiQueryResponse {
  List<GhibliSearchEntity> search;

  WikiQueryResponse({required this.search});

  factory WikiQueryResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> resultList = json['search'];
    List<GhibliSearchEntity> search = resultList.map((dynamic value) => GhibliSearchEntity.fromJson(value)).toList(growable: false);
    return WikiQueryResponse(search: search);
  }
}

class GhibliSearchEntity {
  dynamic id;
  String title;
  String original_title;
  String original_title_romanised;
  String image;
  String movie_banner;
  String description;
  String director;
  String producer;
  int release_date;
  int running_time;
  int rt_score;
  String people;
  String species;
  String locations;
  String vehicles;
  String url;

  GhibliSearchEntity({required this.id, required this.title, required this.original_title, required this.original_title_romanised, required this.image, required this.movie_banner, required this.description, required this.director, required this.producer, required this.release_date, required this.running_time, required this.rt_score, required this.people, required this.species, required this.locations, required this.vehicles, required this.url});

  factory GhibliSearchEntity.fromJson(Map<String, dynamic> json) => GhibliSearchEntity(id: json["ID"], title: json["Title"], original_title: json["Original Title"], original_title_romanised: json["Original Title Romanised"], image: json["Image"], movie_banner: json["Movie Banner"], description: json["Description"], director: json["Director"], producer: json["Producer"], release_date: json["Realease date"], running_time: json["Running Time"], rt_score: json["Rt Score"], people: json["People"], species: json["Species"], locations: json["Locations"], vehicles: json["Vehicles"], url: json["url"]);
}
