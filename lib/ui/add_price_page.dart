import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import '../local/dao_secured_string.dart';
import '../local/dao_string.dart';
import '../local/local_database.dart';
import '../model/dao_osm.dart';
import '../model/openpricesapiclient2.dart';
import '../model/osm_node.dart';
import '../ui/common.dart';
import '../ui/select_place_page.dart';
import '../ui/user_page.dart';

class AddPricePage extends StatefulWidget {
  const AddPricePage({
    required this.product,
    super.key,
  });

  final Product product;

  static const String daoStringTagDate = 'date';
  static const String daoStringTagPlace = 'place';

  @override
  State<AddPricePage> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPricePage> {
  final TextEditingController _controller = TextEditingController();

  static const Currency _currency = Currency.EUR;

  @override
  void initState() {
    super.initState();
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoString daoString = DaoString(localDatabase);
    final String? date = daoString.get(AddPricePage.daoStringTagDate);
    if (date == null) {
      daoString.put(AddPricePage.daoStringTagDate, formatDate(DateTime.now()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoString daoString = DaoString(localDatabase);
    final String date = daoString.get(AddPricePage.daoStringTagDate)!;
    final DateTime day = DateTime.parse(date);
    final String? osmKey = daoString.get(AddPricePage.daoStringTagPlace);
    OsmNode? place;
    if (osmKey != null) {
      final DaoOSM daoOSM = DaoOSM(localDatabase);
      final String? json = daoOSM.get(osmKey);
      if (json != null) {
        place = OsmNode.fromJson(key: osmKey, json: json);
      }
    }
    final String nickname = place == null ? '' : place.nickname;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add prices!'),
      ),
      floatingActionButton: place == null || _controller.text.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final ScaffoldMessengerState state =
                    ScaffoldMessenger.of(context);
                try {
                  state.showSnackBar(
                    const SnackBar(content: Text('Adding this price...')),
                  );
                  final String barcode = widget.product.barcode!;
                  final String token =
                      (await DaoSecuredString.get(daoSecuredStringTagToken))!;
                  final double price =
                      double.parse(_controller.text.replaceAll(',', '.'));
                  // TODO: 1 add receipt download
                  final dynamic result = await OpenPricesAPIClient2.addPrice(
                    productCode: barcode,
                    price: price,
                    currency: _currency,
                    locationOSMId: place!.id,
                    locationOSMType: place.type,
                    date: day,
                    bearerToken: token,
                  );
                  final String message;
                  final dynamic detail = result['detail'];
                  final dynamic created = result['created'];
                  if (detail != null) {
                    message = 'Error: $detail';
                  } else if (created != null) {
                    message = 'Created: $created';
                  } else {
                    message = "I don't know: $result";
                  }
                  state.showSnackBar(SnackBar(content: Text(message)));
                } catch (e) {
                  state.showSnackBar(
                    const SnackBar(
                      content: Text('Could not add this price :('),
                    ),
                  );
                }
              },
              label: const Text('Add this single price now!'),
              icon: const Icon(Icons.add),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(widget.product.barcode!),
              subtitle: Text(widget.product.productName ?? ''),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.edit_calendar),
                title: Text(formatDate(day)!),
                onTap: () async {
                  final DateTime? dateTime = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2023, 1, 1),
                    lastDate: DateTime(2073, 1, 1),
                    initialDate: day,
                  );
                  if (dateTime == null) {
                    return;
                  }
                  await daoString.put(
                      AddPricePage.daoStringTagDate, formatDate(dateTime));
                  setState(() {});
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      controller: _controller,
                      decoration: getDecoration(
                        hintText: 'Price',
                        prefixIcon: const Icon(Icons.monetization_on_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () async => _controller.text = '',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      height: 48, // TODO: 3 pure luck
                      child: ElevatedButton(
                        // TODO: 2 implement the choice of a currency
                        onPressed: null,
                        child: Text(_currency.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.map),
                title: place == null
                    ? const Text('Click here to select a location')
                    : Text(
                        nickname.isNotEmpty
                            ? nickname
                            : place.getTagsAsLines().join('\n'),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const SelectPlacePage(),
                    ),
                  );
                  setState(() {});
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
