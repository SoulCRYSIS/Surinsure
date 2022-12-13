import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:woot/models/policy.dart';
import 'package:woot/models/property.dart';
import 'package:woot/utils/connection_util.dart';
import 'package:woot/utils/server_data.dart';
import 'package:woot/utils/ui_util.dart';
import 'package:woot/widgets/form_widgets.dart';

import '../widgets/misc_widgets.dart';

class PolicyFormScreen extends StatefulWidget {
  const PolicyFormScreen({
    this.editFrom,
    required this.propertyId,
    required this.customerId,
    required this.type,
    super.key,
  });

  final String propertyId;
  final String customerId;
  final PropertyType type;
  final PolicyDocument? editFrom;

  @override
  State<PolicyFormScreen> createState() => _PolicyFormScreenState();
}

class _PolicyFormScreenState extends State<PolicyFormScreen> {
  final formKey = GlobalKey<FormState>();

  bool get isEditing => widget.editFrom != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: widget.editFrom == null
              ? const Text('เพิ่มกรมธรรม์')
              : const Text('แก้ไขกรมธรรม์')),
      body: Center(
        child: BidirectionScroll(
          child: BlockBorder(
            child: () {
              switch (widget.type) {
                case PropertyType.fire:
                  return FirePolcyForm(
                    customerId: widget.customerId,
                    propertyId: widget.propertyId,
                    editFrom: widget.editFrom,
                  );
              }
            }(),
          ),
        ),
      ),
    );
  }
}

class FirePolcyForm extends StatefulWidget {
  const FirePolcyForm({
    required this.customerId,
    required this.propertyId,
    this.editFrom,
    super.key,
  });

  final PolicyDocument? editFrom;
  final String customerId;
  final String propertyId;

  @override
  State<FirePolcyForm> createState() => _FirePolcyFormState();
}

class _FirePolcyFormState extends State<FirePolcyForm> {
  String policyNumber = '';
  DateTime? startDate;
  DateTime? endDate;
  DateTime? contractIssueDate;
  DateTime policyIssueDate = DateTime.now();
  double? premium;
  double? premiumDiscount;
  double? duty;
  double? tax;

  int? buildingFund;
  int? furnitureFund;
  int? buildingFurnitureFund;
  int? stockFund;
  int? machineFund;
  int? otherFund;

  List<PlatformFile>? files;
  bool isSelectedBuildingFurniture = false;

  final formKey = GlobalKey<FormState>();

  bool get isEditing => widget.editFrom != null;
  Future<void> upload() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    policyNumber = policyNumber.replaceAll('/', '_');

    final docRef =
        FirebaseFirestore.instance.collection('insurances').doc(policyNumber);
    if ((await docRef.get()).exists) {
      UiUtil.snackbar(context, 'เลขที่กรมธรรม์ซ้ำ กรุณาตรวจสอบอีกครั้ง');
      return;
    }

    try {
      await UiUtil.loadingScreen(
        context,
        timeoutSecond: 30,
        future: () async {
          List<String> filesName = [];
          for (var file in files!) {
            var fileName = '${policyNumber}_${file.name}';
            filesName.add(fileName);
            await ServerData.uploadFile(file, fileName);
          }
          final policy = FirePolicy(
            customerId: widget.customerId,
            propertyId: widget.propertyId,
            policyNumber: policyNumber,
            startDate: startDate!,
            endDate: endDate!,
            policyIssueDate: policyIssueDate,
            contractIssueDate: contractIssueDate!,
            filesName: filesName,
            premium: premium!,
            premiumDiscount: premiumDiscount!,
            duty: duty!,
            tax: tax!,
            buildingFund: buildingFund!,
            furnitureFund: furnitureFund!,
            buildingFurnitureFund: buildingFurnitureFund!,
            stockFund: stockFund!,
            machineFund: machineFund!,
            otherFund: otherFund!,
          );
          await ConnectionUtil.setTimeout(3, docRef.set(policy.toJson()));
          if (!isEditing) {
            formKey.currentState!.reset();
            // ignore: use_build_context_synchronously
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PolicyFormScreen(
                      type: PropertyType.fire,
                      propertyId: widget.propertyId,
                      customerId: widget.customerId,
                      editFrom: PolicyDocument(
                        id: policyNumber,
                        reference: docRef,
                        data: policy,
                      )),
                ));
          } else {
            // ignore: use_build_context_synchronously
            UiUtil.snackbar(context, 'บันทึกข้อมูลสำเร็จ', isError: false);
          }
        }(),
      );
    } catch (e) {
      UiUtil.snackbar(context, e.toString());
    }
  }

  @override
  void initState() {
    if (isEditing) {
      final FirePolicy e = widget.editFrom!.data as FirePolicy;
      policyNumber = e.policyNumber;
      startDate = e.startDate;
      endDate = e.endDate;
      contractIssueDate = e.contractIssueDate;
      policyIssueDate = e.policyIssueDate;
      premium = e.premium;
      premiumDiscount = e.premiumDiscount;
      duty = e.duty;
      tax = e.tax;
      buildingFund = e.buildingFund;
      furnitureFund = e.furnitureFund;
      stockFund = e.stockFund;
      machineFund = e.machineFund;
      otherFund = e.otherFund;
      isSelectedBuildingFurniture = buildingFurnitureFund != 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const TopicText('เลขที่กรมธรรม์'),
              spacing,
              isEditing
                  ? TextCopyable(
                      width: 300,
                      value: policyNumber,
                    )
                  : TextInputField(
                      width: 300,
                      onChanged: (value) => policyNumber = value!,
                      isRequire: true,
                      validator: (value) {
                        if (value!.contains('\\') || value.contains('.')) {
                          return 'รูปแบบไม่ถูกต้อง';
                        }
                        return null;
                      },
                    ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              const TopicText('ระยะเวลาประกันภัย'),
              spacing,
              DateInputField(
                label: 'เริ่มต้น',
                initialValue: startDate,
                isRequire: true,
                onSaved: (value) => startDate = value!,
              ),
              spacing,
              DateInputField(
                label: 'สิ้นสุด',
                initialValue: endDate,
                isRequire: true,
                onSaved: (value) => endDate = value!,
              ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              const TopicText('แนบไฟล์'),
              if (isEditing && widget.editFrom!.data.filesName.isNotEmpty) ...[
                spacing,
                AllFilesExpandPanel(
                  items: widget.editFrom!.data.filesName,
                  prefixLength: widget.editFrom!.data.policyNumber.length,
                ),
              ],
              spacing,
              FileUploader(
                onChanged: (value) => files = value,
              ),
            ],
          ),
          spacingVertical,
          Center(
            child: ElevatedButton(
              onPressed: upload,
              child: Text(isEditing ? 'บันทึกการแก้ไข' : 'ลงทะเบียน'),
            ),
          )
        ],
      ),
    );
  }
}
