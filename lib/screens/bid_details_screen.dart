// THIS IS A DUMMY FILE FOR BID DETAILS SCREEN
// TO BE IMPLEMENTED LATER

import 'package:flutter/material.dart';

class BidDetailsScreen extends StatelessWidget {
  final String bidId;
  final String stage;

  const BidDetailsScreen({super.key, required this.bidId, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bid Details - $bidId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Placeholder for Bid Details Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Bid ID: $bidId\nStage: $stage',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
