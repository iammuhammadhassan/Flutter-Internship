import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/user_profile/data/repositories/user_repository.dart';
import 'features/user_profile/presentation/providers/user_profile_provider.dart';
import 'features/user_profile/presentation/screens/user_profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        home: const UserProfileScreen(),
      ),
    );
  }
}
