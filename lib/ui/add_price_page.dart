import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openprices/model/maybe_error.dart';
import 'package:openprices/model/proof.dart';
import 'package:provider/provider.dart';
import '../local/dao_secured_string.dart';
import '../local/dao_string.dart';
import '../local/local_database.dart';
import '../model/dao_osm.dart';
import '../model/openpricesapiclient2.dart';
import '../model/osm_node.dart';
import '../model/proof_type.dart';
import '../ui/common.dart';
import '../ui/select_place_page.dart';
import '../local/user_page.dart';

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

  int? _proofId;

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: place == null || _controller.text.isEmpty || _proofId == null
            ? null
            : () async {
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
                  final MaybeError<Price> result =
                      await OpenPricesAPIClient2.addPrice(
                    productCode: barcode,
                    price: price,
                    currency: _currency,
                    locationOSMId: place!.id,
                    locationOSMType: place.type,
                    date: day,
                    proofId: _proofId,
                    bearerToken: token,
                  );
                  final String message;
                  if (result.isError) {
                    message = 'Could not add the price: ${result.error}';
                  } else {
                    message = 'Price created at ${result.value.created}';
                  }
                  state.showSnackBar(SnackBar(content: Text(message)));
                } catch (e) {
                  print('EEE: $e');
                  state.showSnackBar(
                    SnackBar(
                      content: Text('Could not add this price :( - $e'),
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
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.photo_camera_rounded),
                title: Text('Proof'),
                onTap: _proofId != null
                    ? null
                    : () async {
                        _proofId = await _getProofId();
                        setState(() {});
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _getProofId() async {
    print('coucou0');
    final ImagePicker picker = ImagePicker();
    print('coucou1');
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);
    print('coucou2');
    if (xFile == null) {
      return null;
    }
    print('coucou4');
    final String token =
        (await DaoSecuredString.get(daoSecuredStringTagToken))!;
    final MaybeError<Proof> result = await OpenPricesAPIClient2.uploadProof(
      imageUri: Uri.parse(xFile.path),
      proofType: ProofType.receipt,
      isPublic: true,
      bearerToken: token,
    );
    if (result.isError) {
      throw Exception('Could not upload proof: ${result.error}');
    }
    return result.value.id!;
  }
}
