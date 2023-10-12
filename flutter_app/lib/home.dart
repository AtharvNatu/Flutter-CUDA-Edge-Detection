import "package:flutter/material.dart";
import "dart:ffi";
import "package:ffi/ffi.dart";
import "package:file_picker/file_picker.dart";
import "dart:ui" as ui;
import "results.dart";

// Typedefs
typedef DartFunction = Double Function(Pointer<Utf8> str);
typedef NativeFunction = double Function(Pointer<Utf8> str);

late double Function(Pointer<Utf8>) sobelCV, sobelCUDA, cannyCV, cannyCUDA;
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

      runEdgeDetection();
    }
  }

  void runEdgeDetection() {
    final imageFile = selectedFileName.toNativeUtf8();

    double time1 = sobelCV(imageFile);
    double time2 = sobelCUDA(imageFile);
    double time3 = cannyCV(imageFile);
    double time4 = cannyCUDA(imageFile);

    print("Sobel OpenCV : $time1");
    print("Sobel CUDA : $time2");
    print("Canny OpenCV : $time3");
    print("Canny CUDA : $time4");

    calloc.free(imageFile);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Results()),
    );
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
