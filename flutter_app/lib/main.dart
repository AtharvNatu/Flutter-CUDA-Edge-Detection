import "package:flutter/material.dart";
import "package:window_manager/window_manager.dart";
import "dart:ffi";
import "package:path/path.dart" as path;
import "dart:io";
import "dart:ui" as ui;
import "home.dart";

const appName = "Edge Detection Using CUDA";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WindowOptions windowOptions = const WindowOptions(
      size: ui.Size(1000, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      fullScreen: true,
      windowButtonVisibility: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Default Linux
    var libraryPath =
        path.join(Directory.current.path, "ffi_lib", "libEdgeDetection.so");
    if (Platform.isWindows) {
      libraryPath =
          path.join(Directory.current.path, "ffi_lib", "EdgeDetection.dll");
    }

    dynamicLib = DynamicLibrary.open(libraryPath);

    // Edge Detection Native Functions
    sobelCV =
        dynamicLib.lookupFunction<DartFunction, NativeFunction>('sobelCV');
    sobelCUDA =
        dynamicLib.lookupFunction<DartFunction, NativeFunction>('sobelCUDA');
    cannyCV =
        dynamicLib.lookupFunction<DartFunction, NativeFunction>('cannyCV');
    cannyCUDA =
        dynamicLib.lookupFunction<DartFunction, NativeFunction>('cannyCUDA');

    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
    return MaterialApp(
        title: appName,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 118, 185, 0),
            title: const Text(appName),
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
          body: const HomeScreen(),
          // body: const ResultsScreen(),
        ));
  }
}
