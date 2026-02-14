// Generated Firebase configuration for supplier_app.
// Based on flutterfire configure output for project vietfuelprocapp.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'run flutterfire configure to set it up.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaLSoXSKiTQq-uKi30NS4Zq23UaIoPLHA',
    appId: '1:490924808031:android:69defbdeffc1f6e1cac8ea',
    messagingSenderId: '490924808031',
    projectId: 'vietfuelprocapp',
    storageBucket: 'vietfuelprocapp.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCgNNxTCWmAuygURSFYpOzbdz9ZfEOP-LI',
    authDomain: 'vietfuelprocapp.firebaseapp.com',
    appId: '1:490924808031:web:c3276a58bb7458decac8ea',
    messagingSenderId: '490924808031',
    projectId: 'vietfuelprocapp',
    storageBucket: 'vietfuelprocapp.firebasestorage.app',
  );
}
