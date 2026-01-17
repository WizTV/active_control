import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/app_drawer.dart';
import '../services/training_service.dart';
import '../services/firestore_training_service.dart';
import 'edit_training_page.dart';
import 'day_trainings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedDate = DateTime.now();
  }

  List<Training> _getLastSevenTrainings(List<Training> allTrainings) {
    // Filter out future trainings (only show trainings that have already happened or are today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final pastTrainings = allTrainings.where((training) {
      final trainingDay = DateTime(training.trainingDate.year, training.trainingDate.month, training.trainingDate.day);
      return trainingDay.isBefore(today) || trainingDay.isAtSameMomentAs(today);
    }).toList();
    
    // Sort by date descending (most recent first)
    final sorted = pastTrainings..sort((a, b) => b.trainingDate.compareTo(a.trainingDate));
    // Return only the last 7
    return sorted.take(7).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: theme.primaryColor,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Calendar widget
            Card(
              color: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2100),
                  focusedDay: _focusedDate,
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    // Normalize dates to midnight to avoid time component issues
                    final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                    final normalizedFocusedDay = DateTime(focusedDay.year, focusedDay.month, focusedDay.day);
                    
                    setState(() {
                      _selectedDate = normalizedSelectedDay;
                      _focusedDate = normalizedFocusedDay;
                    });
                    // Navigate to day trainings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayTrainingsPage(selectedDate: normalizedSelectedDay),
                      ),
                    );
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    todayTextStyle: const TextStyle(color: Colors.white),
                    selectedTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: const TextStyle(color: Colors.white70),
                    outsideTextStyle: const TextStyle(color: Colors.white30),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white70),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white70),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white70),
                    weekendStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Recent trainings (Last 7)',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<Training>>(
              valueListenable: TrainingService.instance.trainings,
              builder: (context, list, _) {
                final lastSeven = _getLastSevenTrainings(list);

                if (lastSeven.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text('No trainings yet', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final t in lastSeven)
                      Card(
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
                          title: Text('${t.title} • ${t.trainingDate.day}/${t.trainingDate.month}/${t.trainingDate.year}', style: const TextStyle(color: Colors.white)),
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
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(height: 80),
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
