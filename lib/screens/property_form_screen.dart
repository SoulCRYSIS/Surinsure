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

  bool get isEditing => widget.editFrom != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขข้อมูลทรัพย์สิน' : 'ลงทะเบียนทรัพย์สิน'),
        actions: const [HomeButton()],
      ),
      body: Center(
        child: BidirectionScroll(
          child: BlockBorder(
              child: Column(
            children: [
              if (isEditing) ...[
                Row(
                  children: [
                    const TopicText('รหัสทรัพย์สิน'),
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
                  !isEditing
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
                  case PropertyType.car:
                    return CarPropertyForm(
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

class CarPropertyForm extends StatefulWidget {
  const CarPropertyForm(
      {this.editFrom, required this.customerId, this.customerData, super.key});

  final PropertyDocument? editFrom;
  final String customerId;
  final Customer? customerData;

  @override
  State<CarPropertyForm> createState() => _CarPropertyFormState();
}

class _CarPropertyFormState extends State<CarPropertyForm> {
  String registration = '';
  String registrationProvince = '';
  String code = '';
  String brand = '';
  String model = '';
  String bodyId = '';
  String engineId = '';
  String color = '';
  int? cc;
  double? weight;
  int? seat;

  final formKey = GlobalKey<FormState>();

  bool get isEditing => widget.editFrom != null;

  Future<void> upload() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final property = CarProperty(
      customerId: widget.customerId,
      registration: registration,
      registrationProvince: registrationProvince,
      code: code,
      brand: brand.toLowerCase(),
      model: model.toLowerCase(),
      bodyId: bodyId,
      engineId: engineId,
      color: color,
      cc: cc!,
      weight: weight!,
      seat: seat!,
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
      final CarProperty e = widget.editFrom!.data as CarProperty;
      registration = e.registration;
      registrationProvince = e.registrationProvince;
      code = e.code;
      brand = e.brand;
      model = e.model;
      bodyId = e.bodyId;
      engineId = e.engineId;
      color = e.color;
      cc = e.cc;
      weight = e.weight;
      seat = e.seat;
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
              const TopicText('ทะเบียนรถ'),
              spacing,
              TextInputField(
                width: 100,
                initialValue: registration,
                require: true,
                onChanged: (value) => registration = value!,
              ),
              spacing,
              DropdownSearchableInputField(
                items: GeoData.changwats,
                width: 150,
                require: true,
                label: 'จังหวัด',
                onEditingComplete: (value) => registrationProvince = value!,
              ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              const TopicText('ข้อมูลรถ'),
              spacing,
              TextInputField(
                width: 100,
                initialValue: code,
                require: true,
                label: 'รหัสรถ',
                onChanged: (value) => code = value!,
              ),
              spacing,
              TextInputField(
                width: 150,
                initialValue: brand,
                require: true,
                label: 'ยี่ห้อ',
                onChanged: (value) => brand = value!,
              ),
              spacing,
              TextInputField(
                width: 150,
                initialValue: model,
                require: true,
                label: 'รุ่น',
                onChanged: (value) => model = value!,
              ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              topicSpacing,
              spacing,
              TextInputField(
                width: 150,
                initialValue: color,
                require: true,
                label: 'สี',
                onChanged: (value) => color = value!,
              ),
              spacing,
              TextInputField(
                width: 100,
                initialValue: cc?.toString(),
                onlyDigit: true,
                require: true,
                label: 'ซีซี',
                onChanged: (value) =>
                    cc = value!.isEmpty ? null : int.parse(value),
              ),
              spacing,
              TextInputField(
                width: 150,
                initialValue: weight?.toStringAsFixed(2),
                onlyNumber: true,
                require: true,
                label: 'น้ำหนัก (ตัน)',
                onChanged: (value) =>
                    weight = value!.isEmpty ? null : double.parse(value),
              ),
              spacing,
              TextInputField(
                width: 100,
                initialValue: seat?.toString(),
                onlyDigit: true,
                require: true,
                label: 'ที่นั่ง',
                onChanged: (value) =>
                    seat = value!.isEmpty ? null : int.parse(value),
              ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              topicSpacing,
              spacing,
              TextInputField(
                width: 250,
                initialValue: bodyId,
                require: true,
                label: 'เลขตัวถัง',
                onChanged: (value) => bodyId = value!,
              ),
              spacing,
              TextInputField(
                width: 250,
                initialValue: engineId,
                require: true,
                label: 'เลขเครื่องยนตร์',
                onChanged: (value) => engineId = value!,
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
                            propertyId: widget.editFrom!.id),
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
                          type: PropertyType.car,
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
  double? area;
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
      area: area!,
      width: width,
      length: length,
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
      area = e.area;
      occupancy = e.occupancy;
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
                onlyNumber: true,
                require: true,
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
                    center: true,
                    onlyDigit: true,
                    require: true,
                    onChanged: (value) => floorCount = int.parse(value!),
                  ),
                  TextInputField(
                    width: 130,
                    initialValue: externalWall,
                    center: true,
                    require: true,
                    onChanged: (value) => externalWall = value!,
                  ),
                  TextInputField(
                    width: 130,
                    initialValue: upperFloor,
                    center: true,
                    require: true,
                    onChanged: (value) => upperFloor = value!,
                  ),
                  TextInputField(
                    width: 130,
                    initialValue: roofBeam,
                    center: true,
                    require: true,
                    onChanged: (value) => roofBeam = value!,
                  ),
                  TextInputField(
                    width: 130,
                    initialValue: roof,
                    center: true,
                    require: true,
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
                    center: true,
                    require: true,
                    onChanged: (value) => buildingCount = value!,
                  ),
                  TextInputField(
                    width: 200,
                    initialValue: occupancy,
                    center: true,
                    require: true,
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
                    center: true,
                    onlyNumber: true,
                    onChanged: (value) => setState(() {
                      width = value!.isEmpty ? null : double.parse(value);
                    }),
                  ),
                  TextInputField(
                    width: 150,
                    initialValue: length?.toString(),
                    center: true,
                    onlyNumber: true,
                    onChanged: (value) => setState(() {
                      length = value!.isEmpty ? null : double.parse(value);
                    }),
                  ),
                  TextInputField(
                    width: 150,
                    initialValue: area?.toString(),
                    center: true,
                    onlyNumber: true,
                    require: true,
                    onChanged: (value) => setState(() {
                      area = value!.isEmpty ? null : double.parse(value);
                    }),
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
                        builder: (context) => SearchPoliciesScreen(
                            propertyId: widget.editFrom!.id),
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
