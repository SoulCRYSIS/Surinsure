import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:woot/models/property.dart';
import 'package:woot/widgets/form_widgets.dart';

import '../constants/firestore_collection.dart';
import '../constants/geo_data.dart';
import '../models/customer.dart';
import '../utils/ui_util.dart';
import '../widgets/misc_widgets.dart';

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen(
      {this.editFrom,
      required this.customerId,
      required this.customerData,
      super.key});

  final PropertyDocument? editFrom;
  final String customerId;
  final Customer customerData;

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  PropertyType type = PropertyType.fire;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงทะเบียนทรัพย์สิน')),
      body: Center(
        child: BidirectionScroll(
          child: BlockBorder(
              child: Column(
            children: [
              Row(
                children: [
                  const TopicText('ประเภท'),
                  spacing,
                  SizedBox(
                    width: 150,
                    child: DropdownButtonFormField(
                      value: type,
                      items: PropertyType.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.thai),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        type = value!;
                      }),
                    ),
                  ),
                ],
              ),
              spacingVertical,
              () {
                switch (type) {
                  case PropertyType.fire:
                    return FirePropertyForm(
                      customerId: widget.customerId,
                      customerData: widget.customerData,
                      editFrom: widget.editFrom,
                    );
                }
              }(),
            ],
          )),
        ),
      ),
    );
  }
}

class FirePropertyForm extends StatefulWidget {
  const FirePropertyForm(
      {this.editFrom,
      required this.customerId,
      required this.customerData,
      super.key});

  final PropertyDocument? editFrom;
  final String customerId;
  final Customer customerData;

  @override
  State<FirePropertyForm> createState() => _FirePropertyFormState();
}

class _FirePropertyFormState extends State<FirePropertyForm> {
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

  int? floorCount;
  String externalWall = '';
  String upperFloor = '';
  String roofBeam = '';
  String roof = '';
  int? buildingCount;
  double? area;
  double? width;
  double? length;
  String occupancy = '';

  final formKey = GlobalKey<FormState>();

  bool get isEditing => widget.editFrom != null;

  void useCustomerAddress() {
    final Customer e = widget.customerData;
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
  }

  Future<void> upload() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();

    final property = FireProperty(
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
      floorCount: floorCount!,
      externalWall: externalWall,
      upperFloor: upperFloor,
      roofBeam: roofBeam,
      roof: roof,
      buildingCount: buildingCount!,
      area: area!,
      width: width!,
      length: length!,
      occupancy: occupancy,
    );
    try {
      late final DocumentReference<Map<String, dynamic>> newDocRef;
      await UiUtil.loadingScreen(context,
          timeoutSecond: 3,
          future: !isEditing
              ? () async {
                  newDocRef = await FirestoreCollection.properties
                      .add(property.toJson());
                }()
              : widget.editFrom!.reference.update(property.toJson()));
      if (!isEditing) {
        formKey.currentState!.reset();
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyFormScreen(
                  customerId: widget.customerId,
                  customerData: widget.customerData,
                  editFrom: PropertyDocument(
                      id: newDocRef.id, reference: newDocRef, data: property)),
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
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Row(
            children: [
              const TopicText('ที่ตั้งทรัพย์สิน'),
              spacing,
              TextInputField(
                width: 100,
                initialValue: houseNumber,
                onSaved: (value) => houseNumber = value!,
                label: 'บ้านเลขที่',
                key: UniqueKey(),
              ),
              spacing,
              TextInputField(
                width: 150,
                initialValue: buildingOrVillage,
                onSaved: (value) => buildingOrVillage = value!,
                label: 'ตึก/หมู่บ้าน',
                key: UniqueKey(),
              ),
              spacing,
              TextInputField(
                width: 50,
                initialValue: villageNumber,
                onSaved: (value) => villageNumber = value!,
                label: 'หมู่',
                key: UniqueKey(),
              ),
              spacing,
              TextInputField(
                width: 130,
                initialValue: alley,
                onSaved: (value) => alley = value!,
                label: 'ตรอก',
                key: UniqueKey(),
              ),
              spacing,
              TextInputField(
                width: 130,
                initialValue: lane,
                onSaved: (value) => lane = value!,
                label: 'ซอย',
                key: UniqueKey(),
              ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              const SizedBox(width: 150),
              spacing,
              DropdownInputField(
                value: province,
                width: 200,
                label: 'จังหวัด',
                isSearchable: true,
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
                isRequire: true,
              ),
              spacing,
              DropdownInputField(
                value: district,
                width: 200,
                label: 'เขต/อำเภอ',
                isSearchable: true,
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
                isRequire: true,
              ),
              spacing,
              DropdownInputField(
                value: subdistrict,
                width: 200,
                label: 'แขวง/ตำบล',
                isSearchable: true,
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
                isRequire: true,
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
                  if (value!.length != 5 ||
                      !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'ไม่ถูกต้อง';
                  }
                  return null;
                },
                isRequire: true,
                key: UniqueKey(),
              ),
              spacing,
              TextInputField(
                width: 200,
                initialValue: road,
                onSaved: (value) => road = value!,
                label: 'ถนน',
                key: UniqueKey(),
              ),
              spacing,
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => setState(useCustomerAddress),
                  child: const Text('ใช้ที่อยู่ลูกค้า'),
                ),
              )
            ],
          ),
          spacingVertical,
          Row(
            children: [
              const TopicText('รายละเอียด'),
              spacing,
              TableInputFields(
                headers: const ['จำนวนชั้น', 'ฝาผนังด้านนอก', 'พื้นชั้นบน'],
                fields: [
                  TextFormField(
                    onSaved: (value) => floorCount = int.parse(value!),
                    textAlign: TextAlign.center,
                  ),
                  TextFormField(
                    onSaved: (value) => externalWall = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'asdad';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    onSaved: (value) => upperFloor = value!,
                  ),
                ],
              )
            ],
          ),
          spacingVertical,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isEditing) ...[
                ElevatedButton(
                  onPressed: () {},
                  child: const SizedBox(
                    width: 120,
                    child: Text(
                      'ดูทรัพย์สินทั้งหมด',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                spacing,
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PropertyFormScreen(
                          customerId: widget.customerId,
                          customerData: widget.customerData,
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
              ],
              ElevatedButton(
                onPressed: upload,
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
    );
  }
}
