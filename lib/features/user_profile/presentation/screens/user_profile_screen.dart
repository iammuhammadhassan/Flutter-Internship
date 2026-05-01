import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../providers/user_profile_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    this.firebaseSetupMessage,
    this.showLogout = true,
  });

  final String? firebaseSetupMessage;
  final bool showLogout;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const String _firebaseBannerTitle =
      'Firebase setup incomplete - API demo mode';
  static const String _firebaseDetails =
      'Complete Firebase setup for this project:\n\n'
      '1. Install Firebase CLI and login\n'
      '2. Run flutterfire configure with your project id\n'
      '3. Ensure lib/firebase_options.dart is generated\n'
      '4. Rebuild the app';

  String _buildFirebaseDetailsText() {
    if (widget.firebaseSetupMessage == null) {
      return '';
    }

    return _firebaseDetails;
  }

  Future<void> _showFirebaseDetailsDialog() async {
    final details = _buildFirebaseDetailsText();
    if (details.isEmpty) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Firebase Setup Details'),
          content: Text(details),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: widget.showLogout
            ? [
                IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                ),
              ]
            : null,
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await provider.fetchUsers();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.users.isEmpty) {
            return const Center(child: Text('No user data available.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchUsers();
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: provider.users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final UserModel user = provider.users[index];

                return Card(
                  child: ListTile(
                    title: Text('${user.name} (#${user.id})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text('Username: ${user.username}'),
                        Text('Email: ${user.email}'),
                        Text('Phone: ${user.phone}'),
                        Text('Website: ${user.website}'),
                      ],
                    ),
                    leading: CircleAvatar(
                      child: Text(user.name.isNotEmpty ? user.name[0] : '?'),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: widget.firebaseSetupMessage == null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                color: Colors.amber.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.amber.shade900,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        _firebaseBannerTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    if (_buildFirebaseDetailsText().isNotEmpty)
                      TextButton(
                        onPressed: _showFirebaseDetailsDialog,
                        child: const Text('Details'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
