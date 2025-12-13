import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../services/training_service.dart';
import 'edit_training_page.dart';

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
              child: ValueListenableBuilder<List<Training>>(
                valueListenable: TrainingService.instance.trainings,
                builder: (context, list, _) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text('No trainings yet', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final t = list[index];
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
                          title: Text(t.title, style: const TextStyle(color: Colors.white)),
                          subtitle: Text('${t.description} • ${t.durationMinutes} min', style: const TextStyle(color: Colors.white70)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.chevron_right, color: Colors.white70),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EditTrainingPage(trainingId: t.id)),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              // Delete button (reddish)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete training?'),
                                      content: const Text('Are you sure you want to delete this training? This action cannot be undone.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    TrainingService.instance.deleteTraining(t.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
