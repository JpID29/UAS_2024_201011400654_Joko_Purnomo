import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.red, // Ganti dengan warna yang diinginkan
        primarySwatch: Colors.blue,
      ),
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' UAS Crypto Prices',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String apiUrl = 'https://api.coinlore.net/api/tickers/';
  List<dynamic> cryptoData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];
        setState(() {
          cryptoData = data ?? []; // menggunakan list kosong jika data null
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error fetching data from API
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch data. Please try again later.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Harga Crypto Dari coinlore.net'),
      ),
      body: cryptoData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cryptoData.length,
              itemBuilder: (context, index) {
                return CryptoCard(
                  name: cryptoData[index]['name'] ?? 'Unknown',
                  symbol: cryptoData[index]['symbol'] ?? 'Unknown',
                  priceUsd: cryptoData[index]['price_usd'] ?? '0.00',
                  imageUrl: cryptoData[index]['logo_url'] ?? '',
                );
              },
            ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  final String name;
  final String symbol;
  final String priceUsd;
  final String imageUrl;

  const CryptoCard({
    required this.name,
    required this.symbol,
    required this.priceUsd,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(name),
        subtitle: Text(symbol),
        trailing: Text('\$$priceUsd'),
      ),
    );
  }
}
