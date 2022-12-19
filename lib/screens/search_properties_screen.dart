import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:woot/models/property.dart';
import 'package:woot/screens/property_form_screen.dart';

import '../constants/firestore_collection.dart';
import '../constants/geo_data.dart';
import '../utils/ui_util.dart';
import '../widgets/form_widgets.dart';
import '../widgets/misc_widgets.dart';

class SearchPropertiesScreen extends StatefulWidget {
  const SearchPropertiesScreen({this.customerId, super.key});

  final String? customerId;

  @override
  State<SearchPropertiesScreen> createState() => _SearchPropertiesScreenState();
}

class _SearchPropertiesScreenState extends State<SearchPropertiesScreen> {
  int? sortColumnIndex;
  bool sortAscending = true;

  final formKey = GlobalKey<FormState>();

  // default fields
  late String customerId = widget.customerId ?? '';

  PropertyType? type;

  // fire fields
  String province = '';
  String district = '';
  String subdistrict = '';
  String zipcode = '';

  List<PropertyDocument>? docs;

  void resetFields() {
    type = null;
    customerId = widget.customerId ?? '';
    province = '';
    district = '';
    subdistrict = '';
    zipcode = '';
  }

  Future<void> search() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    Query<Map<String, dynamic>> query = FirestoreCollection.properties;
    if (customerId.isNotEmpty) {
      query = query.where('customerId', isEqualTo: customerId);
    }
    switch (type) {
      case PropertyType.fire:
        query = query.where('type', isEqualTo: type!.name);
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
        break;
      case null:
        break;
    }

    try {
      await UiUtil.loadingScreen(context, timeoutSecond: 3, future: () async {
        docs = (await query.get())
            .docs
            .map((e) => PropertyDocument.fromDoc(e))
            .toList();
      }());
    } catch (e, stacktrace) {
      UiUtil.snackbar(context, e.toString());
      debugPrintStack(stackTrace: stacktrace);
    }
    setState(() {});
  }

  @override
  void initState() {
    if (widget.customerId != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        UiUtil.loadingScreen(context, timeoutSecond: 3, future: search());
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลทรัพย์สิน'),
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
                  TextInputField(
                    initialValue: widget.customerId,
                    width: 200,
                    label: 'รหัสลูกค้า',
                    onChanged: (value) => customerId = value!,
                  ),
                  spacingVertical,
                  SizedBox(
                    width: 200,
                    height: 32,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: 'ประเภท'),
                      value: type,
                      items: PropertyType.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.thai),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        type = value;
                      }),
                    ),
                  ),
                  spacingVertical,
                  if (type != null)
                    ...() {
                      switch (type!) {
                        case PropertyType.fire:
                          return [
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
                                if (!GeoData.amphoes[province]!
                                    .contains(district)) {
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
                              onEditingComplete: (value) =>
                                  subdistrict = value!,
                              validator: (value) {
                                if (subdistrict.isEmpty ||
                                    GeoData.tambons[province]?[district] ==
                                        null) {
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
                              onChanged: (value) => zipcode = value!,
                              onlyDigit: true,
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
                            spacingVertical,
                          ];
                        case PropertyType.car:
                          return [];
                      }
                    }(),
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
                            columns: FireProperty.headers
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
                                                  PropertyFormScreen(
                                                editFrom: doc,
                                                customerId: doc.data.customerId,
                                              ),
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
