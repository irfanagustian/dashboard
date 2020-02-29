import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';

class Dashboard {
  final String id;
  final String acara, tempat, deskripsi, image, jadwal;

  Dashboard({
    this.id,
    this.acara,
    this.tempat,
    this.jadwal,
    this.deskripsi,
    this.image
  });

  factory Dashboard.fromJson(Map<String, dynamic> jsonData){
    return Dashboard(
      id: jsonData['id'],
      acara: jsonData['acara'],
      jadwal: jsonData['jadwal'],
      tempat: jsonData['tempat'],
      deskripsi: jsonData['deskripsi'],
      image: "https://or.neotelemetri.com/pict"+jsonData['image']
    );
  }
}

class CostumListView extends StatelessWidget {
  final List<Dashboard> dashboards;

  CostumListView(this.dashboards);

  Widget build (context){
    return ListView.builder(
      itemCount: dashboards.length,
      itemBuilder: (context, int currentIndex){
      return createViewItem(dashboards[currentIndex], context);
      },
    );
  }

  Widget createViewItem (Dashboard dashboard, BuildContext context){
    return new ListTile(
        title: new Card(
          elevation: 5.0,
          child: new Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.orange)),
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Row(children: <Widget>[
                  Padding(
                      child: Text(
                        dashboard.acara,
                        style: new TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      padding: EdgeInsets.all(1.0)),
                ]),
              ],
            ),
          ),
        ),
        onTap: () {
          var route = new MaterialPageRoute(
            builder: (BuildContext context) =>
            new SecondScreen(value: dashboard),
          );
          Navigator.of(context).push(route);
        }
    );
  }

}

Future<List<Dashboard>> downloadJSON() async {
  final jsonEndpoint =
      "https://or.neotelemetri.com/view/dashboard.php";

  final response = await get(jsonEndpoint);

  if (response.statusCode == 200) {
    List dashboards = json.decode(response.body);
    return dashboards
        .map((dashboard) => new Dashboard.fromJson(dashboard))
        .toList();
  } else
    throw Exception('We were not able to successfully download the json data.');
}

class SecondScreen extends StatefulWidget {
  final Dashboard value;

  SecondScreen({Key key, this.value}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Detail Page')),
      body: new Container(
        child: new Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: new Text(
                  'DETAILS ACARA',
                  style: new TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
                padding: EdgeInsets.only(bottom: 20.0),
              ),
              Padding(
                //`widget` is the current configuration. A State object's configuration
                //is the corresponding StatefulWidget instance.
                child: Image.network('${widget.value.image}'),
                padding: EdgeInsets.all(12.0),
              ),
              Padding(
                child: new Text(
                  'ACARA : ${widget.value.acara}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Padding(
                child: new Text(
                  'JADWAL : ${widget.value.jadwal}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Padding(
                child: new Text(
                  'TEMPAT : ${widget.value.tempat}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Padding(
                child: new Text(
                  'DESKRIPSI : ${widget.value.deskripsi}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              )
            ],   ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: new Scaffold(
        appBar: new AppBar(title: const Text('Dashboard')),
        body: new Center(
          //FutureBuilder is a widget that builds itself based on the latest snapshot
          // of interaction with a Future.
          child: new FutureBuilder<List<Dashboard>>(
            future: downloadJSON(),
            //we pass a BuildContext and an AsyncSnapshot object which is an
            //Immutable representation of the most recent interaction with
            //an asynchronous computation.
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Dashboard> dashboards = snapshot.data;
                return new CostumListView(dashboards);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              //return  a circular progress indicator.
              return new CircularProgressIndicator();
            },
          ),

        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
