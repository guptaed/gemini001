import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';

class Header extends StatelessWidget {
  final String title;
  final String userName;

  const Header({
    super.key,
    required this.title,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.teal[700],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.agriculture,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              const Text(
                'Fuel Procurement System', // Application name added here
                style: TextStyle(
                  color: Color.fromARGB(255, 190, 189, 189),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(
                  width: 20), // Spacing between app name and page title
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Welcome, $userName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () => Provider.of<AuthProvider>(context, listen: false)
                    .signOut(context),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
