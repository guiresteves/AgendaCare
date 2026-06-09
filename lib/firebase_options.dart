import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Este projeto foi configurado apenas para Android e iOS.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOPHseHc3_d4Q1MN3H0FViLRGl9J5NpvM',
    appId: '1:47118712381:android:4637b8b2ba432412407454',
    messagingSenderId: '47118712381',
    projectId: 'agendacare-2fbf7',
    storageBucket: 'agendacare-2fbf7.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD-43mzbfkQhNcw0crXTSvA3LF_Ecr7Sp0',
    appId: '1:47118712381:ios:1322bedc25433bd2407454',
    messagingSenderId: '47118712381',
    projectId: 'agendacare-2fbf7',
    storageBucket: 'agendacare-2fbf7.firebasestorage.app',
    androidClientId: '47118712381-tffffosgj0njo0il6eluu2iv1i4ong6p.apps.googleusercontent.com',
    iosClientId: '47118712381-sn2u05gr2kksfi65077f7e81bc1lh4g3.apps.googleusercontent.com',
    iosBundleId: 'com.example.agendacare',
  );
}
