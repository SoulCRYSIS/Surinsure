import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:woot/models/insurance.dart';
import 'package:woot/utils/connection_util.dart';
import 'package:woot/utils/ui_util.dart';
import 'package:woot/widgets/form_widgets.dart';

import '../widgets/misc_widgets.dart';

class InsuranceFormScreen extends StatefulWidget {
  const InsuranceFormScreen({required this.customerId, super.key});

  final String customerId;

  @override
  State<InsuranceFormScreen> createState() => _InsuranceFormScreenState();
}

class _InsuranceFormScreenState extends State<InsuranceFormScreen> {
  late String insuranceType;
  late String insuranceNumber;
  String note = '';
  List<PlatformFile>? files;

  List<String> allInsuranceTypes = [
    'อัคคีภัย',
    'รถยนตร์',
    'เบ็ดเตล็ด',
  ];

  final formKey = GlobalKey<FormState>();

  Future<void> uploadFile(PlatformFile file, String name) async {
    await ConnectionUtil.setTimeout(
        3, FirebaseStorage.instance.ref('uploads/$name').putData(file.bytes!));
  }

  Future<void> uploadInsurance() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    insuranceNumber = insuranceNumber.replaceAll('/', '_');

    final docRef = FirebaseFirestore.instance
        .collection('insurances')
        .doc(insuranceNumber);
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
            var fileName = '${insuranceNumber}_${file.name}';
            filesName.add(fileName);
            await uploadFile(file, fileName);
          }
          final insurance = Insurance(
            customerId: widget.customerId,
            insuranceNumber: insuranceNumber,
            insuranceType: insuranceType,
            note: note,
            filesName: filesName,
          );
          await ConnectionUtil.setTimeout(3, docRef.set(insurance.toJson()));
        }(),
      );
    } on ConnectionFailedException catch (e) {
      UiUtil.snackbar(context, e.toString());
    } catch (e, stacktrace) {
      UiUtil.snackbar(context, e.toString());
      debugPrintStack(stackTrace: stacktrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlockBorder(
        child: Column(
          children: [
            Row(
              children: [
                const TopicText('เลขที่กรมธรรม์'),
                spacing,
                TextInputField(
                  width: 250,
                  onSaved: (value) => insuranceNumber = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'จำเป็น';
                    }
                    if (value.contains('\\') || value.contains('.')) {
                      return 'รูปแบบไม่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const TopicText('ประเภท'),
                spacing,
                DropdownInputField(
                  width: 150,
                  hint: 'เลือกประเภท',
                  value: insuranceType,
                  onChanged: (value) => insuranceType = value!,
                  items: allInsuranceTypes,
                ),
              ],
            ),
            spacingVertical,
            Row(
              children: [
                const TopicText('หมายเหตุ'),
                spacing,
                TextInputField(
                  width: 350,
                  onSaved: (value) => note = value!,
                  validator: (value) {
                    if (value != null && value.length > 200) {
                      return 'สูงสุด 200 ตัวอักษร';
                    }
                    return null;
                  },
                ),
                const TopicText('แนบไฟล์'),
                spacing,
                FileUploader(
                  onChanged: (value) => files = value,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
