import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../ui/add_price_page.dart';
import '../ui/common.dart';

class BarcodePage extends StatefulWidget {
  const BarcodePage({super.key});

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  final TextEditingController _controller = TextEditingController();
  Product? _product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add prices'),
        actions: [
          IconButton(
            onPressed: () {
              _controller.clear();
              _product = null;
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      floatingActionButton: _product == null
          ? null
          : FloatingActionButton(
              onPressed: () async => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => AddPricePage(
                    product: _product!,
                  ),
                ),
              ),
              child: const Icon(Icons.arrow_forward),
            ),
      body: Column(
        children: [
          const ListTile(title: Text('Step 1: select the barcode')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
              controller: _controller,
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
          if (_product == null)
            const ListTile(title: Text('Product not found yet'))
          else if (_product!.imageFrontSmallUrl != null)
            SizedBox(
              height: MediaQuery.of(context).size.width * .5,
              child: Image(image: NetworkImage(_product!.imageFrontSmallUrl!)),
            )
          else
            const ListTile(title: Text('Product found but without thumbnail')),
        ],
      ),
    );
  }

  Future<void> _setProduct() async {
    final ProductResultV3 productResultV3 =
        await OpenFoodAPIClient.getProductV3(
      ProductQueryConfiguration(
        _controller.text,
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
