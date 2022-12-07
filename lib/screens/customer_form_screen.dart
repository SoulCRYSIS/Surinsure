import 'package:flutter/material.dart';
import 'package:woot/constants/geo_data.dart';
import 'package:woot/widgets/form_widgets.dart';

import '../constants/constant.dart';
import '../utils/validator.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  String assuredType = Constant.assuredTypes.first;
  String namePrefix = Constant.namePrefixes.first;
  late String firstname;
  late String surname;
  String? juristicName;
  String? province;
  String? district;
  String? subdistrict;
  late String zipcode;
  String addressDetail = '';
  String phone = '';
  String email = '';

  final formKey = GlobalKey<FormState>();

  bool get isPerson => 'บุคคลธรรมดา' == assuredType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlockBorder(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Row(
                children: [
                  const TopicText('ประเภทคู่สัญญา'),
                  spacing,
                  DropdownInputField(
                    width: 150,
                    value: assuredType,
                    onChanged: (value) {
                      if (assuredType != value) {
                        setState(() {
                          assuredType = value!;
                        });
                      }
                    },
                    items: Constant.assuredTypes,
                  ),
                  if (!isPerson) ...[
                    const TopicText('ชื่อนิติบุคคล'),
                    spacing,
                    TextInputField(
                      width: 320,
                      onSaved: (value) => juristicName = value!,
                      validator: Validator.noneEmpty,
                    ),
                  ],
                ],
              ),
              spacingVertical,
              Row(
                children: [
                  TopicText(isPerson ? 'ชื่อ' : 'ชื่อเจ้าของ'),
                  spacing,
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField(
                      value: namePrefix,
                      items: Constant.namePrefixes
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => namePrefix = value!,
                      validator: Validator.noneEmpty,
                    ),
                  ),
                  spacing,
                  TextInputField(
                    label: 'ชื่อจริง',
                    width: 250,
                    onSaved: (value) => firstname = value!,
                    validator: Validator.noneEmpty,
                  ),
                  spacing,
                  TextInputField(
                    label: 'นามสกุล',
                    width: 250,
                    onSaved: (value) => surname = value!,
                    validator: Validator.noneEmpty,
                  ),
                ],
              ),
              spacingVertical,
              Row(
                children: [
                  TopicText(isPerson ? 'ที่อยู่' : 'ที่ตั้งนิติบุคคล'),
                  spacing,
                  DropdownInputField(
                    width: 200,
                    label: 'จังหวัด',
                    items: GeoData.changwats,
                    onChanged: (value) {
                      if (province != value) {
                        setState(() {
                          district = null;
                          subdistrict = null;
                          province = value;
                        });
                      }
                    },
                  ),
                  spacing,
                  DropdownInputField(
                    value: district,
                    width: 200,
                    label: 'เขต/อำเภอ',
                    items: province == null ? [] : GeoData.amphoes[province]!,
                    onChanged: (value) {
                      if (district != value) {
                        setState(() {
                          subdistrict = null;
                          district = value;
                        });
                      }
                    },
                  ),
                  spacing,
                  DropdownInputField(
                    value: subdistrict,
                    width: 200,
                    label: 'แขวง/ตำบล',
                    items: province == null || district == null
                        ? []
                        : GeoData.tambons[province]![district]!,
                    onChanged: (value) => setState(() {
                      subdistrict = value!;
                    }),
                  ),
                ],
              ),
              spacingVertical,
              Row(
                children: [
                  const SizedBox(width: 150),
                  spacing,
                  TextInputField(
                    width: 100,
                    onSaved: (value) => zipcode = value!,
                    label: 'ไปรษณีย์',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'จำเป็น';
                      }
                      if (value.length != 5 ||
                          !RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'ไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  spacing,
                  TextInputField(
                    width: 520,
                    onSaved: (value) => addressDetail = value!,
                    label: 'รายละเอียดอื่นๆ',
                  ),
                ],
              ),
              spacingVertical,
              Row(
                children: [
                  const TopicText('ข้อมูลติดต่อ'),
                  spacing,
                  TextInputField(
                    width: 150,
                    onSaved: (value) => phone = value!,
                    label: 'เบอร์โทรศัพท์',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'จำเป็น';
                      }
                      // Thai format
                      if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                        if (value.length != 10 && value.length != 9) {
                          return 'ความยาวไม่ถูกต้อง';
                        }
                        if (value[0] != '0' ||
                            (value.length == 9 && value[1] != '2')) {
                          return 'รูปแบบไม่ถูกต้อง';
                        }
                      }
                      // US format
                      else if (value.substring(0, 2) == '+1' &&
                          RegExp(r'^[0-9]+$').hasMatch(value.substring(2))) {
                        if (value.length != 12) {
                          return 'ความยาวไม่ถูกต้อง';
                        }
                      } else {
                        return 'กรุณากรอกเฉพาะตัวเลข';
                      }
                      return null;
                    },
                  ),
                  spacing,
                  TextInputField(
                    width: 250,
                    onSaved: (value) => email = value!,
                    label: 'อีเมล',
                  ),
                ],
              ),
              spacingVertical,
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const SizedBox(
                    width: 100,
                    child: Text(
                      'ยืนยัน',
                      textAlign: TextAlign.center,
                    ),
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
