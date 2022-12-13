import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:woot/models/policy.dart';
import 'package:woot/screens/policy_form_screen.dart';

import '../constants/firestore_collection.dart';
import '../utils/ui_util.dart';
import '../widgets/misc_widgets.dart';

class SearchPoliciesScreen extends StatefulWidget {
  const SearchPoliciesScreen({super.key});

  @override
  State<SearchPoliciesScreen> createState() => _SearchPoliciesScreenState();
}

class _SearchPoliciesScreenState extends State<SearchPoliciesScreen> {
  int? sortColumnIndex;
  bool sortAscending = true;

  final formKey = GlobalKey<FormState>();

  List<PolicyDocument> docs = [];

  Future<void> search() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    const lastChar = '\uf8ff';

    Query<Map<String, dynamic>> query = FirestoreCollection.policies;
    try {
      await UiUtil.loadingScreen(context, timeoutSecond: 3, future: () async {
        docs = (await query.get())
            .docs
            .map((e) => PolicyDocument.fromDoc(e))
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
      appBar: AppBar(title: const Text('ข้อมูลกรมธรรม์')),
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
                    ElevatedButton(
                      onPressed: search,
                      child: const Text('ค้นหา'),
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
                  columnSpacing: 10,
                  columns: Policy.headers
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
                                    builder: (context) => PolicyFormScreen(
                                      propertyId: doc.data.propertyId,
                                      customerId: doc.data.customerId,
                                      type: doc.data.type,
                                      editFrom: doc,
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
            ],
          ),
        ),
      ),
    );
  }
}
