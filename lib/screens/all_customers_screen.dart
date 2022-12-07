
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woot/screens/customer_form_screen.dart';
import 'package:woot/widgets/form_widgets.dart';

import '../models/customer.dart';

class AllCustomersScreen extends StatefulWidget {
  const AllCustomersScreen({super.key});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  int? sortColumnIndex;
  bool sortAscending = true;

  // filters

  static const headers = [
    'ประเภท',
    'ชื่อจริง',
    'นามสกุล',
    'จังหวัด',
    'อำเภอ',
    'ตำบล',
    'ไปรษณีย์',
  ];

  List<String> toRow(Customer customer) => [
        customer.assuredType,
        customer.firstname,
        customer.surname,
        customer.province,
        customer.district,
        customer.subdistrict,
        customer.zipcode,
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ข้อมูลลูกค้า')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Consumer<List<CustomerDocument>?>(
          builder: (context, docs, child) {
            if (docs == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StatefulBuilder(
                builder: (context, setState) {
                  if (sortColumnIndex != null) {
                    docs.sort(
                      (a, b) =>
                          (sortAscending ? 1 : -1) *
                          toRow(a.data)[sortColumnIndex!]
                              .compareTo(toRow(b.data)[sortColumnIndex!]),
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Text(
                            'ตัวกรอง',
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          TextInputField(
                            width: 200,
                            label: 'test',
                            onSaved: (value) {},
                          ),
                        ],
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
                                  onSort: (columnIndex, ascending) =>
                                      setState(() {
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
                                    cells: toRow(doc.data)
                                        .map((e) => DataCell(Text(e)))
                                        .toList(),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
