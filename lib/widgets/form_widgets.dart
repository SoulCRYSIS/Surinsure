import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
    this.state,
    required this.width,
    required this.items,
    required this.onChanged,
    super.key,
  }) : assert(hint == null || label == null);
  final GlobalKey<FormFieldState>? state;
  final List<String> items;
  final String? hint;
  final String? label;
  final String? value;
  final double width;
  final void Function(String? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        key: state,
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
        validator: (value) {
          if (value == null) {
            return 'จำเป็น';
          }
          return null;
        },
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

class BlockBorder extends StatelessWidget {
  const BlockBorder({required this.child, this.width = 840, super.key});

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      margin: const EdgeInsets.all(10),
      width: width,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: child,
    );
  }
}

class BidirectionScroll extends StatelessWidget {
  const BidirectionScroll({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: child,
      ),
    );
  }
}

const spacing = SizedBox(width: 20);
const spacingVertical = SizedBox(height: 20);
