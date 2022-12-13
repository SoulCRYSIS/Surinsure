import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:woot/models/property.dart';
import 'package:woot/screens/policy_form_screen.dart';
import 'package:woot/screens/search_policies_screen.dart';
import 'package:woot/widgets/form_widgets.dart';

import '../constants/firestore_collection.dart';
import '../constants/geo_data.dart';
import '../models/customer.dart';
import '../utils/ui_util.dart';
import '../widgets/misc_widgets.dart';

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen(
      {this.editFrom, required this.customerId, this.customerData, super.key})
      : assert(editFrom != null || customerData != null);

  final PropertyDocument? editFrom;
  final String customerId;
  final Customer? customerData;

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  late PropertyType type = widget.editFrom?.data.type ?? PropertyType.fire;

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
                  widget.editFrom == null
                      ? SizedBox(
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
                        )
                      : TextUneditable(
                          width: 100,
                          value: type.thai,
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
      {this.editFrom, required this.customerId, this.customerData, super.key});

  final PropertyDocument? editFrom;
  final String customerId;
  final Customer? customerData;

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
  String buildingCount = '';
  double? width;
  double? length;
  String occupancy = '';

  final formKey = GlobalKey<FormState>();

  bool get isEditing => widget.editFrom != null;

  void useCustomerAddress() {
    final Customer e = widget.customerData!;
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

    final property = FireProperty(
      customerId: widget.customerId,
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
      buildingCount: buildingCount,
      area: width! * length!,
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
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
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
  void initState() {
    if (isEditing) {
      final FireProperty e = widget.editFrom!.data as FireProperty;

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
      floorCount = e.floorCount;
      externalWall = e.externalWall;
      upperFloor = e.upperFloor;
      roofBeam = e.roofBeam;
      roof = e.roof;
      buildingCount = e.buildingCount;
      width = e.width;
      length = e.length;
    }
    super.initState();
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
                onChanged: (value) => houseNumber = value!,
                label: 'บ้านเลขที่',
                key: UniqueKey(),
              ),
              spacing,
              TextInputField(
                width: 150,
                initialValue: buildingOrVillage,
                onChanged: (value) => buildingOrVillage = value!,
                label: 'ตึก/หมู่บ้าน',
                key: UniqueKey(),
              ),
              spacing,
              TextInputField(
                width: 50,
                initialValue: villageNumber,
                onChanged: (value) => villageNumber = value!,
                label: 'หมู่',
                key: UniqueKey(),
              ),
              spacing,
              TextInputField(
                width: 130,
                initialValue: alley,
                onChanged: (value) => alley = value!,
                label: 'ตรอก',
                key: UniqueKey(),
              ),
              spacing,
              TextInputField(
                width: 130,
                initialValue: lane,
                onChanged: (value) => lane = value!,
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
                onChanged: (value) => zipcode = value!,
                label: 'ไปรษณีย์',
                isOnlyNumber: true,
                isRequire: true,
                key: UniqueKey(),
              ),
              spacing,
              TextInputField(
                width: 200,
                initialValue: road,
                onChanged: (value) => road = value!,
                label: 'ถนน',
                key: UniqueKey(),
              ),
              if (!isEditing) ...[
                spacing,
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () => setState(useCustomerAddress),
                    child: const Text('ใช้ที่อยู่ลูกค้า'),
                  ),
                ),
              ],
            ],
          ),
          spacingVertical,
          Row(
            children: [
              const TopicText('รายละเอียด'),
              spacing,
              TableInputFields(
                headers: const [
                  'จำนวนชั้น',
                  'ฝาผนังด้านนอก',
                  'พื้นชั้นบน',
                  'โครงหลังคา',
                  'หลังคา',
                ],
                fields: [
                  TextInputField(
                    width: 120,
                    initialValue: floorCount?.toString(),
                    isCenter: true,
                    isOnlyDigit: true,
                    isRequire: true,
                    onChanged: (value) => floorCount = int.parse(value!),
                  ),
                  TextInputField(
                    width: 130,
                    initialValue: externalWall,
                    isCenter: true,
                    isRequire: true,
                    onChanged: (value) => externalWall = value!,
                  ),
                  TextInputField(
                    width: 130,
                    initialValue: upperFloor,
                    isCenter: true,
                    isRequire: true,
                    onChanged: (value) => upperFloor = value!,
                  ),
                  TextInputField(
                    width: 130,
                    initialValue: roofBeam,
                    isCenter: true,
                    isRequire: true,
                    onChanged: (value) => roofBeam = value!,
                  ),
                  TextInputField(
                    width: 130,
                    initialValue: roof,
                    isCenter: true,
                    isRequire: true,
                    onChanged: (value) => roof = value!,
                  ),
                ],
              ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              const SizedBox(width: 150),
              spacing,
              TableInputFields(
                headers: const [
                  'จำนวนคูหาหรือหลัง',
                  'สถานที่ใช้เป็น',
                ],
                fields: [
                  TextInputField(
                    width: 150,
                    initialValue: buildingCount,
                    isCenter: true,
                    isRequire: true,
                    onChanged: (value) => buildingCount = value!,
                  ),
                  TextInputField(
                    width: 200,
                    initialValue: occupancy,
                    isCenter: true,
                    isRequire: true,
                    onChanged: (value) => occupancy = value!,
                  ),
                ],
              ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              const SizedBox(width: 150),
              spacing,
              TableInputFields(
                headers: const [
                  'กว้าง (เมตร)',
                  'ยาว (เมตร)',
                  'พื้นที่ (ตารางเมตร)',
                ],
                fields: [
                  TextInputField(
                    width: 150,
                    initialValue: width?.toString(),
                    isCenter: true,
                    isOnlyDigit: true,
                    isRequire: true,
                    onChanged: (value) => setState(() {
                      width = double.parse(value!);
                    }),
                  ),
                  TextInputField(
                    width: 150,
                    initialValue: length?.toString(),
                    isCenter: true,
                    isOnlyDigit: true,
                    isRequire: true,
                    onChanged: (value) => setState(() {
                      length = double.parse(value!);
                    }),
                  ),
                  TextUneditable(
                    width: 150,
                    isCenter: true,
                    value: width != null && length != null
                        ? (width! * length!).toString()
                        : '',
                  ),
                ],
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
                        builder: (context) => SearchPoliciesScreen(),
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
                        builder: (context) => PolicyFormScreen(
                          propertyId: widget.editFrom!.id,
                          customerId: widget.customerId,
                          type: PropertyType.fire,
                        ),
                      )),
                  child: const SizedBox(
                    width: 120,
                    child: Text(
                      'เพิ่มกรมธรรม์',
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
