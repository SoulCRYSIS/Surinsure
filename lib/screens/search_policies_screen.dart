import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:woot/models/policy.dart';
import 'package:woot/screens/policy_form_screen.dart';
import 'package:woot/utils/server_data.dart';

import '../constants/firestore_collection.dart';
import '../models/property.dart';
import '../utils/ui_util.dart';
import '../widgets/form_widgets.dart';
import '../widgets/misc_widgets.dart';

class SearchPoliciesScreen extends StatefulWidget {
  const SearchPoliciesScreen({super.key, this.customerId, this.propertyId});

  final String? customerId;
  final String? propertyId;

  @override
  State<SearchPoliciesScreen> createState() => _SearchPoliciesScreenState();
}

class _SearchPoliciesScreenState extends State<SearchPoliciesScreen> {
  final formKey = GlobalKey<FormState>();

  late String customerId = widget.customerId ?? '';
  late String propertyId = widget.propertyId ?? '';
  PropertyType? type;
  String policyNumber = '';
  String company = '';
  bool? isPaid;

  List<PolicyDocument>? docs;

  void resetFields() {
    customerId = widget.customerId ?? '';
    propertyId = widget.propertyId ?? '';
    type = null;
    policyNumber = '';
    company = '';
    isPaid = null;
  }

  Future<void> search() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    Query<Map<String, dynamic>> query = FirestoreCollection.policies;
    if (customerId.isNotEmpty) {
      query = query.where('customerId', isEqualTo: customerId);
    }
    if (propertyId.isNotEmpty) {
      query = query.where('propertyId', isEqualTo: propertyId);
    }
    if (policyNumber.isNotEmpty) {
      query = query.where('policyNumber', isEqualTo: policyNumber);
    }
    if (company.isNotEmpty) {
      query = query.where('company', isEqualTo: company);
    }
    if (isPaid != null) {
      query = query.where('isPaid', isEqualTo: isPaid);
    }
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
  void initState() {
    if (widget.customerId != null || widget.propertyId != null) {
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
        title: const Text('ข้อมูลกรมธรรม์'),
        actions: const [HomeButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Form(
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
                        TextInputField(
                          initialValue: widget.propertyId,
                          width: 200,
                          label: 'รหัสทรัพย์สิน',
                          onChanged: (value) => propertyId = value!,
                        ),
                        spacingVertical,
                        TextInputField(
                          width: 200,
                          label: 'เลขที่กรมธรรม์',
                          onChanged: (value) => propertyId = value!,
                        ),
                        spacingVertical,
                        SizedBox(
                          width: 200,
                          height: 32,
                          child: DropdownButtonFormField<bool>(
                            decoration: const InputDecoration(
                                labelText: 'สถานะการชำระเงิน'),
                            value: isPaid,
                            items: const [
                              DropdownMenuItem(
                                value: true,
                                child: Text('ชำระแล้ว'),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: Text('ยังไม่ชำระ'),
                              ),
                            ],
                            onChanged: (value) => setState(() {
                              isPaid = value;
                            }),
                          ),
                        ),
                        spacingVertical,
                        SizedBox(
                          width: 200,
                          height: 32,
                          child: DropdownButtonFormField(
                            decoration:
                                const InputDecoration(labelText: 'ประเภท'),
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
                        DropdownInputField(
                          items: ServerData.insuranceCompanies,
                          width: 200,
                          label: 'บริษัทรับประกัน',
                          onEditingComplete: (value) => company = value!,
                        ),
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
                ),
              ),
              const VerticalDivider(thickness: 1),
              spacing,
              Flexible(
                fit: FlexFit.loose,
                child: docs == null
                    ? Container()
                    : docs!.isEmpty
                        ? const Center(
                            child: Text(
                              'ไม่พบผลการค้นหา',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.grey),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  (type == null ? PropertyType.values : [type!])
                                      .map(
                                (thisType) {
                                  final thisTypeDocs = docs!
                                      .where((element) =>
                                          element.data.type == thisType)
                                      .toList();
                                  if (thisTypeDocs.isEmpty) {
                                    return Container();
                                  }
                                  return _Table(
                                    docs: thisTypeDocs,
                                    isShowTypeText: type == null,
                                    type: thisType,
                                  );
                                },
                              ).toList(),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Table extends StatefulWidget {
  const _Table({
    required this.isShowTypeText,
    required this.type,
    required this.docs,
  });

  final bool isShowTypeText;
  final PropertyType type;
  final List<PolicyDocument> docs;

  @override
  State<_Table> createState() => __TableState();
}

class __TableState extends State<_Table> {
  int? sortColumnIndex;
  bool sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isShowTypeText)
          Text(
            widget.type.thai,
            style: const TextStyle(
                fontSize: 20, decoration: TextDecoration.underline),
          ),
        DataTable(
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
                    widget.docs.sort(
                      (a, b) =>
                          (ascending ? 1 : -1) *
                          a.data.asTextRow[columnIndex]
                              .compareTo(b.data.asTextRow[columnIndex]),
                    );
                  }),
                ),
              )
              .toList(),
          rows: widget.docs
              .map((doc) => DataRow(
                    onSelectChanged: (value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PolicyFormScreen(
                              editFrom: doc,
                              type: doc.data.type,
                              propertyId: doc.data.propertyId,
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
        spacingVertical,
      ],
    );
  }
}
