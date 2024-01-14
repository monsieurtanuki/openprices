import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openprices/model/openpricesapiclient2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: "monsieurtanuki's open prices",
    );
  }

  List<Price>? _prices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              await OpenPricesAPIClient2.addPrice(
                productCode: '5010477348678',
                price: 3.99,
                currency: Currency.EUR,
                locationOSMId: 5324689769,
                locationOSMType: LocationOSMType.node,
                date: DateTime(2024, 1, 13),
              );
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              final String? token =
                  await OpenPricesAPIClient2.getAuthenticationToken(
                username: 'monsieurtanuki', // TODO 0000
                password: 'TODO', // TODO 0000
              );
              print('token :$token');
            },
            icon: const Icon(Icons.login),
          ),
        ],
      ),
      body: _prices == null
          ? Center(child: Text('nothing'))
          : ListView.builder(
              itemCount: _prices!.length,
              itemBuilder: (
                final BuildContext context,
                final int index,
              ) {
                final Price price = _prices![index];
                print('pro: ${price.toJson()}');
                final String date = price.date.toString().substring(0, 10);
                // location_osm_id: 84818012, location_osm_type: WAY
                return ListTile(
                  title: Text(price.productCode ?? 'no product code'),
                  subtitle: Text(
                    '${price.price}'
                    ' '
                    '${price.currency.toString().split('.')[1]}'
                    '\n'
                    '$date',
                  ),
                  isThreeLine: true,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final GetPricesResults results = await OpenPricesAPIClient2.getPrices(
            pageSize: 20,
            pageNumber: 1,
            //productCode: '5010477348678', //'7300400481588',
            //locationOSMId: 27108404,
            //locationOSMType: LocationOSMType.way,
            //locationId: 35,
            //currency: Currency.EUR,
            //dateGte: DateTime.utc(2024, 1, 13),
            //owner: 'Jbieber ',
          );
          if (results.result == null) {
            // TODO error
            return;
          }
          setState(() => _prices = results.result!.items);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
