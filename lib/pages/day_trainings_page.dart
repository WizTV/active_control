import 'package:flutter/material.dart';
import '../services/training_service.dart';
import '../services/firestore_training_service.dart';
import 'edit_training_page.dart';

class DayTrainingsPage extends StatelessWidget {
  final DateTime selectedDate;

  const DayTrainingsPage({super.key, required this.selectedDate});

  List<Training> _getTrainingsForDay(List<Training> allTrainings) {
    return allTrainings.where((training) {
      return training.trainingDate.year == selectedDate.year &&
          training.trainingDate.month == selectedDate.month &&
          training.trainingDate.day == selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trainings for this day',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder<List<Training>>(
                valueListenable: TrainingService.instance.trainings,
                builder: (context, list, _) {
                  final trainingsForDay = _getTrainingsForDay(list);

                  if (trainingsForDay.isEmpty) {
                    return Center(
                      child: Text(
                        'No trainings on this day',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: trainingsForDay.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final t = trainingsForDay[index];
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
                                    try {
                                      await FirestoreTrainingService().deleteTraining(t.id);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error deleting training: $e')),
                                        );
                                      }
                                    }
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
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTrainingPage(initialDate: selectedDate),
            ),
          );
        },
      ),
    );
  }
}
