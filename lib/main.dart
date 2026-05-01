import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'features/user_profile/data/repositories/user_repository.dart';
import 'features/user_profile/presentation/screens/user_profile_screen.dart';
import 'features/user_profile/presentation/providers/user_profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<void> _firebaseInitialization = _initializeFirebase();
  static const String _firebaseSetupHint =
      'Firebase setup is incomplete. Run "flutterfire configure", add firebase_options.dart, and include platform config files.';

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } on PlatformException catch (error) {
      throw FirebaseInitializationException(
        _readableFirebaseInitError(error.message ?? error.code),
      );
    } on Exception catch (error) {
      throw FirebaseInitializationException(_readableFirebaseInitError(error));
    }
  }

  String _readableFirebaseInitError(Object? error) {
    final raw = (error?.toString() ?? '').trim();

    if (raw.isEmpty || raw == 'Exception') {
      return _firebaseSetupHint;
    }

    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: 'Internship Task',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProfileProvider>(
                create: (_) => UserProfileProvider(UserRepository()),
              ),
            ],
            child: MaterialApp(
              title: 'Firebase Setup Required',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              home: UserProfileScreen(
                firebaseSetupMessage: _readableFirebaseInitError(snapshot.error),
                showLogout: false,
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(AuthRepository(), UserRepository()),
            ),
            ChangeNotifierProvider<UserProfileProvider>(
              create: (_) => UserProfileProvider(UserRepository()),
            ),
          ],
          child: MaterialApp(
            title: 'Internship Task',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: const AuthGate(),
          ),
        );
      },
    );
  }
}

class FirebaseInitializationException implements Exception {
  FirebaseInitializationException(this.message);

  final String message;

  @override
  String toString() => message;
}

