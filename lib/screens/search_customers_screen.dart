import 'package:flutter/material.dart';
import 'package:woot/constants/firestore_collection.dart';
import 'package:woot/constants/geo_data.dart';
import 'package:woot/screens/customer_form_screen.dart';
import 'package:woot/widgets/form_widgets.dart';

import '../models/customer.dart';
import '../widgets/misc_widgets.dart';

class SearchCustomersScreen extends StatefulWidget {
  const SearchCustomersScreen({super.key});

  @override
  State<SearchCustomersScreen> createState() => _SearchCustomersScreenState();
}

class _SearchCustomersScreenState extends State<SearchCustomersScreen> {
  int? sortColumnIndex;
  bool sortAscending = true;

  final formKey = GlobalKey<FormState>();

  String? assuredType;
  String? namePrefix;
  late String firstname;
  late String surname;
  String? juristicName;
  String? province;
  String? district;
  String? subdistrict;
  late String zipcode;

  List<CustomerDocument> docs = [];

  static const headers = [
    'ประเภท',
    'ชื่อจริง',
    'นามสกุล',
    'จังหวัด',
    'อำเภอ',
    'ตำบล',
    'ไปรษณีย์',
  ];

  void search() {
    final ref = FirestoreCollection.customers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ข้อมูลลูกค้า')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Text(
                      'ตัวกรอง',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    DropdownInputField(
                      label: 'จังหวัด',
                      width: 200,
                      items: GeoData.changwats,
                      isSearchable: true,
                      onChanged: (value) {
                        print('change');
                      },
                    ),
                  ],
                ),
              ),
              spacing,
              const VerticalDivider(thickness: 1),
              spacing,
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  showCheckboxColumn: false,
                  sortColumnIndex: sortColumnIndex,
                  sortAscending: sortAscending,
                  horizontalMargin: 0,
                  columnSpacing: 10,
                  dataTextStyle: const TextStyle(fontSize: 14),
                  headingTextStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                  headingRowHeight: 32,
                  dataRowHeight: 28,
                  columns: headers
                      .map(
                        (e) => DataColumn(
                          label: Text(e),
                          onSort: (columnIndex, ascending) => setState(() {
                            sortColumnIndex = columnIndex;
                            sortAscending = ascending;
                          }),
                        ),
                      )
                      .toList(),
                  rows: docs
                      .map((doc) => DataRow(
                            onSelectChanged: (value) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CustomerFormScreen(editFrom: doc),
                                  ));
                            },
                            cells: doc.data.asTextRow
                                .map((e) => DataCell(Text(e)))
                                .toList(),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
