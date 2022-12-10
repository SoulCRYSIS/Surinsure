import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:woot/constants/firestore_collection.dart';
import 'package:woot/constants/geo_data.dart';
import 'package:woot/screens/customer_form_screen.dart';
import 'package:woot/utils/ui_util.dart';
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

  String assuredType = '';
  String namePrefix = '';
  String firstname = '';
  String surname = '';
  String juristicName = '';
  String province = '';
  String district = '';
  String subdistrict = '';
  String zipcode = '';

  List<CustomerDocument> docs = [];

  Future<void> search() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    const lastChar = '\uf8ff';

    Query<Map<String, dynamic>> query = FirestoreCollection.customers;
    if (assuredType.isNotEmpty) {
      query = query.where('assuredType', isEqualTo: assuredType);
    }
    if (namePrefix.isNotEmpty) {
      query = query.where('namePrefix', isEqualTo: namePrefix);
    }
    if (firstname.isNotEmpty) {
      query = query
          .where('firstname', isGreaterThanOrEqualTo: firstname)
          .where('firstname', isLessThan: firstname + lastChar);
    }
    if (surname.isNotEmpty) {
      query = query
          .where('surname', isGreaterThanOrEqualTo: surname)
          .where('surname', isLessThan: surname + lastChar);
    }
    if (juristicName.isNotEmpty) {
      query = query
          .where('juristicName', isGreaterThanOrEqualTo: juristicName)
          .where('juristicName', isLessThan: juristicName + lastChar);
    }
    if (province.isNotEmpty) {
      query = query.where('province', isEqualTo: province);
    }
    if (district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }
    if (subdistrict.isNotEmpty) {
      query = query.where('subdistrict', isEqualTo: subdistrict);
    }
    if (zipcode.isNotEmpty) {
      query = query.where('zipcode', isEqualTo: zipcode);
    }
    try {
      await UiUtil.loadingScreen(context, timeoutSecond: 3, future: () async {
        docs = (await query.get())
            .docs
            .map((e) => CustomerDocument.fromDoc(e))
            .toList();
      }());
    } catch (e) {
      UiUtil.snackbar(context, e.toString());
    }
    setState(() {});
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
                    spacingVertical,
                    DropdownInputField(
                      value: province,
                      width: 200,
                      label: 'จังหวัด',
                      isSearchable: true,
                      items: GeoData.changwats,
                      onEditingComplete: (value) {
                        if (province != value) {
                          setState(() {
                            district = '';
                            subdistrict = '';
                            province = value!;
                          });
                        }
                      },
                      validator: (value) {
                        if (subdistrict.isEmpty) {
                          return null;
                        }
                        if (!GeoData.changwats.contains(province)) {
                          return 'ไม่พบชื่อนี้';
                        }
                        return null;
                      },
                    ),
                    spacingVertical,
                    DropdownInputField(
                      value: district,
                      width: 200,
                      label: 'เขต/อำเภอ',
                      isSearchable: true,
                      items: GeoData.amphoes[province] ?? [],
                      onEditingComplete: (value) {
                        if (district != value) {
                          setState(() {
                            subdistrict = '';
                            district = value!;
                          });
                        }
                      },
                      validator: (value) {
                        if (district.isEmpty ||
                            GeoData.amphoes[province] == null) {
                          return null;
                        }
                        if (!GeoData.amphoes[province]!.contains(district)) {
                          return 'ไม่พบชื่อนี้';
                        }
                        return null;
                      },
                    ),
                    spacingVertical,
                    DropdownInputField(
                      value: subdistrict,
                      width: 200,
                      label: 'แขวง/ตำบล',
                      isSearchable: true,
                      items: GeoData.tambons[province]?[district] ?? [],
                      onEditingComplete: (value) => setState(() {
                        subdistrict = value!;
                      }),
                      validator: (value) {
                        if (subdistrict.isEmpty ||
                            GeoData.tambons[province]?[district] == null) {
                          return null;
                        }
                        if (!GeoData.tambons[province]![district]!
                            .contains(subdistrict)) {
                          return 'ไม่พบชื่อนี้';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: search,
                      child: Text('ค้นหา'),
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
                  columns: Customer.headers
                      .map(
                        (e) => DataColumn(
                          label: Text(e),
                          onSort: (columnIndex, ascending) => setState(() {
                            sortColumnIndex = columnIndex;
                            sortAscending = ascending;
                            docs.sort(
                              (a, b) =>
                                  (ascending ? 1 : -1) *
                                  a.data.asTextRow[columnIndex]
                                      .compareTo(b.data.asTextRow[columnIndex]),
                            );
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
