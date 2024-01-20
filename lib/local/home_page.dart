import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openprices/local/dao_secured_string.dart';
import 'package:openprices/model/openpricesapiclient2.dart';
import 'package:openprices/model/proof_type.dart';
import '../ui/barcode_page.dart';
import '../ui/map_page.dart';
import 'show_price_page.dart';
import '../ui/user_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Open Prices Demo Home Page'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                onTap: () async => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const MapPage(),
                  ),
                ),
                leading: const Icon(Icons.map),
                title: const Text('Map'),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () async => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const UserPage(),
                  ),
                ),
                leading: const Icon(Icons.login),
                title: const Text('User'),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () async => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const BarcodePage(),
                  ),
                ),
                leading: const Icon(Icons.add),
                title: const Text('Add prices'),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () async => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const ShowPricePage(),
                  ),
                ),
                leading: const Icon(Icons.list),
                title: const Text('Show prices'),
              ),
            ),
            ListTile(
              title: Text('coucou'),
              onTap: () async => pickImageFile(context),
            ),
          ],
        ),
      );

  Future<void> pickImageFile(
    final BuildContext context, {
    bool ignorePlatformException = false,
  }) async {
    print('coucou0');
    final ImagePicker picker = ImagePicker();
    print('coucou1');
    final XFile? result = await picker.pickImage(source: ImageSource.gallery);
    print('coucou2');
    if (result == null) {
      return;
    }
    print('coucou3');
    print('uri; ${Uri.parse(result.path)}');
    print('coucou4');
    final String token =
        (await DaoSecuredString.get(daoSecuredStringTagToken))!;
    await OpenPricesAPIClient2.uploadProof(
      imageUri: Uri.parse(result.path),
      proofType: ProofType.receipt,
      isPublic: true,
      bearerToken: token,
    );
    /*
401
{"detail":"Not authenticated"}

201
{
  "id":1576,
  "file_path":"0002/Vl3AaqMmr5.bin",
  "mimetype":"application/octet-stream",
  "type":"RECEIPT",
  "owner":"monsieurtanuki",
  "created":"2024-01-20T09:38:26.510286Z",
  "is_public":true
}

201
{
  "id":1577,
  "file_path":"0002/qcTRhAQvqc.bin",
  "mimetype":"application/octet-stream",
  "type":"RECEIPT",
  "owner":"monsieurtanuki",
  "created":"2024-01-20T09:40:03.179587Z",
  "is_public":true
}     */
  }
}
