import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';


class Dashboard {
  
  final int id;
  final String nama_acara, tempat, deskripsi, image, jadwal;

  Dashboard({
    this.id,
    this.nama_acara,
    this.tempat,
    this.jadwal,
    this.deskripsi,
    this.image
  });

  factory Dashboard.fromJson(Map<String, dynamic> jsonData){
    return Dashboard(
      id: jsonData['id'],
      nama_acara: jsonData['nama_acara'],
      jadwal: jsonData['jadwal'],
      tempat: jsonData['tempat'],
      deskripsi: jsonData['deskripsi'],
      image: "http://10.10851.133/PHP/ipann"+jsonData['image']
    );
  }

}

class CostumListView extends StatelessWidget {
  final List<Dashboard> dashboard;

  CostumListView(this.dashboard);

  Widget build (context){
    return ListView.builder(
      itemCount: dashboard.length,
      itemBuilder: (context, int currentIndex){
      return createViewItem(dashboard[currentIndex], context);
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
                Padding(
                  child: Image.network(dashboard.image),
                  padding: EdgeInsets.only(bottom: 8.0),
                ),
                Row(children: <Widget>[
                  Padding(
                      child: Text(
                        dashboard.nama_acara,
                        style: new TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                      padding: EdgeInsets.all(1.0)),
                  Text(" | "),
                  Padding(
                      child: Text(
                        dashboard.tempat,
                        style: new TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.right,
                      ),
                      padding: EdgeInsets.all(1.0)),
                  Text(" | "),
                  Padding(
                      child: Text(
                        dashboard.jadwal,
                        style: new TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.right,
                      ),
                      padding: EdgeInsets.all(1.0)),
                  Text(" | "),
                  Padding(
                      child: Text(
                        dashboard.deskripsi,
                        style: new TextStyle(fontStyle: FontStyle.italic),
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
                  'SPACECRAFT DETAILS',
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
                  'NAME : ${widget.value.nama_acara}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Padding(
                child: new Text(
                  'NAME : ${widget.value.jadwal}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Padding(
                child: new Text(
                  'PROPELLANT : ${widget.value.tempat}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Padding(
                child: new Text(
                  'NAME : ${widget.value.deskripsi}',
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
        appBar: new AppBar(title: const Text('MySQL Images Text')),
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
                List<Dashboard> dashboard = snapshot.data;
                return new CostumListView(dashboard);
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

Future<List<Dashboard>> downloadJSON() async {
  final jsonEndpoint =
      "http://10.10851.133/PHP/ipann";

  final response = await get(jsonEndpoint);

  if (response.statusCode == 200) {
    List dashboard = json.decode(response.body);
    return dashboard
        .map((dashboard) => new Dashboard.fromJson(dashboard))
        .toList();
  } else
    throw Exception('We were not able to successfully download the json data.');
}

void main() {
  runApp(MyApp());
}
