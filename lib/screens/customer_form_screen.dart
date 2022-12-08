import 'package:flutter/material.dart';
import 'package:woot/constants/firestore_collection.dart';
import 'package:woot/constants/geo_data.dart';
import 'package:woot/models/customer.dart';
import 'package:woot/utils/ui_util.dart';
import 'package:woot/widgets/form_widgets.dart';

import '../constants/constant.dart';
import '../utils/validator.dart';
import '../widgets/misc_widgets.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({this.editFrom, super.key});

  final CustomerDocument? editFrom;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  String assuredType = Constant.assuredTypes.first;
  String namePrefix = Constant.namePrefixes.first;
  String firstname = '';
  String surname = '';
  String? juristicName;
  String province = '';
  String district = '';
  String subdistrict = '';
  String zipcode = '';
  String addressDetail = '';
  String phone = '';
  String email = '';

  final formKey = GlobalKey<FormState>();

  bool get isPerson => 'บุคคลธรรมดา' == assuredType;

  Future<void> upload() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();

    final customer = Customer(
      addressDetail: addressDetail,
      assuredType: assuredType,
      district: district,
      email: email,
      firstname: firstname,
      namePrefix: namePrefix,
      phone: phone,
      province: province,
      subdistrict: subdistrict,
      surname: surname,
      zipcode: zipcode,
      juristicName: juristicName,
    );
    try {
      await UiUtil.loadingScreen(context,
          timeoutSecond: 3,
          future: widget.editFrom == null
              ? FirestoreCollection.customers.add(customer.toJson())
              : widget.editFrom!.reference.update(customer.toJson()));
      //formKey.currentState!.reset();
      // ignore: use_build_context_synchronously
      UiUtil.snackbar(context, 'บันทึกข้อมูลสำเร็จ', isError: false);
    } catch (e) {
      UiUtil.snackbar(context, e.toString());
    }
  }

  @override
  void initState() {
    if (widget.editFrom != null) {
      final Customer e = widget.editFrom!.data;
      assuredType = e.assuredType;
      namePrefix = e.namePrefix;
      firstname = e.firstname;
      surname = e.surname;
      juristicName = e.juristicName;
      province = e.province;
      district = e.district;
      subdistrict = e.subdistrict;
      zipcode = e.zipcode;
      addressDetail = e.addressDetail;
      phone = e.phone;
      email = e.email;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: widget.editFrom == null
              ? const Text('ลงทะเบียนลูกค้าใหม่')
              : const Text('แก้ไขข้อมูลลูกค้า')),
      body: Center(
        child: BidirectionScroll(
          child: BlockBorder(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          initialValue: juristicName,
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
                        initialValue: firstname,
                        onSaved: (value) => firstname = value!,
                        validator: Validator.noneEmpty,
                      ),
                      spacing,
                      TextInputField(
                        label: 'นามสกุล',
                        width: 250,
                        initialValue: surname,
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
                        value: province,
                        width: 200,
                        label: 'จังหวัด',
                        isSearchable: true,
                        items: GeoData.changwats,
                        onChanged: (value) {
                          if (province != value) {
                            setState(() {
                              district = '';
                              subdistrict = '';
                              province = value!;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'จำเป็น';
                          }
                          if (!GeoData.changwats.contains(province)) {
                            return 'ไม่พบชื่อนี้';
                          }
                          return null;
                        },
                      ),
                      spacing,
                      DropdownInputField(
                        value: district,
                        width: 200,
                        label: 'เขต/อำเภอ',
                        isSearchable: true,
                        items: GeoData.amphoes[province] ?? [],
                        onChanged: (value) {
                          if (district != value) {
                            setState(() {
                              subdistrict = '';
                              district = value!;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'จำเป็น';
                          }
                          if (GeoData.amphoes[province] == null) {
                            return null;
                          }
                          if (!GeoData.amphoes[province]!.contains(district)) {
                            return 'ไม่พบชื่อนี้';
                          }
                          return null;
                        },
                      ),
                      spacing,
                      DropdownInputField(
                        value: subdistrict,
                        width: 200,
                        label: 'แขวง/ตำบล',
                        isSearchable: true,
                        items: GeoData.tambons[province]?[district] ?? [],
                        onChanged: (value) => setState(() {
                          subdistrict = value!;
                        }),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'จำเป็น';
                          }
                          if (GeoData.tambons[province]?[district] == null) {
                            return null;
                          }
                          if (!GeoData.tambons[province]![district]!
                              .contains(subdistrict)) {
                            return 'ไม่พบชื่อนี้';
                          }
                          return null;
                        },
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
                        initialValue: zipcode,
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
                        initialValue: addressDetail,
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
                        initialValue: phone,
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
                              RegExp(r'^[0-9]+$')
                                  .hasMatch(value.substring(2))) {
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
                        initialValue: email,
                        onSaved: (value) => email = value!,
                        label: 'อีเมล',
                      ),
                    ],
                  ),
                  spacingVertical,
                  Center(
                    child: ElevatedButton(
                      onPressed: upload,
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
        ),
      ),
    );
  }
}
