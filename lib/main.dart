import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance";
void main() async {
  runApp(MaterialApp(
      home: const Home(),
      theme: ThemeData(
          hintColor: Colors.amber[200],
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.yellow.shade50)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber[200]),
          ))));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

late double dolar;
late double euro;

final realController = TextEditingController();
final dolarController = TextEditingController();
final euroController = TextEditingController();

void _realChanged(String text) {
  double value;
  if (text.isEmpty) {
    value = 0;
  } else {
    value = double.parse(text);
  }
  dolarController.text = (value / dolar).toStringAsFixed(2);
  euroController.text = (value / euro).toStringAsFixed(2);
}

void _dolarChanged(String text) {
  double value;
  if (text.isEmpty) {
    value = 0;
  } else {
    value = double.parse(text);
  }
  realController.text = (value * dolar).toStringAsFixed(2);
  euroController.text = (value * dolar / euro).toStringAsFixed(2);
}

void _euroChanged(String text) {
  double value;
  if (text.isEmpty) {
    value = 0;
  } else {
    value = double.parse(text);
  }
  realController.text = (value * euro).toStringAsFixed(2);
  dolarController.text = (value * euro / dolar).toStringAsFixed(2);
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: Text(
          "Conversor",
          style: TextStyle(color: Colors.amber[200]),
        ),
        backgroundColor: Colors.grey[850],
        centerTitle: false,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (contex, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Container(
                  color: Colors.grey[850],
                  child: Center(
                    child: Text(
                      "Caregando dados",
                      style:
                          TextStyle(color: Colors.amber[200], fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  ));
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text("Erro ao carregar os dados"),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return Scaffold(
                    backgroundColor: Colors.grey[850],
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "images/moedas.png",
                            scale: 4.0,
                          ),
                          const Divider(),
                          buildTextFild(
                              "Reais", "R\$", realController, _realChanged),
                          const Divider(),
                          buildTextFild(
                              "Dólares", "\$", dolarController, _dolarChanged),
                          const Divider(),
                          buildTextFild(
                              "Euros", "€", euroController, _euroChanged)
                        ],
                      ),
                    ));
              }
          }
        },
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

Widget buildTextFild(String label, String prefix,
    TextEditingController controller, Function(String) f) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber[200]),
        border: const OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber[200]),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
