import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:woot/constants/firestore_collection.dart';
import 'package:woot/constants/geo_data.dart';
import 'package:woot/models/customer.dart';
import 'package:woot/screens/property_form_screen.dart';
import 'package:woot/screens/search_policies_screen.dart';
import 'package:woot/screens/search_properties_screen.dart';
import 'package:woot/utils/server_data.dart';
import 'package:woot/utils/ui_util.dart';
import 'package:woot/utils/user_util.dart';
import 'package:woot/utils/validator.dart';
import 'package:woot/widgets/form_widgets.dart';

import '../constants/constant.dart';
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
  String identificationNumber = '';
  String firstname = '';
  String surname = '';
  String? juristicName = '';
  String province = '';
  String district = '';
  String subdistrict = '';
  String zipcode = '';
  String houseNumber = '';
  String buildingOrVillage = '';
  String villageNumber = '';
  String alley = '';
  String lane = '';
  String road = '';
  String phone = '';
  String email = '';
  List<String> groups = [];

  final formKey = GlobalKey<FormState>();

  bool get isPerson => 'บุคคลธรรมดา' == assuredType;
  bool get isEditing => widget.editFrom != null;

  Future<void> upload() async {
    final customer = Customer(
      assuredType: assuredType,
      namePrefix: namePrefix,
      identificationNumber: identificationNumber,
      firstname: firstname,
      surname: surname,
      juristicName: isPerson ? null : juristicName,
      province: province,
      district: district,
      subdistrict: subdistrict,
      zipcode: zipcode,
      houseNumber: houseNumber,
      buildingOrVillage: buildingOrVillage,
      villageNumber: villageNumber,
      alley: alley,
      lane: lane,
      road: road,
      phone: phone,
      email: email,
      groups: groups,
    );
    try {
      late final DocumentReference<Map<String, dynamic>> newDocRef;
      await UiUtil.loadingScreen(context,
          timeoutSecond: 3,
          future: !isEditing
              ? () async {
                  newDocRef = await FirestoreCollection.customers
                      .add(customer.toJson());
                }()
              : widget.editFrom!.reference.set(customer.toJson()));
      if (!isEditing) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerFormScreen(
                  editFrom: CustomerDocument(
                      id: newDocRef.id, reference: newDocRef, data: customer)),
            ));
      } else {
        // ignore: use_build_context_synchronously
        UiUtil.snackbar(context, 'บันทึกข้อมูลสำเร็จ', isError: false);
      }
    } catch (e) {
      UiUtil.snackbar(context, e.toString());
    }
  }

  @override
  void initState() {
    if (isEditing) {
      final Customer e = widget.editFrom!.data;
      assuredType = e.assuredType;
      namePrefix = e.namePrefix;
      identificationNumber = e.identificationNumber;
      firstname = e.firstname;
      surname = e.surname;
      juristicName = e.juristicName;
      province = e.province;
      district = e.district;
      subdistrict = e.subdistrict;
      zipcode = e.zipcode;
      houseNumber = e.houseNumber;
      buildingOrVillage = e.buildingOrVillage;
      villageNumber = e.villageNumber;
      alley = e.alley;
      lane = e.lane;
      road = e.road;
      phone = e.phone;
      email = e.email;
      groups = e.groups;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isEditing
            ? const Text('ลงทะเบียนลูกค้าใหม่')
            : const Text('แก้ไขข้อมูลลูกค้า'),
        actions: const [HomeButton()],
      ),
      body: Center(
        child: BidirectionScroll(
          child: BlockBorder(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEditing) ...[
                    Row(
                      children: [
                        const TopicText('รหัสลูกค้า'),
                        spacing,
                        TextCopyable(
                          width: 300,
                          value: widget.editFrom!.id,
                        ),
                      ],
                    ),
                    spacingVertical,
                  ],
                  Row(
                    children: [
                      const TopicText('ประเภท'),
                      spacing,
                      DropdownInputField(
                        width: 150,
                        value: assuredType,
                        onEditingComplete: (value) {
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
                          onChanged: (value) => juristicName = value!,
                          require: true,
                        ),
                      ],
                    ],
                  ),
                  spacingVertical,
                  Row(
                    children: [
                      const TopicText('เลขบัตรประชาชน'),
                      spacing,
                      TextInputField(
                        width: 250,
                        initialValue: identificationNumber,
                        onChanged: (value) => identificationNumber = value!,
                        validator: (value) {
                          if (value!.length != 13) {
                            return 'ความยาวไม่ถูกต้อง';
                          }
                          return null;
                        },
                        require: true,
                        onlyDigit: true,
                      ),
                    ],
                  ),
                  spacingVertical,
                  Row(
                    children: [
                      const TopicText('ชื่อผู้เอาประกัน'),
                      spacing,
                      DropdownInputField(
                        width: 100,
                        value: namePrefix,
                        items: Constant.namePrefixes,
                        onEditingComplete: (value) => namePrefix = value!,
                      ),
                      spacing,
                      TextInputField(
                        label: 'ชื่อจริง',
                        width: 250,
                        initialValue: firstname,
                        onChanged: (value) => firstname = value!,
                        require: true,
                      ),
                      spacing,
                      TextInputField(
                        label: 'นามสกุล',
                        width: 250,
                        initialValue: surname,
                        onChanged: (value) => surname = value!,
                        require: true,
                      ),
                    ],
                  ),
                  spacingVertical,
                  Row(
                    children: [
                      const TopicText('ที่อยู่ติดต่อ'),
                      spacing,
                      TextInputField(
                        width: 100,
                        initialValue: houseNumber,
                        onChanged: (value) => houseNumber = value!,
                        label: 'บ้านเลขที่',
                      ),
                      spacing,
                      TextInputField(
                        width: 150,
                        initialValue: buildingOrVillage,
                        onChanged: (value) => buildingOrVillage = value!,
                        label: 'ตึก/หมู่บ้าน',
                      ),
                      spacing,
                      TextInputField(
                        width: 50,
                        initialValue: villageNumber,
                        onChanged: (value) => villageNumber = value!,
                        label: 'หมู่',
                      ),
                      spacing,
                      TextInputField(
                        width: 130,
                        initialValue: alley,
                        onChanged: (value) => alley = value!,
                        label: 'ตรอก',
                      ),
                      spacing,
                      TextInputField(
                        width: 130,
                        initialValue: lane,
                        onChanged: (value) => lane = value!,
                        label: 'ซอย',
                      ),
                    ],
                  ),
                  spacingVertical,
                  Row(
                    children: [
                      const SizedBox(width: 150),
                      spacing,
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
                          if (!GeoData.changwats.contains(province)) {
                            return 'ไม่พบชื่อนี้';
                          }
                          return null;
                        },
                        require: true,
                      ),
                      spacing,
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
                          if (GeoData.amphoes[province] == null) {
                            return null;
                          }
                          if (!GeoData.amphoes[province]!.contains(district)) {
                            return 'ไม่พบชื่อนี้';
                          }
                          return null;
                        },
                        require: true,
                      ),
                      spacing,
                      DropdownSearchableInputField(
                        value: subdistrict,
                        width: 200,
                        label: 'แขวง/ตำบล',
                        items: GeoData.tambons[province]?[district] ?? [],
                        onEditingComplete: (value) => setState(() {
                          subdistrict = value!;
                        }),
                        validator: (value) {
                          if (GeoData.tambons[province]?[district] == null) {
                            return null;
                          }
                          if (!GeoData.tambons[province]![district]!
                              .contains(subdistrict)) {
                            return 'ไม่พบชื่อนี้';
                          }
                          return null;
                        },
                        require: true,
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
                        onChanged: (value) => zipcode = value!,
                        label: 'ไปรษณีย์',
                        validator: (value) {
                          if (value!.length != 5) {
                            return 'ไม่ถูกต้อง';
                          }
                          return null;
                        },
                        require: true,
                        onlyDigit: true,
                      ),
                      spacing,
                      TextInputField(
                        width: 200,
                        initialValue: road,
                        onChanged: (value) => road = value!,
                        label: 'ถนน',
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
                        onChanged: (value) => phone = value!,
                        label: 'เบอร์โทรศัพท์',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }
                          // Thai format
                          if (Validator.isDigits(value)) {
                            if (value.length != 10 && value.length != 9) {
                              return 'ความยาวไม่ถูกต้อง';
                            }
                            if (value[0] != '0' ||
                                (value.length == 9 && value[1] != '2')) {
                              return 'รูปแบบไม่ถูกต้อง';
                            }
                          }
                          // Foriegn format
                          else if (value[0] == '+' &&
                              Validator.isDigits(value.substring(1))) {
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
                        onChanged: (value) => email = value!,
                        label: 'อีเมล',
                      ),
                    ],
                  ),
                  spacingVertical,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TopicText('กลุ่ม'),
                      spacing,
                      SizedBox(
                        width: 640,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            ...groups
                                .asMap()
                                .entries
                                .map(
                                  (e) => Stack(
                                    alignment: AlignmentDirectional.topEnd,
                                    children: [
                                      DropdownSearchableInputField(
                                        value: e.value,
                                        items: ServerData.customerGroups,
                                        width: 200,
                                        require: true,
                                        onChanged: (value) =>
                                            groups[e.key] = value!,
                                        noItemsFoundBuilder: !UserUtil
                                                .hasEditPermission
                                            ? null
                                            : (_) => ListTile(
                                                  onTap: () {
                                                    String input =
                                                        groups[e.key];
                                                    UiUtil.confirmDialog(
                                                      context,
                                                      title:
                                                          'ชื่อกลุ่มที่ต้องการสร้าง',
                                                      content: TextInputField(
                                                        initialValue: input,
                                                        require: true,
                                                        width: 200,
                                                        onChanged: (value) =>
                                                            input = value!,
                                                      ),
                                                      onConfirm:
                                                          (closeDialog) async {
                                                        closeDialog();
                                                        await UiUtil
                                                            .loadingScreen(
                                                          context,
                                                          timeoutSecond: 2,
                                                          future: ServerData
                                                              .fetchData(),
                                                        );

                                                        if (ServerData
                                                            .customerGroups
                                                            .contains(input)) {
                                                          // ignore: use_build_context_synchronously
                                                          UiUtil.snackbar(
                                                              context,
                                                              'ชื่อกลุ่มซ้ำ');
                                                        } else {
                                                          ServerData
                                                              .addCustomerGroup(
                                                                  input);
                                                          // ignore: use_build_context_synchronously
                                                          UiUtil.snackbar(
                                                              context,
                                                              'เพิ่มสำเร็จ',
                                                              isError: false);
                                                        }
                                                        setState(() {});
                                                      },
                                                    );
                                                  },
                                                  title: const Text(
                                                    'สร้างกลุ่มใหม่',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                        validator: (value) {
                                          if (!ServerData.customerGroups
                                              .contains(value)) {
                                            return 'ไม่พบกลุ่มนี้ กรุณาสร้างกลุ่มใหม่';
                                          }
                                          return null;
                                        },
                                      ),
                                      if (UserUtil.hasEditPermission)
                                        InkWell(
                                          child: Icon(
                                            Icons.remove_circle,
                                            color: Theme.of(context).errorColor,
                                          ),
                                          onTap: () => setState(() {
                                            groups.removeAt(e.key);
                                          }),
                                        ),
                                    ],
                                  ),
                                )
                                .toList(),
                            if (UserUtil.hasEditPermission)
                              InkWell(
                                child: SizedBox(
                                  height: 34,
                                  child: Icon(
                                    Icons.add_circle,
                                    size: 20,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onTap: () => setState(() {
                                  groups.add('');
                                }),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  spacingVertical,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isEditing) ...[
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPoliciesScreen(
                                    customerId: widget.editFrom!.id),
                              )),
                          child: const SizedBox(
                            width: 120,
                            child: Text(
                              'ดูกรมธรรม์ทั้งหมด',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        spacing,
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPropertiesScreen(
                                    customerId: widget.editFrom!.id),
                              )),
                          child: const SizedBox(
                            width: 120,
                            child: Text(
                              'ดูทรัพย์สินทั้งหมด',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (UserUtil.hasEditPermission) ...[
                          spacing,
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyFormScreen(
                                    customerId: widget.editFrom!.id,
                                    customerData: widget.editFrom!.data,
                                  ),
                                )),
                            child: const SizedBox(
                              width: 120,
                              child: Text(
                                'เพิ่มทรัพย์สิน',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          spacing,
                        ]
                      ],
                      if (UserUtil.hasEditPermission)
                        ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }
                            formKey.currentState!.save();
                            UiUtil.confirmPin(context, onConfirm: upload);
                          },
                          child: SizedBox(
                            width: 120,
                            child: Text(
                              isEditing ? 'บันทึกการแก้ไข' : 'ลงทะเบียน',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
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
