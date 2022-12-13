import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:woot/utils/server_data.dart';
import 'package:woot/utils/validator.dart';
import 'package:woot/widgets/misc_widgets.dart';

const topicSpacing = SizedBox(width: 150);

class TopicText extends StatelessWidget {
  const TopicText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Text(
        '$text :',
        textAlign: TextAlign.right,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class DateInputField extends StatelessWidget {
  const DateInputField({
    required this.onSaved,
    this.initialValue,
    this.label,
    this.isRequire = false,
    super.key,
  });

  final String? label;
  final bool isRequire;
  final DateTime? initialValue;
  final void Function(DateTime? value) onSaved;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: TextFormField(
        initialValue: initialValue == null
            ? null
            : DateFormat('dd/MM/').format(initialValue!) +
                (initialValue!.year + 543).toString(),
        decoration: InputDecoration(
            labelText: label,
            hintText: 'dd/mm/yyyy',
            suffixIcon: const Icon(
              Icons.calendar_month,
            )),
        onSaved: (newValue) {
          if (newValue == null) {
            onSaved(null);
            return;
          }
          var splited = newValue.split('/');
          onSaved(DateTime(
            int.parse(splited[2]) - 543,
            int.parse(splited[1]),
            int.parse(splited[0]),
          ));
        },
        validator: (value) {
          if (isRequire && (value == null || value.isEmpty)) {
            return 'จำเป็น';
          }
          if (!RegExp(r'^\d\d\/\d\d\/\d\d\d\d$').hasMatch(value!)) {
            return 'รูปแบบผิด';
          }
          return null;
        },
      ),
    );
  }
}

class TextInputField extends StatelessWidget {
  const TextInputField({
    this.label,
    this.initialValue,
    this.isOnlyDigit = false,
    this.isOnlyNumber = false,
    this.width,
    required this.onChanged,
    this.validator,
    this.isRequire = false,
    this.isCenter = false,
    super.key,
  }) : assert(!(isOnlyDigit && isOnlyNumber));

  final String? initialValue;
  final String? label;
  final bool isRequire;
  final bool isOnlyDigit;
  final bool isOnlyNumber;
  final double? width;
  final bool isCenter;

  final void Function(String? value) onChanged;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        initialValue: initialValue,
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
        validator: isRequire ? Validator.notEmpty(validator) : validator,
        inputFormatters: isOnlyDigit
            ? [FilteringTextInputFormatter.digitsOnly]
            : isOnlyNumber
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))]
                : null,
      ),
    );
  }
}

class TextCopyable extends StatelessWidget {
  const TextCopyable({
    required this.value,
    required this.width,
    super.key,
  });

  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return FieldBorder(
      width: width,
      color: Colors.grey[300],
      child: Row(
        children: [
          InkWell(
            onTap: () => Clipboard.setData(ClipboardData(text: value)),
            child: const Icon(Icons.copy),
          ),
          spacing,
          SelectableText(value),
        ],
      ),
    );
  }
}

class TextUneditable extends StatelessWidget {
  const TextUneditable({
    required this.value,
    required this.width,
    this.isCenter = false,
    super.key,
  });

  final String value;
  final double width;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    return FieldBorder(
      width: width,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          value,
          textAlign: isCenter ? TextAlign.center : TextAlign.start,
        ),
      ),
    );
  }
}

class FieldBorder extends StatelessWidget {
  const FieldBorder(
      {required this.child, required this.width, this.color, super.key});

  final Widget child;
  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: color,
      ),
      child: child,
    );
  }
}

class DropdownInputField extends StatelessWidget {
  const DropdownInputField({
    this.hint,
    this.value,
    this.label,
    this.isSearchable = false,
    this.validator,
    this.isRequire = false,
    required this.width,
    required this.items,
    required this.onEditingComplete,
    super.key,
  });
  final List<String> items;
  final String? hint;
  final String? label;
  final String? value;
  final double width;
  final bool isRequire;
  final bool isSearchable;
  final void Function(String? value) onEditingComplete;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController =
        TextEditingController(text: value);
    return SizedBox(
      width: width,
      child: isSearchable
          ? Focus(
              skipTraversal: true,
              onFocusChange: (value) {
                if (!value) {
                  onEditingComplete(textEditingController.text);
                }
              },
              child: TypeAheadFormField(
                animationDuration: const Duration(),
                debounceDuration: const Duration(milliseconds: 100),
                textFieldConfiguration: TextFieldConfiguration(
                  controller: textEditingController,
                  decoration: InputDecoration(labelText: label),
                ),
                suggestionsCallback: (pattern) =>
                    items.where((item) => item.contains(pattern)),
                itemBuilder: (context, itemData) => ListTile(
                  title: Text(itemData),
                ),
                onSuggestionSelected: (suggestion) {
                  onEditingComplete(suggestion);
                  textEditingController.text = suggestion;
                },
                noItemsFoundBuilder: (context) => const ListTile(
                  title: Text(
                    'ไม่พบรายการ',
                    textAlign: TextAlign.center,
                  ),
                ),
                autoFlipDirection: true,
                validator:
                    isRequire ? Validator.notEmpty(validator) : validator,
              ),
            )
          : DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(labelText: label),
              hint: hint == null ? null : Text(hint!),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: onEditingComplete,
              validator: isRequire
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'จำเป็น';
                      }
                      if (validator != null) {
                        return validator!(value);
                      }
                      return null;
                    }
                  : validator,
            ),
    );
  }
}

class FileUploader extends StatelessWidget {
  const FileUploader({required this.onChanged, required this.files, super.key});

  final void Function(List<PlatformFile> value) onChanged;
  final List<PlatformFile> files;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      InkWell(
        onTap: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
          );
          if (result == null) {
            return;
          }
          onChanged(result.files);
        },
        child: FieldBorder(
          width: 200,
          child: Row(
            children: [
              Icon(
                Icons.file_upload,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  files.isEmpty
                      ? 'อัพโหลดไฟล์'
                      : files.length == 1
                          ? files.first.name
                          : 'แนบ ${files.length} ไฟล์',
                  style:
                      files.length == 1 ? const TextStyle(fontSize: 14) : null,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 10),
      if (files.isNotEmpty)
        InkWell(
          onTap: () {
            onChanged([]);
          },
          child: Icon(
            Icons.cancel,
            color: Theme.of(context).errorColor,
          ),
        ),
    ]);
  }
}

class AllFilesExpandPanel extends StatelessWidget {
  const AllFilesExpandPanel(
      {required this.prefixLength, required this.items, super.key});

  final List<String> items;
  final int prefixLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: ExpandablePanel(
        theme: const ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          iconPadding: EdgeInsets.symmetric(horizontal: 10),
        ),
        header: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.file_copy,
                  color: Colors.grey,
                ),
                spacing,
                Text('ทั้งหมด ${items.length} ไฟล์'),
              ],
            ),
          ),
        ),
        collapsed: Container(),
        expanded: Column(
          children: items
              .map(
                (e) => InkWell(
                  onTap: () => ServerData.downloadFile(e),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.download,
                          color: Theme.of(context).primaryColor,
                        ),
                        spacing,
                        Text(
                          e.substring(prefixLength),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class TableInputFields extends StatelessWidget {
  const TableInputFields(
      {super.key, required this.headers, required this.fields});

  final List<String> headers;
  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Theme.of(context).errorColor,
                ),
              ),
              errorStyle: const TextStyle(fontSize: 0.2),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent)),
            ),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: Colors.grey,
        ),
        columnWidths:
            List.filled(headers.length, const IntrinsicColumnWidth()).asMap(),
        children: [
          TableRow(
              children: headers
                  .map((e) => TableCell(
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: Text(
                              e,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ))
                  .toList()),
          TableRow(
              children: fields
                  .map((e) => TableCell(
                        child: SizedBox(
                          height: 32,
                          child: Center(child: e),
                        ),
                      ))
                  .toList()),
        ],
      ),
    );
  }
}
