import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_text_field.dart';
import '../services/training_service.dart';

class EditTrainingPage extends StatefulWidget {
  final int? trainingId;
  const EditTrainingPage({super.key, this.trainingId});

  @override
  State<EditTrainingPage> createState() => _EditTrainingPageState();
}

class _EditTrainingPageState extends State<EditTrainingPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  bool _isNew = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final id = widget.trainingId;
    if (id != null) {
      final t = TrainingService.instance.getById(id);
      if (t != null) {
        _isNew = false;
        _titleController.text = t.title;
        _descriptionController.text = t.description;
        _durationController.text = t.durationMinutes.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Training'),
        backgroundColor: theme.primaryColor,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Training details',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: 'Title',
              icon: Icons.title,
              controller: _titleController,
            ),
            CustomTextField(
              hintText: 'Description',
              icon: Icons.description,
              controller: _descriptionController,
            ),
            CustomTextField(
              hintText: 'Duration (min)',
              icon: Icons.timer,
              keyboardType: TextInputType.number,
              controller: _durationController,
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  final title = _titleController.text.trim();
                  final description = _descriptionController.text.trim();
                  final duration = int.tryParse(_durationController.text.trim()) ?? 0;
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
                    return;
                  }
                  if (_isNew) {
                    final newId = TrainingService.instance.addTraining(title: title, description: description, durationMinutes: duration);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Training created')));
                    // Open the same page for the newly created training so exercises can be added
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EditTrainingPage(trainingId: newId)),
                    );
                    return;
                  } else {
                    TrainingService.instance.updateTraining(widget.trainingId!, title: title, description: description, durationMinutes: duration);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Training saved')));
                    // stay on the page so user can manage exercises
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAAC2FF), // requested save color
                  foregroundColor: const Color(0xFF213466), // darker text for contrast
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF213466))),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 20),
            Text('Exercises', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_isNew)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Save the training first to add exercises.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              )
            else
              ValueListenableBuilder<List<Training>>(
                valueListenable: TrainingService.instance.trainings,
                builder: (context, list, _) {
                  final t = TrainingService.instance.getById(widget.trainingId!);
                  final exercises = t?.exercises ?? [];
                  return Column(
                    children: [
                      for (final ex in exercises)
                        Card(
                          color: Colors.white10,
                          child: ListTile(
                            title: Text(ex.name, style: const TextStyle(color: Colors.white)),
                            subtitle: Text('Sets: ${ex.sets} • Reps: ${ex.reps} • Weight: ${ex.weight}', style: const TextStyle(color: Colors.white70)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white70),
                                  onPressed: () => _showExerciseDialog(context, trainingId: widget.trainingId!, exercise: ex),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete exercise?'),
                                        content: const Text('Are you sure you want to delete this exercise?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      TrainingService.instance.deleteExercise(widget.trainingId!, ex.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showExerciseDialog(context, trainingId: widget.trainingId!),
                          icon: const Icon(Icons.add),
                          label: const Text('Add exercise'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExerciseDialog(BuildContext context, {required int trainingId, Exercise? exercise}) async {
    final nameCtrl = TextEditingController(text: exercise?.name ?? '');
    final setsCtrl = TextEditingController(text: exercise != null ? exercise.sets.toString() : '3');
    final repsCtrl = TextEditingController(text: exercise != null ? exercise.reps.toString() : '8');
    final weightCtrl = TextEditingController(text: exercise != null ? exercise.weight.toString() : '0');

    final isEdit = exercise != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit exercise' : 'Add exercise'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: setsCtrl, decoration: const InputDecoration(labelText: 'Sets'), keyboardType: TextInputType.number),
              TextField(controller: repsCtrl, decoration: const InputDecoration(labelText: 'Reps'), keyboardType: TextInputType.number),
              TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Weight'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final sets = int.tryParse(setsCtrl.text.trim()) ?? 0;
              final reps = int.tryParse(repsCtrl.text.trim()) ?? 0;
              final weight = double.tryParse(weightCtrl.text.trim()) ?? 0.0;
              if (name.isEmpty) return; // keep dialog open
              if (isEdit) {
                TrainingService.instance.updateExercise(trainingId, exercise.id, name: name, sets: sets, reps: reps, weight: weight);
              } else {
                TrainingService.instance.addExercise(trainingId, name: name, sets: sets, reps: reps, weight: weight);
              }
              Navigator.pop(context, true);
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      // optional: show feedback
    }
  }
}
