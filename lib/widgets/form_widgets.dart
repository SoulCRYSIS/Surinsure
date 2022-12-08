import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
    super.key,
  });

  final String? initialValue;
  final String? label;
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
        validator: validator,
      ),
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
    required this.width,
    required this.items,
    required this.onChanged,
    super.key,
  });
  final List<String> items;
  final String? hint;
  final String? label;
  final String? value;
  final double width;
  final bool isSearchable;
  final void Function(String? value) onChanged;
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
                  onChanged(textEditingController.text);
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
                  onChanged(suggestion);
                  textEditingController.text = suggestion;
                },
                noItemsFoundBuilder: (context) => const ListTile(
                  title: Text(
                    'ไม่พบรายการ',
                    textAlign: TextAlign.center,
                  ),
                ),
                autoFlipDirection: true,
                validator: validator,
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
              onChanged: onChanged,
              validator: validator,
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
        child: Container(
          width: 200,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
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
                      ? 'upload'
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
            color: Colors.red[400],
          ),
        ),
    ]);
  }
}
