import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../util/utils.dart' as util;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => new _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {

  String _cityEntered;

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context).push(
      new MaterialPageRoute<Map>(builder: (BuildContext context) {
        return new ChangeCity();
      })
    );
    if (results != null && results.containsKey('enter')) {
      _cityEntered = results['enter'].text;
//      print(results['enter'].text);
        print(_cityEntered);
    }
  }

  void showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Klimatic'),
        centerTitle: true,
        backgroundColor: Colors.black54,
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.menu),
              onPressed: () { _goToNextScreen(context); })
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset('images/rain.jpg',
            width: 490.0,
            height: 1200.0,
            fit: BoxFit.fill,),
          ),
          new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: new Text('${_cityEntered == null ? util.defaultCity : _cityEntered}',
            style: cityStyle(),),
          ),
          new Container(
            alignment: Alignment.center,
            child: new Image.asset('images/light_rain.png'),
            margin: const EdgeInsets.fromLTRB(220.0, 0.0, 0.0, 330.0)
          ),
          new Container(
            margin: const EdgeInsets.fromLTRB(30.0, 300.0, 30.0, .0),
            alignment: Alignment.center,
            child: updateTempWidget(_cityEntered),
          )
        ],
      ),
    );
  }
}

Future<Map> getWeather(String appId, String city) async {
  String apiUrl = 'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=${util.appId}&units=metric';

  http.Response response = await http.get(apiUrl);

  return json.decode(response.body);
}

Widget updateTempWidget(String city) {
  return new FutureBuilder(
    future: getWeather(util.appId, city == null ? util.defaultCity : city),
    builder: (BuildContext context, AsyncSnapshot<Map> snapshot){
    //Lugar onde pegamos toda a informação e  setamos no widgets
      if (snapshot.hasData) {
        Map content = snapshot.data;
        return new Container(
          child: new Column(
            children: <Widget>[
              new ListTile(
                title: new Text('${content['main']['temp'].toString()}°',
                style: tempStyle(),),
                subtitle: new ListTile(
                  title: new Text(
                    'Umidade: ${content['main']['humidity'].toString()}%\n'
                        'Min: ${content['main']['temp_min'].toString()}°\n'
                        'Max: ${content['main']['temp_max'].toString()}°',
                    style: extraData()
                  ),
                ),
              )
            ],
          )
        );
      } else {
        return new Container();
      }
    }
    ,);
}

class ChangeCity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _cityFieldController = new TextEditingController();
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.black54,
        title: new Text('Configurações'),
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset('images/snow.jpg',
                width: 490.0,
                height: 1200.0,
                fit: BoxFit.fill),
          ),
          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  decoration: new InputDecoration(
                    hintText: 'Selecione a cidade',
                    fillColor: Colors.white
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                )
              ),
              new ListTile(
                title: new FlatButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'enter': _cityFieldController
                      });
                    },
                    color: Colors.redAccent,
                    textColor: Colors.white,
                    child: new Text('Veja o Clima')),
              )
            ],
          )
        ],
      ),
    );
  }
}


TextStyle cityStyle () {
  return new TextStyle(
    color: Colors.white,
    fontSize: 22.9,
    fontStyle: FontStyle.italic
  );
}

TextStyle extraData () {
  return new TextStyle(
      color: Colors.white70,
      fontStyle: FontStyle.normal,
      fontSize: 17.9
  );
}

TextStyle tempStyle() {
  return new TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontSize: 49.9
  );
}

