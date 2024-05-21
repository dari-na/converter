import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;


class CurrencyConverterPage extends StatefulWidget {
  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _amount = 0.0;
  double _result = 0.0;

  Future<void>? _futureConvertCurrency;
  final TextEditingController _amountController = TextEditingController();

  Future<void> _convertCurrency() async {
    const apiKey = 'fca_live_tL4anwHf7FLQF4OiQ2EPOawYI5rRUuHOCAXWdF8h';
    final url = 'https://api.freecurrencyapi.com/v1/latest?apikey=$apiKey&currencies=$_toCurrency&base_currency=$_fromCurrency';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rate = data['data'][_toCurrency];
      setState(() {
        _result = _amount * rate;
      });
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _amountField(),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _fromCurrency,
                    onChanged: (newValue) {
                      setState(() {
                        _fromCurrency = newValue!;
                      });
                    },
                    items: <String>['USD', 'EUR', 'BGN']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<String>(
                    value: _toCurrency,
                    onChanged: (newValue) {
                      setState(() {
                        _toCurrency = newValue!;
                      });
                    },
                    items: <String>['USD', 'EUR', 'BGN']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff668cff),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold)),
              onPressed: () {
                if (_amount > 0) {
                  setState(() {
                    _futureConvertCurrency = _convertCurrency();
                  });
                }
              },
              child: const Text('Convert', style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),),
            ),
            SizedBox(height: 20),
            FutureBuilder<void>(
              future: _futureConvertCurrency,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text(
                      'Result: $_result $_toCurrency',
                      style: TextStyle(fontSize: 20),
                    );
                  }
                } else {
                  return Text('Press the button to convert currency');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Container _amountField() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: const Color(0xff1D1617).withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 0.0
            )
          ]
      ),
      child: TextField(
        controller: _amountController,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(8),
            hintText: '0',
            hintStyle: const TextStyle(
                color: Color(0xffDDDADA),
                fontSize: 14
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.search),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none
            )
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            _amount = double.tryParse(value) ?? 0.0;
          });
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
        title: const Text('ConverTo',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff668cff),
        actions: [Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.access_time),
                color: Colors.white,
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            }
        )
        ]
    );
  }
}