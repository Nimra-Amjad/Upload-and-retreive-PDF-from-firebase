import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_practice/viewpdf.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "",
          appId: "",
          messagingSenderId: "",
          projectId: "flutter-firebase-practic-f9b06",
          storageBucket: "flutter-firebase-practic-f9b06.appspot.com"));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String url = "";
  int? number;

  uploadDataToFirebase() async {
    //generate random number
    number = Random().nextInt(10);

    //pick pdf file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf']);
    Uint8List? filebytes = result!.files.first.bytes;
    // File pick = File(result!.files.single.path.toString());
    // var file = pick.readAsBytesSync();
    // String name = DateTime.now().microsecondsSinceEpoch.toString();
    String name = result.files.first.name;

    //uploading file to firebase
    var pdfFile = FirebaseStorage.instance.ref().child(name).child("/.pdf");
    UploadTask task = pdfFile.putData(filebytes!);
    TaskSnapshot snapshot = await task;
    url = await snapshot.ref.getDownloadURL();
    print("hello");

    //upload url to cloud firebase
    await FirebaseFirestore.instance
        .collection("file")
        .doc()
        .set({'fileUrl': url, 'num': "Book#" + number.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("PDF"),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("file").snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, i) {
                      QueryDocumentSnapshot x = snapshot.data!.docs[i];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewPDF(url: x['fileUrl'])));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Text(x['num']),
                        ),
                      );
                    });
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: uploadDataToFirebase,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const HomePage(),
//     );
//   }
// }
