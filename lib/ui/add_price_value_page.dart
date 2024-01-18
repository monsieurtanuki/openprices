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

  Product? _product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add prices!'),
        actions: [
          IconButton(
            onPressed: () {
              _barcodeController.clear();
              _valueController.clear();
              _product = null;
            },
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ScaffoldMessengerState state = ScaffoldMessenger.of(context);
          try {
            state.showSnackBar(
              const SnackBar(content: Text('Adding this price...')),
            );
            await _setProduct();
            if (!mounted) {
              return;
            }
            final String barcode = _barcodeController.text;
            if (_product == null) {
              await showDialog(
                context: context,
                builder: (final BuildContext context) => AlertDialog(
                  title: const Text('Unknown barcode!'),
                  content: Text('Barcode $barcode is not in the OFF database'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
              return;
            }
            final String token =
                (await DaoSecuredString.get(daoSecuredStringTagToken))!;
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
            // TODO: 1 "next" button for keyboard
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
                onChanged: (_) => setState(() => _product = null),
                decoration: getDecoration(
                  hintText: 'Barcode',
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Check if product is in OFF',
                    onPressed: () async {
                      final ScaffoldMessengerState state =
                          ScaffoldMessenger.of(context);
                      state.showSnackBar(
                        const SnackBar(
                            content: Text('Looking for this product...')),
                      );
                      await _setProduct();
                    },
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
                ),
              ),
            ),
            if (_product == null)
              const ListTile(title: Text('Product not found yet'))
            else if (_product!.imageFrontSmallUrl != null)
              SizedBox(
                height: MediaQuery.of(context).size.width * .5,
                child:
                    Image(image: NetworkImage(_product!.imageFrontSmallUrl!)),
              )
            else
              const ListTile(
                  title: Text('Product found but without thumbnail')),
            Card(
              // TODO: 2 edit currency
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setProduct() async {
    final ProductResultV3 productResultV3 =
        await OpenFoodAPIClient.getProductV3(
      ProductQueryConfiguration(
        _barcodeController.text,
        version: ProductQueryVersion.v3,
      ),
    );
    _product = productResultV3.product;
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
