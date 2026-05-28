// App entrypoint and storage initialization.
import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/app.dart';
import 'package:personal_finance_tracker/services/hive_service.dart';

Future<void> main() async {
  // Ensure Flutter bindings are ready before async setup.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize local storage and adapters.
  await HiveService.init();
  // Launch the application.
  runApp(const App());
}
