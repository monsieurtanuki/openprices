import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openprices/model/dao_secured_string.dart';
import 'package:openprices/model/openpricesapiclient2.dart';
import 'package:openprices/model/osm_node.dart';
import 'package:openprices/ui/common.dart';
import 'package:openprices/ui/user_page.dart';

class AddPriceValuePage extends StatefulWidget {
  const AddPriceValuePage({
    required this.place,
    required this.day,
    super.key,
  });

  final OsmNode place;
  final DateTime day;

  @override
  State<AddPriceValuePage> createState() => _AddPriceValuePageState();
}

class _AddPriceValuePageState extends State<AddPriceValuePage> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  static const Currency _currency = Currency.EUR;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add prices!'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ScaffoldMessengerState state = ScaffoldMessenger.of(context);
          try {
            state.showSnackBar(
              const SnackBar(content: Text('Adding this price...')),
            );
            final String token =
                (await DaoSecuredString.get(daoSecuredStringTagToken))!;
            final String barcode = _barcodeController.text;
            final double price =
                double.parse(_valueController.text.replaceAll(',', '.'));
            final dynamic result = await OpenPricesAPIClient2.addPrice(
              productCode: barcode,
              price: price,
              currency: _currency,
              locationOSMId: widget.place.id,
              locationOSMType: widget.place.type,
              date: widget.day,
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
            const ListTile(title: Text('Step 3: add one single price')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                controller: _barcodeController,
                decoration: getDecoration(
                  hintText: 'Barcode',
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () =>
                        setState(() => _barcodeController.text = ''),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                controller: _valueController,
                decoration: getDecoration(
                  hintText: 'Price',
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _valueController.text = ''),
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(
                    'Currency: ${_currency.name} (not editable for the moment)'),
              ),
            ),
            Card(
              child: ListTile(
                title:
                    Text('Date: ${formatDate(widget.day)} (not editable here)'),
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              child: Card(
                child: Text(widget.place.getTagsAsLines().join('\n')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
