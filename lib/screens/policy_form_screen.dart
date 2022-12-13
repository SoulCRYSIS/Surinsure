import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:woot/constants/firestore_collection.dart';
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
  double? netPremium;
  double? duty;
  double? tax;
  String? company;

  double? buildingFund;
  double? furnitureFund;
  double? buildingFurnitureFund;
  double? stockFund;
  double? machineFund;
  double? otherFund;

  List<PlatformFile> files = [];
  bool isSelectedBuildingFurniture = false;
  List<String> allCompanies = ['วิริยะประกันภัย', 'กรุงเทพประกันภัย'];

  final formKey = GlobalKey<FormState>();

  final buildingFurnitureFundKey = UniqueKey();
  final buildingFundKey = UniqueKey();
  final furnitureFundKey = UniqueKey();

  bool get isEditing => widget.editFrom != null;
  Future<void> upload() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    policyNumber = policyNumber.replaceAll('/', '_');

    final docRef = FirestoreCollection.policies.doc(policyNumber);
    if (!isEditing && (await docRef.get()).exists) {
      UiUtil.snackbar(context, 'เลขที่กรมธรรม์ซ้ำ กรุณาตรวจสอบอีกครั้ง');
      return;
    }

    List<String> filesName = [];
    for (var file in files) {
      var fileName = '${policyNumber}_${file.name}';
      filesName.add(fileName);
    }
    final policy = FirePolicy(
      customerId: widget.customerId,
      propertyId: widget.propertyId,
      policyNumber: policyNumber,
      startDate: startDate!,
      endDate: endDate!,
      policyIssueDate: policyIssueDate,
      contractIssueDate: contractIssueDate!,
      filesName: isEditing
          ? [...filesName, ...widget.editFrom!.data.filesName]
          : filesName,
      netPremium: netPremium!,
      duty: duty!,
      tax: tax!,
      company: company!,
      buildingFund: isSelectedBuildingFurniture ? 0 : (buildingFund ?? 0),
      furnitureFund: isSelectedBuildingFurniture ? 0 : (furnitureFund ?? 0),
      buildingFurnitureFund:
          isSelectedBuildingFurniture ? (buildingFurnitureFund ?? 0) : 0,
      stockFund: stockFund ?? 0,
      machineFund: machineFund ?? 0,
      otherFund: otherFund ?? 0,
    );

    try {
      await UiUtil.loadingScreen(
        context,
        timeoutSecond: 30,
        future: () async {
          for (int i = 0; i < filesName.length; i++) {
            await ServerData.uploadFile(files[i], filesName[i]);
          }
          await ConnectionUtil.setTimeout(3, docRef.set(policy.toJson()));
        }(),
      );
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
        setState(() {
          files = [];
          widget.editFrom!.data.filesName.addAll(filesName);
        });
        // ignore: use_build_context_synchronously
        UiUtil.snackbar(context, 'บันทึกข้อมูลสำเร็จ', isError: false);
      }
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
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
      netPremium = e.netPremium;
      duty = e.duty;
      tax = e.tax;
      company = e.company;
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
              const TopicText('บริษัทรับประกัน'),
              spacing,
              isEditing
                  ? TextUneditable(
                      width: 200,
                      value: company ?? '',
                    )
                  : DropdownInputField(
                      value: company,
                      width: 200,
                      isRequire: true,
                      onEditingComplete: (value) => company = value!,
                      items: allCompanies,
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
              const Text('ถึง'),
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
              const TopicText('วันที่ทำสัญญา'),
              spacing,
              DateInputField(
                initialValue: contractIssueDate,
                isRequire: true,
                onSaved: (value) => contractIssueDate = value!,
              ),
              spacing,
              const TopicText('วันที่ทำกรมธรรม์'),
              spacing,
              DateInputField(
                initialValue: policyIssueDate,
                isRequire: true,
                onSaved: (value) => policyIssueDate = value!,
              ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              const TopicText('เบี้ยประกันภัย'),
              spacing,
              TableInputFields(
                headers: const ['เบี้ยประกันสุทธิ', 'อากร', 'ภาษี', 'เบี้ยรวม'],
                fields: [
                  TextInputField(
                    initialValue: netPremium?.toStringAsFixed(2),
                    isCenter: true,
                    isOnlyNumber: true,
                    isRequire: true,
                    width: 150,
                    onChanged: (value) => setState(
                      () {
                        netPremium = double.parse(value!);
                      },
                    ),
                  ),
                  TextInputField(
                    initialValue: duty?.toStringAsFixed(2),
                    isCenter: true,
                    isOnlyNumber: true,
                    isRequire: true,
                    width: 150,
                    onChanged: (value) => setState(
                      () {
                        duty = double.parse(value!);
                      },
                    ),
                  ),
                  TextInputField(
                    initialValue: tax?.toStringAsFixed(2),
                    isCenter: true,
                    isOnlyNumber: true,
                    isRequire: true,
                    width: 150,
                    onChanged: (value) => setState(
                      () {
                        tax = double.parse(value!);
                      },
                    ),
                  ),
                  TextUneditable(
                    value: (netPremium != null && duty != null && tax != null)
                        ? (netPremium! + duty! + tax!).toStringAsFixed(2)
                        : '',
                    width: 150,
                  )
                ],
              )
            ],
          ),
          spacingVertical,
          Row(
            children: [
              const TopicText('ทุนประกันภัย'),
              spacing,
              Row(
                children: [
                  Radio(
                    value: false,
                    groupValue: isSelectedBuildingFurniture,
                    onChanged: (value) => setState(() {
                      isSelectedBuildingFurniture = false;
                    }),
                  ),
                  const Text('สิ่งปลูกสร้าง'),
                ],
              ),
              spacing,
              Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: isSelectedBuildingFurniture,
                    onChanged: (value) => setState(() {
                      isSelectedBuildingFurniture = true;
                    }),
                  ),
                  const Text('สิ่งปลูกสร้าง + เฟอร์นิเจอร์'),
                ],
              ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              topicSpacing,
              spacing,
              isSelectedBuildingFurniture
                  ? TableInputFields(
                      headers: const [
                        'สิ่งปลูกสร้าง + เฟอร์นิเจอร์',
                        'สต๊อกสินค้า'
                      ],
                      fields: [
                        TextInputField(
                          key: buildingFurnitureFundKey,
                          initialValue:
                              buildingFurnitureFund?.toStringAsFixed(2),
                          isCenter: true,
                          isOnlyNumber: true,
                          width: 300,
                          onChanged: (value) => setState(
                            () {
                              buildingFurnitureFund = double.parse(value!);
                            },
                          ),
                        ),
                        TextInputField(
                          initialValue: stockFund?.toStringAsFixed(2),
                          isCenter: true,
                          isOnlyNumber: true,
                          width: 150,
                          onChanged: (value) => setState(
                            () {
                              stockFund = double.parse(value!);
                            },
                          ),
                        ),
                      ],
                    )
                  : TableInputFields(
                      headers: const [
                        'สิ่งปลูกสร้าง',
                        'เฟอร์นิเจอร์',
                        'สต๊อกสินค้า'
                      ],
                      fields: [
                        TextInputField(
                          key: buildingFundKey,
                          initialValue: buildingFund?.toStringAsFixed(2),
                          isCenter: true,
                          isOnlyNumber: true,
                          width: 150,
                          onChanged: (value) => setState(
                            () {
                              buildingFund =
                                  value!.isEmpty ? null : double.parse(value);
                            },
                          ),
                        ),
                        TextInputField(
                          key: furnitureFundKey,
                          initialValue: furnitureFund?.toStringAsFixed(2),
                          isCenter: true,
                          isOnlyNumber: true,
                          width: 150,
                          onChanged: (value) => setState(
                            () {
                              furnitureFund =
                                  value!.isEmpty ? null : double.parse(value);
                            },
                          ),
                        ),
                        TextInputField(
                          initialValue: stockFund?.toStringAsFixed(2),
                          isCenter: true,
                          isOnlyNumber: true,
                          width: 150,
                          onChanged: (value) => setState(
                            () {
                              stockFund =
                                  value!.isEmpty ? null : double.parse(value);
                            },
                          ),
                        ),
                      ],
                    ),
            ],
          ),
          spacingVertical,
          Row(
            children: [
              topicSpacing,
              spacing,
              TableInputFields(
                headers: const ['เครื่องจักร', 'อื่นๆ', 'รวม'],
                fields: [
                  TextInputField(
                    initialValue: machineFund?.toStringAsFixed(2),
                    isCenter: true,
                    isOnlyNumber: true,
                    width: 150,
                    onChanged: (value) => setState(
                      () {
                        machineFund =
                            value!.isEmpty ? null : double.parse(value);
                      },
                    ),
                  ),
                  TextInputField(
                    initialValue: otherFund?.toStringAsFixed(2),
                    isCenter: true,
                    isOnlyNumber: true,
                    width: 150,
                    onChanged: (value) => setState(
                      () {
                        otherFund = value!.isEmpty ? null : double.parse(value);
                      },
                    ),
                  ),
                  TextUneditable(
                    width: 150,
                    value: ((isSelectedBuildingFurniture
                                ? buildingFurnitureFund ?? 0
                                : (buildingFund ?? 0) + (furnitureFund ?? 0)) +
                            (stockFund ?? 0) +
                            (machineFund ?? 0) +
                            (otherFund ?? 0))
                        .toStringAsFixed(2),
                  ),
                ],
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
                files: files,
                onChanged: (value) => setState(() {
                  files = value;
                }),
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
