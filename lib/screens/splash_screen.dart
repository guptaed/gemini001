// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';                         // Importing necessary Flutter material design components.
import 'dart:async';                                            // Importing Dart's `async` library for `Future.delayed`.
import 'package:gemini001/screens/login_screen.dart';           // Importing the `LoginScreen` to navigate to it after the splash.
                                                             
class SplashScreen extends StatefulWidget {                     // `SplashScreen` is a `StatefulWidget`.
                                                                // It needs to be stateful because it manages a timer (`Future.delayed`)
                                                                // and performs a navigation action after a certain duration.
  const SplashScreen({super.key});                              // Constructor for SplashScreen.
  @override
  State<SplashScreen> createState() => _SplashScreenState();    // Creates the mutable (=changing) state for this widget.
}                                                               // State Object: holds the widget's "state" — the data that can change and cause the widget to rebuild.
                                                                // createState(): This is the method that a StatefulWidget uses to create and return its associated State object.
                                                                // _SplashScreenState class holds all the dynamic parts, like the timer that runs on the splash screen and navigates to the next page. 

class _SplashScreenState extends State<SplashScreen> {          // `_SplashScreenState` holds the mutable (=changing) state for `SplashScreen`.
                                                                                                                                
  @override                                                     // `initState` is a lifecycle method called once when the `State` object is created.
  void initState() {                                            // It's the ideal place to start our timer for the splash screen.
    super.initState();                                          
                                                                
    Future.delayed(const Duration(seconds: 3), () {             // `Future.delayed` creates a future that completes after 3 seconds. After 3 seconds, we navigate to the `LoginScreen`.                                                                                                                      
      if (mounted) {                                            // Check if the widget is still in the widget tree before navigating
        Navigator.pushReplacement(                              // `pushReplacement` removes the current route (SplashScreen) from the stack and replaces it with the new route (LoginScreen).
                                                                //  This means the user cannot go back to the splash screen using the back button.                                                                 
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()), // - `MaterialPageRoute` is a modal route that replaces the entire screen with a platform-adaptive transition.
        );                                                              // A modal route is a type of screen or page in that takes over the entire screen and prevents you
      }                                                                 // from interacting with any of the content behind it.   
    });
  }
  
  @override
  Widget build(BuildContext context) {                            // The `build` method describes the UI of the splash screen.
    return Scaffold(                                              // `Scaffold` provides the basic Material Design visual structure.
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(                                               // `body` is the primary content of the scaffold.
        child: Column(                                            // `Column` arranges its children vertically.
          mainAxisAlignment: MainAxisAlignment.center,            // `mainAxisAlignment.center` centers the children vertically.
          children: <Widget>[
            
            Icon(                                                 // `Icon` for a visual element. List of all available icons here: https://material.io/resources/icons
              Icons.agriculture,                                  // A relevant icon for a farmer app.
              size: 100,                                          // Large size for prominence.
              color: Colors.white,                              // White color for contrast.
            ),
            
            const SizedBox(height: 20),                           // Adds vertical space between icon and text.
            
            const Text(                                           // `Text` for the app title.
              'Fuel Procurement System',
              style: TextStyle(
                color: Colors.white,                            // White text for contrast.
                fontSize: 32,                                     // Large font size.
                fontWeight: FontWeight.bold,                      // Bold text.
              ),
            ),
            
            const SizedBox(height: 30),                           // Adds more vertical space.
            
            const CircularProgressIndicator(                      // `CircularProgressIndicator` to show that something is loading.
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // White loading indicator.
            ),
            //const LinearProgressIndicator(
            //  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            //),
          ],
        ),
      ),
    );
  }
}
