import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UploadTask? task;
  File? file;

  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : 'No file selected';
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(onPressed: selectFile, child: const Text("Select file")),
        const SizedBox(
          height: 20,
        ),
        Text(
          fileName,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(onPressed: (){}, child: const Text("Upload file"))
      ]),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf']);
    if (result == null) return;
    Uint8List? fileBytes = result.files.first.bytes;
    String fileName = result.files.first.name;

    // Upload file
    await FirebaseStorage.instance.ref('uploads/$fileName').putData(fileBytes!);
    // setState(() => file = File(path as String));
  }

  // Future uploadFile() async {
  //   if (file == null) return;

  //   final fileName = basename(file!.path);
  //   final destination = 'files/$fileName';
  //   FirebaseApi.uploadFile(destination, file!);
  // }
  // void openPDF(BuildContext context, File file) => Navigator.of(context).push(
  //       MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
  //     );
}
