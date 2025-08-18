// lib/main.dart

import 'package:flutter/material.dart';                     // Importing necessary Flutter material design components.
import 'package:gemini001/screens/splash_screen.dart';      // Importing the new splash screen.
import 'package:firebase_core/firebase_core.dart';          // Importing Firebase Core for initialization.
import 'package:gemini001/firebase_options.dart';           // Importing our generated Firebase options file.

// The main function, which is the entry point of any Flutter application.
void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();                // Ensure that Flutter widgets are initialized before any Firebase operations.

  await Firebase.initializeApp(                             // Initialize Firebase with the default options for the current platform.
    options: DefaultFirebaseOptions.currentPlatform,        // This is a crucial step for using any Firebase service.
  );

  runApp(const MyApp());                                    // `runApp` takes a Widget and makes it the root of the widget tree.
}                                                           // Here, `MyApp` is our root widget.

                                                            // `MyApp` is a `StatelessWidget`.
                                                            // Stateless widgets are immutable, meaning their properties cannot change over time.
                                                            // They are used for parts of the UI that do not change based on user interaction or data.
                                                            // In our case, the top-level app configuration (like the title and theme) remains constant.
class MyApp extends StatelessWidget {
  
  const MyApp({super.key});                                 // Constructor for MyApp. `const` keyword indicates that this widget and its properties
                                                            // are immutable and can be created at compile time, leading to performance benefits.
  @override
  Widget build(BuildContext context) {                      // The `build` method describes the part of the user interface represented by this widget.
                                                            // It returns a `Widget` tree.
    return MaterialApp(                                     // `MaterialApp` is a convenience widget that wraps a number of widgets that are
                                                            // commonly required for material design applications.
                                                            // It provides the basic structure for a Material Design app.     
      title: 'Fuel Procurement App',                        // `title` is a short description of the app used by the device to identify the app.
                                                            // This is often seen in the task switcher on mobile devices.     
      theme: ThemeData(                                     // `theme` defines the visual properties of the Material Design widgets.
        primarySwatch: Colors.green,                      // We are now setting the primary color for the application to a shade of green.
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green),
        useMaterial3: true,
      ),
      
      home: const SplashScreen(),                           // `home` is the default route of the app. When the app starts, this widget is displayed.
                                                            // We now set our `SplashScreen` as the initial screen.     
      debugShowCheckedModeBanner: false,                    // removes the "DEBUG" banner from the top right corner of the app during development.
    );
  }
}
