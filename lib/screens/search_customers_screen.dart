import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:woot/constants/constant.dart';
import 'package:woot/constants/firestore_collection.dart';
import 'package:woot/constants/geo_data.dart';
import 'package:woot/screens/customer_form_screen.dart';
import 'package:woot/utils/server_data.dart';
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
  String identificationNumber = '';
  String group = '';

  List<CustomerDocument>? docs;

  void resetFields() {
    assuredType = '';
    namePrefix = '';
    firstname = '';
    surname = '';
    juristicName = '';
    province = '';
    district = '';
    subdistrict = '';
    zipcode = '';
    identificationNumber = '';
  }

  Future<void> search() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    Query<Map<String, dynamic>> query = FirestoreCollection.customers;
    if (assuredType.isNotEmpty) {
      query = query.where('assuredType', isEqualTo: assuredType);
    }
    if (namePrefix.isNotEmpty) {
      query = query.where('namePrefix', isEqualTo: namePrefix);
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
    if (identificationNumber.isNotEmpty) {
      query =
          query.where('identificationNumber', isEqualTo: identificationNumber);
    }
    try {
      await UiUtil.loadingScreen(context, timeoutSecond: 3, future: () async {
        docs = (await query.get())
            .docs
            .map((e) => CustomerDocument.fromDoc(e))
            .toList();
      }());
      if (firstname.isNotEmpty) {
        docs = docs!
            .where((element) => element.data.firstname.contains(firstname))
            .toList();
      }
      if (surname.isNotEmpty) {
        docs = docs!
            .where((element) => element.data.surname.contains(surname))
            .toList();
      }
      if (juristicName.isNotEmpty && assuredType == 'นิติบุคคล') {
        docs = docs!
            .where(
                (element) => element.data.juristicName!.contains(juristicName))
            .toList();
      }
    } catch (e) {
      debugPrint(e.toString());
      UiUtil.snackbar(context, e.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลลูกค้า'),
        actions: const [HomeButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                    width: 200,
                    items: Constant.assuredTypes,
                    label: 'ประเภท',
                    onEditingComplete: (value) => setState(() {
                      assuredType = value!;
                    }),
                  ),
                  spacingVertical,
                  TextInputField(
                    width: 200,
                    label: 'บัตรประชาชน',
                    onlyDigit: true,
                    onChanged: (value) {
                      firstname = value!;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return null;
                      }
                      if (value.length != 13) {
                        return 'ความยาวไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  spacingVertical,
                  DropdownSearchableInputField(
                    items: ServerData.customerGroups,
                    width: 200,
                    label: 'กลุ่ม',
                    onEditingComplete: (value) => group = value!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return null;
                      }
                      if (!ServerData.customerGroups.contains(value)) {
                        return 'ไม่พบกลุ่มนี้';
                      }
                      return null;
                    },
                  ),
                  spacingVertical,
                  TextInputField(
                    width: 200,
                    label: 'ชื่อจริง',
                    onChanged: (value) {
                      firstname = value!;
                    },
                  ),
                  spacingVertical,
                  TextInputField(
                    width: 200,
                    label: 'นามสกุล',
                    onChanged: (value) => surname = value!,
                  ),
                  spacingVertical,
                  DropdownSearchableInputField(
                    value: province,
                    width: 200,
                    label: 'จังหวัด',
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
                  DropdownSearchableInputField(
                    value: district,
                    width: 200,
                    label: 'เขต/อำเภอ',
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
                  DropdownSearchableInputField(
                    value: subdistrict,
                    width: 200,
                    label: 'แขวง/ตำบล',
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
                  spacingVertical,
                  TextInputField(
                    width: 200,
                    label: 'รหัสไปรษณีย์',
                    onlyDigit: true,
                    onChanged: (value) => zipcode = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      if (value.length != 5) {
                        return 'ความยาวไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  if (assuredType == 'นิติบุคคล') ...[
                    spacingVertical,
                    TextInputField(
                      width: 200,
                      label: 'ชื่อนิติบุคคล',
                      onChanged: (value) => juristicName = value!,
                    ),
                  ],
                  spacingVertical,
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: ElevatedButton(
                          onPressed: () {
                            formKey.currentState!.reset();
                            resetFields();
                            setState(() {});
                          },
                          child: const Text('ล้าง'),
                        ),
                      ),
                      spacing,
                      SizedBox(
                        width: 80,
                        child: ElevatedButton(
                          onPressed: search,
                          child: const Text('ค้นหา'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            spacing,
            const VerticalDivider(thickness: 1),
            spacing,
            Expanded(
              child: docs == null
                  ? Container()
                  : docs!.isEmpty
                      ? const Center(
                          child: Text(
                            'ไม่พบผลการค้นหา',
                            style: TextStyle(fontSize: 24, color: Colors.grey),
                          ),
                        )
                      : BidirectionScroll(
                          child: DataTable(
                            showCheckboxColumn: false,
                            sortColumnIndex: sortColumnIndex,
                            sortAscending: sortAscending,
                            columnSpacing: 10,
                            columns: Customer.headers
                                .map(
                                  (e) => DataColumn(
                                    label: Text(e),
                                    onSort: (columnIndex, ascending) =>
                                        setState(() {
                                      sortColumnIndex = columnIndex;
                                      sortAscending = ascending;
                                      docs!.sort(
                                        (a, b) =>
                                            (ascending ? 1 : -1) *
                                            a.data.asTextRow[columnIndex]
                                                .compareTo(b.data
                                                    .asTextRow[columnIndex]),
                                      );
                                    }),
                                  ),
                                )
                                .toList(),
                            rows: docs!
                                .map((doc) => DataRow(
                                      onSelectChanged: (value) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomerFormScreen(
                                                      editFrom: doc),
                                            ));
                                      },
                                      cells: doc.data.asTextRow
                                          .map((e) => DataCell(Text(e)))
                                          .toList(),
                                    ))
                                .toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
