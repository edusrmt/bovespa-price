import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MaterialApp(title: "Bovespa", home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

Future<Map> getStockData(String text) async {
  http.Response response = await http.get(
      "https://api.hgbrasil.com/finance/stock_price?key=6def0ffc&symbol=${Uri.encodeFull(text)}");

  return json.decode(response.body);
}

class _HomeState extends State<Home> {
  String search = "";

  String symbol = "";
  String company = "";
  double price = 0;
  double change = 0;

  void searchChange(String text) {
    setState(() {
      search = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.teal[600],
            leading: Icon(Icons.attach_money),
            titleSpacing: 0,
            title: Text(
              'Bovespa',
            )),
        body: Container(
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Container(
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    onChanged: searchChange,
                    style: TextStyle(color: Colors.grey[500]),
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        hintText: "Buscar símbolo de ação",
                        prefixIcon: Icon(Icons.search, color: Colors.teal[600]),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 0, style: BorderStyle.none),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16)))),
                  ),
                ),
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5))
                ]),
              ),
            ),
            FutureBuilder<Map>(
              future: getStockData(search),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Center(
                            child: Text(
                          "Carregando dados...",
                          style:
                              TextStyle(color: Colors.teal[600], fontSize: 20),
                          textAlign: TextAlign.center,
                        )));
                  default:
                    if (snapshot.hasError) {
                      return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Center(
                              child: Text(
                            "Erro ao carregar dados...",
                            style: TextStyle(color: Colors.red, fontSize: 20),
                            textAlign: TextAlign.center,
                          )));
                    }

                    String firstKey = snapshot.data["results"].keys.first;

                    if (snapshot.data["results"][firstKey] != true &&
                        snapshot.data["results"][firstKey].keys.first ==
                            "symbol") {
                      symbol = snapshot.data["results"][firstKey]["symbol"];
                      company = snapshot.data["results"][firstKey]["name"];
                      price = snapshot.data["results"][firstKey]["price"];
                      change =
                          snapshot.data["results"][firstKey]["change_percent"];

                      return Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(symbol,
                                      style: TextStyle(
                                          color: Colors.blueGrey[700],
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500)),
                                  Text(company,
                                      style: TextStyle(
                                          color: Colors.blueGrey[500],
                                          fontSize: 20))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text("R\$${price.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: Colors.blueGrey[700],
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500)),
                                  Container(
                                    width: 75,
                                    height: 25,
                                    child: Text(
                                      "${change.toStringAsFixed(2)}%",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: change < 0
                                            ? Colors.red
                                            : Colors.green),
                                  )
                                ],
                              )
                            ],
                          ));
                    }

                    return Container();
                }
              },
            )
          ]),
        ));
  }
}
