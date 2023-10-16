import "package:flutter/material.dart";
import "dart:ffi";
import "package:ffi/ffi.dart";
import "package:filesystem_picker/filesystem_picker.dart";
import "dart:io";
import "dart:ui" as ui;
import "results.dart";

// Typedefs
typedef DartFunction = Double Function(
    Pointer<Utf8> inputImage, Pointer<Utf8> outputPath);
typedef NativeFunction = double Function(
    Pointer<Utf8> inputImage, Pointer<Utf8> outputPath);

late double Function(Pointer<Utf8>, Pointer<Utf8>) sobelCV,
    sobelCUDA,
    cannyCV,
    cannyCUDA;
late DynamicLibrary dynamicLib;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Code
  Future<void> selectDirectory(BuildContext context) async {
    String? path = await FilesystemPicker.open(
      title: "Select Output Folder",
      context: context,
      rootDirectory: rootPath!,
      fsType: FilesystemType.folder,
      pickText: "Select Current Folder",
      folderIconColor: Colors.teal,
    );
    if (path != null) {
      setState(() {
        dirPath = path;
        sobelCVPath = "$dirPath/Sobel_OpenCV_$imageName";
        sobelCUDAPath = "$dirPath/Sobel_CUDA_$imageName";
        cannyCVPath = "$dirPath/Canny_OpenCV_$imageName";
        cannyCUDAPath = "$dirPath/Canny_CUDA_$imageName";
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoadingScreen()),
      );
    }
  }

  Future<void> selectImage(BuildContext context) async {
    String? path = await FilesystemPicker.open(
        title: "Select Input Image",
        context: context,
        rootDirectory: rootPath!,
        fsType: FilesystemType.file,
        allowedExtensions: ['.jpg', '.png', '.bmp', '.jpeg'],
        pickText: "Select Current Image",
        folderIconColor: Colors.teal,
        fileTileSelectMode: FileTileSelectMode.wholeTile);

    if (path != null) {
      setState(() {
        selectedFileName = path;
        imageName = path.split('/').last;
      });

      selectDirectory(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(100.0),
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
              selectImage(context);
            },
          ),
        ],
      ),
    );
  }
}

class Results extends StatelessWidget {
  const Results({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ResultsScreen());
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      runEdgeDetection();
    });
  }

  // Code
  void runEdgeDetection() {
    final imageFile = selectedFileName?.toNativeUtf8();
    final outputPath = dirPath.toString().toNativeUtf8();

    sobelCVTime =
        double.parse(sobelCV(imageFile!, outputPath).toStringAsFixed(2));
    sobelCUDATime =
        double.parse(sobelCUDA(imageFile, outputPath).toStringAsFixed(2));
    cannyCVTime =
        double.parse(cannyCV(imageFile, outputPath).toStringAsFixed(2));
    cannyCUDATime =
        double.parse(cannyCUDA(imageFile, outputPath).toStringAsFixed(2));

    calloc.free(imageFile);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Results()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 118, 185, 0),
        title: const Text("Results"),
        actions: <Widget>[
          TextButton(
            style: style,
            onPressed: () {
              exit(0);
            },
            child: const Text("Exit"),
          ),
        ],
      ),
      body: const Center(child: CircularProgressIndicator()),
    ));
  }
}
