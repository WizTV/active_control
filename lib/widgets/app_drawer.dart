import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../pages/register_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().getCurrentUser();
    String firstName = 'User';
    String? email;
    if (user != null) {
      email = user.email;
      final displayName = user.displayName ?? '';
      if (displayName.trim().isNotEmpty) {
        firstName = displayName.trim().split(' ').first;
      } else if (email != null && email.isNotEmpty) {
        firstName = email.split('@').first;
      }
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(firstName),
              accountEmail: Text(email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color.fromRGBO(255, 255, 255, 0.9),
                child: const Icon(Icons.fitness_center, color: Colors.blue),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit training'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/edit-training');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final auth = AuthService();
                final navigator = Navigator.of(context);
                try {
                  await auth.logout();
                } catch (_) {}
                navigator.popUntil((route) => route.isFirst);
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
