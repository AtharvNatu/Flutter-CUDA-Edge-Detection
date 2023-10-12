import 'package:flutter/material.dart';
import "dart:ffi";
import 'package:ffi/ffi.dart';
import 'package:file_picker/file_picker.dart';
import "dart:ui" as ui;

// Typedefs
typedef GetNativeString = Pointer<Utf8> Function();
typedef SetNativeString = Void Function(Pointer<Utf8> str);
typedef SetDartString = void Function(Pointer<Utf8> str);
typedef FreeNativeString = Void Function(Pointer<Utf8> str);
typedef FreeDartString = void Function(Pointer<Utf8> str);

late void Function() init, destroy;
late void Function(Pointer<Utf8>) setString, freeString;
late Pointer<Utf8> Function() getString;
late DynamicLibrary dynamicLib;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variable Declarations
  String selectedFileName = "";

  // Code
  void openFilePicker() async {
    FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        dialogTitle: 'Select Input Image',
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'bmp', 'jpeg']);

    if (filePickerResult != null) {
      setState(() {
        selectedFileName = filePickerResult.files.first.path.toString();
      });
    }

    runNativeCode();
  }

  void runNativeCode() {
    // Native Calls
    init();

    final str = selectedFileName.toNativeUtf8();
    setString(str);
    calloc.free(str);

    final cppString = getString();

    print(cppString.toDartString());

    freeString(cppString);

    destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(85.0),
      child: Column(
        children: [
          const Image(image: AssetImage("images/image-processing.png")),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                fixedSize: const ui.Size(220, 60),
                textStyle: const TextStyle(
                    fontFamily: "Cascadia Code",
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            label: const Text("Select Image"),
            icon: Image.asset("images/search.png"),
            onPressed: () {
              openFilePicker();
            },
          ),
        ],
      ),
    );
  }
}
