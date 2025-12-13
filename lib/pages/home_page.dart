import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: theme.primaryColor,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your recent trainings',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Card(
                    color: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.fitness_center, color: theme.primaryColor),
                      ),
                      title: Text('Training ${index + 1}', style: const TextStyle(color: Colors.white)),
                      subtitle: const Text('Easy workout • 30 min', style: TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                        icon: Icon(Icons.chevron_right, color: Colors.white70),
                        onPressed: () => Navigator.pushNamed(context, '/edit-training'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.secondary,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/edit-training');
        },
      ),
    );
  }
}
