import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openprices/model/dao_secured_string.dart';
import 'package:openprices/model/openpricesapiclient2.dart';
import 'package:openprices/ui/common.dart';
import 'package:openprices/ui/user_page.dart';

class ShowPricePage extends StatefulWidget {
  const ShowPricePage({super.key});

  @override
  State<ShowPricePage> createState() => _ShowPricePageState();
}

class _ShowPricePageState extends State<ShowPricePage> {
  List<Price>? _prices;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Show prices'),
        ),
        body: _prices == null
            ? Card(
                child: ListTile(
                  onTap: () async => _loadPrices(),
                  leading: const Icon(Icons.download),
                  title: const Text('Download prices'),
                ),
              )
            : ListView.builder(
                itemCount: _prices!.length,
                itemBuilder: (
                  final BuildContext context,
                  final int index,
                ) {
                  final Price price = _prices![index];
                  final String date = formatDate(price.date) ?? 'no date';
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
      );

  Future<void> _loadPrices() async {
    const int pageSize = 50;
    final ScaffoldMessengerState state = ScaffoldMessenger.of(context);
    final String user =
        await DaoSecuredString.get(daoSecuredStringTagUser) ?? '';
    state.showSnackBar(
      SnackBar(
        content: Text(
          'Getting $pageSize prices ${user.isEmpty ? '' : ' from $user'}',
        ),
      ),
    );
    final GetPricesResults results = await OpenPricesAPIClient2.getPrices(
      pageSize: pageSize,
      pageNumber: 1,
      //productCode: '5010477348678', //'7300400481588',
      //locationOSMId: 27108404,
      //locationOSMType: LocationOSMType.way,
      //locationId: 35,
      //currency: Currency.EUR,
      //dateGte: DateTime.utc(2024, 1, 13),
      owner: user.isEmpty ? null : user,
    );
    if (results.result == null) {
      state.showSnackBar(
        SnackBar(
          content: Text('Error: ${results.error!.detail}'),
        ),
      );
      return;
    }
    _prices = results.result!.items;
    state.showSnackBar(
      SnackBar(
        content: Text('${_prices!.length} prices found!'),
      ),
    );
    setState(() {});
  }
}