import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:woot/utils/validator.dart';
import 'package:woot/widgets/misc_widgets.dart';

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

class TextInputField extends StatelessWidget {
  const TextInputField({
    this.label,
    this.initialValue,
    required this.width,
    required this.onSaved,
    this.validator,
    this.isRequire = false,
    super.key,
  });

  final String? initialValue;
  final String? label;
  final bool isRequire;
  final double width;

  final void Function(String? value) onSaved;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(labelText: label),
        onSaved: onSaved,
        validator: isRequire ? Validator.notEmpty(validator) : validator,
        //inputFormatters: [],
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
      child: Row(
        children: [
          InkWell(
            onTap: () => Clipboard.setData(ClipboardData(text: value)),
            child: const Icon(Icons.copy),
          ),
          spacing,
          SelectableText(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class FieldBorder extends StatelessWidget {
  const FieldBorder({required this.child, required this.width, super.key});

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
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

class FileUploader extends StatefulWidget {
  const FileUploader({required this.onChanged, super.key});

  final void Function(List<PlatformFile>? value) onChanged;

  @override
  State<FileUploader> createState() => _FileUploaderState();
}

class _FileUploaderState extends State<FileUploader> {
  List<PlatformFile>? files;

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
          setState(() {
            files = result.files;
          });
          widget.onChanged(files!);
        },
        child: FieldBorder(
          width: 250,
          child: Row(
            children: [
              Icon(
                Icons.file_upload,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  files == null
                      ? 'อัพโหลดไฟล์'
                      : files!.length == 1
                          ? files!.first.name
                          : 'แนบ ${files!.length} ไฟล์',
                  style: files == null || files!.length > 1
                      ? null
                      : const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 10),
      if (files != null)
        InkWell(
          onTap: () {
            setState(() {
              files = null;
            });
            widget.onChanged(null);
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
      child: ExpansionTile(
        title: Text('ทั้งหมด ${items.length} ไฟล์'),
        leading: Icon(
          Icons.file_copy,
          color: Theme.of(context).primaryColor,
        ),
        children: items
            .map(
              (e) => ListTile(
                title: Text(e.substring(prefixLength)),
                leading: InkWell(
                  onTap: () {},
                  child: Icon(
                    Icons.download,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                trailing: InkWell(
                  onTap: () {},
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class TableInputFields extends StatelessWidget {
  const TableInputFields(
      {super.key, required this.headers, required this.fields});

  final List<String> headers;
  final List<TextFormField> fields;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              errorStyle: const TextStyle(fontSize: 0.2),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent)),
              border: const OutlineInputBorder(
                borderSide: BorderSide(strokeAlign: StrokeAlign.outside),
              ),
            ),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: Colors.grey,
        ),
        columnWidths:
            List.filled(headers.length, const FixedColumnWidth(150)).asMap(),
        children: [
          TableRow(
              children: headers
                  .map((e) => TableCell(
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Center(child: Text(e)),
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
