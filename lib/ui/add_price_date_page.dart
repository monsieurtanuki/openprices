import 'package:flutter/material.dart';
import 'package:openprices/model/dao_string.dart';
import 'package:openprices/model/local_database.dart';
import 'package:openprices/model/osm_node.dart';
import 'package:openprices/ui/add_price_value_page.dart';
import 'package:openprices/ui/common.dart';
import 'package:provider/provider.dart';

class AddPriceDatePage extends StatefulWidget {
  const AddPriceDatePage({
    required this.place,
    super.key,
  });

  final OsmNode place;

  @override
  State<AddPriceDatePage> createState() => _AddPriceDatePageState();
}

class _AddPriceDatePageState extends State<AddPriceDatePage> {
  static const String _daoStringTagDate = 'date';

  @override
  void initState() {
    super.initState();
    final DaoString daoString = DaoString(context.read<LocalDatabase>());
    String? date = daoString.get(_daoStringTagDate);
    if (date == null) {
      date = formatDate(DateTime.now());
      daoString.put(_daoStringTagDate, date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DaoString daoString = DaoString(context.read<LocalDatabase>());
    String date = daoString.get(_daoStringTagDate)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add prices'),
      ),
      body: Column(
        children: [
          const ListTile(title: Text('Step 2: select the date')),
          Card(
            child: ListTile(
              leading: const Icon(Icons.edit_calendar),
              title: Text(date),
              onTap: () async {
                final DateTime? dateTime = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2023, 1, 1),
                  lastDate: DateTime(2073, 1, 1),
                  initialDate: DateTime.tryParse(date),
                );
                if (dateTime == null) {
                  return;
                }
                date = formatDate(dateTime)!;
                daoString.put(_daoStringTagDate, date);
                setState(() {});
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add prices!'),
              onTap: () async => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => AddPriceValuePage(
                    place: widget.place,
                    day: DateTime.parse(date),
                  ),
                ),
              ),
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
    );
  }
}
