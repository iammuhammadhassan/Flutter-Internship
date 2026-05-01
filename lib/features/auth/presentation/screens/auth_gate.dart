import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../user_profile/presentation/screens/user_profile_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const UserProfileScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
