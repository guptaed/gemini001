// lib/screens/login_screen.dart

import 'package:flutter/material.dart';                                           // Importing necessary Flutter material design components.
import 'package:gemini001/screens/home_screen.dart';                              // Importing our `HomeScreen` to navigate to it after successful login.
import 'package:gemini001/widgets/custom_text_field.dart';                        // Importing our custom `CustomTextField` for consistent input field styling.

class LoginScreen extends StatefulWidget {                                        // `LoginScreen` is a `StatefulWidget`.
                                                                                  // It needs to be stateful to manage the state of the text input fields and to display potential error messages.
  const LoginScreen({super.key});                                                 // Constructor for LoginScreen.
  @override
  State<LoginScreen> createState() => _LoginScreenState();                        // Creates the mutable state for this widget.
}

class _LoginScreenState extends State<LoginScreen> {                              // `_LoginScreenState` holds the mutable state for `LoginScreen`.
  
  final _formKey = GlobalKey<FormState>();                                        // `_formKey` is a GlobalKey that uniquely identifies the `Form` widget.
                                                                                  // It's used to access the `FormState`, which allows us to validate all the form fields at once.
  final TextEditingController _usernameController = TextEditingController();      // `TextEditingController`s for the username and password input fields.
  final TextEditingController _passwordController = TextEditingController();      // These allow us to read the text entered by the user.

  String? _errorMessage;                                                          // `_errorMessage` will store any error message to be displayed to the user.

  late final ScrollController _scrollController;                                  // We are creating a `ScrollController` to explicitly link it to both the
                                                                                  // `SingleChildScrollView` and the `Scrollbar`. This fixes the exception.
  @override
  void initState() {                                                              // `initState` is a lifecycle method called once when the `State` object is created.
    super.initState();    
    _scrollController = ScrollController();                                       // Initialize the `ScrollController` in `initState`.
  }

  void _login() {                                                                 // `_login` method: This function is called when the login button is pressed. It handles validation and "authentication".
    if (_formKey.currentState!.validate()) {                                      // Validate all fields in the form. If `validate()` returns true, all fields pass their validation rules.
                                                                                  // These are the validations done below in build -> CustomTextField -> validator.
                                                                                  
                                                                                  // After these validations, now we can write any additional validation code below.


      const String validUsername = 'q';                                           // For this skeleton, we're using hardcoded credentials.
      const String validPassword = 'q';                                           // In a real application, you would connect to an authentication service (like Firebase Authentication, your own backend, etc.)

      if (_usernameController.text == validUsername &&                            // Check if the entered username and password match the hardcoded values.
          _passwordController.text == validPassword) {                            // If credentials are valid, navigate to the `HomeScreen`.
        if (mounted) {                                                            // Check if the widget is still in the widget tree before navigating
          Navigator.pushReplacement(                                              // `Navigator.pushReplacement` is used to remove the login screen
            context,                                                              // from the navigation stack, so the user can't go back to it after logging in.
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {                                                                    // If credentials are invalid, update the error message and trigger a rebuild.    
        setState(() {                                                             // `setState` is called to update the UI with the new error message.                                                  
          _errorMessage = 'Invalid username or password. Please try again.';
        });
      }
    }
  }

  @override
  void dispose() {                                                                // `dispose` method: Called when this `State` object is removed from the tree permanently.
    _usernameController.dispose();                                                // It's important to dispose of `TextEditingController`s and `ScrollController`s to prevent memory leaks.
    _passwordController.dispose();
    _scrollController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {                                            // The `build` method describes the UI of the login screen.
    return Scaffold(                                                              // `Scaffold` provides the basic Material Design visual structure.  

      appBar: AppBar(                                                             // `appBar` for the login screen.
        title: const Text('Login'),
        backgroundColor: Theme.of(context).primaryColor,                          // Using `Theme.of(context).primaryColor`.
      ),
      
      body: Center(                                                               // `body` is the primary content of the scaffold.
        child: Scrollbar(                                                         // The `Scrollbar` is added here to fix the exception.
          controller: _scrollController,                                          // It uses the explicit `_scrollController`.
          child: SingleChildScrollView(                                           // `SingleChildScrollView` makes the content scrollable if it overflows,
            controller: _scrollController,                                        // which is good for forms on smaller screens or when the keyboard appears. It now also uses the `_scrollController`.           
            padding: const EdgeInsets.all(24.0),                                  // `padding` around the login form.
            child: ConstrainedBox(                                                // `ConstrainedBox` limits the maximum width of the login form to make it look good on larger desktop screens.
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(               
                key: _formKey,                                                    // Assign the `GlobalKey` to the `Form`.
                child: Column(                 
                  mainAxisAlignment: MainAxisAlignment.center,                    // `mainAxisAlignment.center` centers the children vertically within the column.                 
                  crossAxisAlignment: CrossAxisAlignment.stretch,                 // `crossAxisAlignment.stretch` makes children fill the available horizontal space.
                  children: <Widget>[                   
                    Icon(                                                         // App logo/icon for the login screen.
                      Icons.agriculture,  
                      size: 80,                     
                      color: Theme.of(context).primaryColor,                      // Using `Theme.of(context).primaryColor`.
                    ),

                    const SizedBox(height: 30),                                   // Vertical space.  

                    CustomTextField(                                              // `CustomTextField` for username input.
                      controller: _usernameController,
                      labelText: 'Username',
                      validator: (value) {
                        return value == null || value.isEmpty ? 'Please enter your username' : null;
                      },
                    ),

                    const SizedBox(height: 16),                                   // Vertical space.                   
                    
                    CustomTextField(                                              // `CustomTextField` for password input.
                      controller: _passwordController,
                      labelText: 'Password',                    
                      obscureText: true,                                          // `obscureText: true` hides the typed characters for password security.
                      validator: (value) {
                        return value == null || value.isEmpty ? 'Please enter your password' : null;
                      },
                    ),
                    
                    const SizedBox(height: 24),                                   // Vertical space.
                    
                    if (_errorMessage != null)                                    // Display error message if `_errorMessage` is not null.
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,                                         // `!` asserts that _errorMessage is not null.
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    ElevatedButton(                                               // `ElevatedButton` for login action.
                      onPressed: _login,                                          // Calls our `_login` method.
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),                      
                        backgroundColor: Theme.of(context).primaryColor,          // Using `Theme.of(context).primaryColor`.                       
                        foregroundColor: Colors.white,                          // `foregroundColor` sets the text color of the button.
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),                 // Rounded corners for the button.
                        ),
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
