import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cultainer/app/app.dart';
import 'package:cultainer/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  final stopwatch = Stopwatch()..start();

  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (non-fatal if missing)
  try {
    await dotenv.load();
  } catch (_) {
    // .env file may not exist in all environments
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore offline persistence with unlimited cache
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  stopwatch.stop();
  if (kDebugMode) {
    developer.log(
      'App initialization: ${stopwatch.elapsedMilliseconds}ms',
      name: 'Startup',
    );
  }

  runApp(
    const ProviderScope(
      child: CultainerApp(),
    ),
  );
}
