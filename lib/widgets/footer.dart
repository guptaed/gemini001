// lib/widgets/footer.dart

import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      color: const Color.fromARGB(255, 218, 217, 217),
      child: const Center(
        child: Text(
          '© 2025 erex Co. Ltd. All rights reserved. | Contact: it.solutions@erex.co.jp | v3.1.4, September 2025.',
          style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 41, 40, 40), decoration: TextDecoration.none),
        ),
      ),
    );
  }
}
