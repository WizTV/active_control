import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_text_field.dart';
import '../services/training_service.dart';
import '../services/firestore_training_service.dart';

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
  final FirestoreTrainingService _firestoreService = FirestoreTrainingService();

  bool _isNew = true;
  bool _isEditMode = false;
  final List<Map<String, dynamic>> _pendingExercises = [];
  final Set<String> _completedExercises = {};

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
        // Load completed exercises
        for (final ex in t.exercises) {
          if (ex.completed) {
            _completedExercises.add(ex.id.toString());
          }
        }
      }
    } else {
      // Start in edit mode for new trainings
      _isEditMode = true;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Training details',
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      _isEditMode ? 'Edit' : 'View',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isEditMode,
                      onChanged: (value) {
                        setState(() {
                          _isEditMode = value;
                        });
                      },
                      activeThumbColor: Colors.blue,
                      inactiveThumbColor: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isEditMode) ...[
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
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title: ${_titleController.text}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (_descriptionController.text.isNotEmpty) ...[
                      Text('Description: ${_descriptionController.text}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                    ],
                    Text('Duration: ${_durationController.text} min', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text('Exercises', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ValueListenableBuilder<List<Training>>(
              valueListenable: TrainingService.instance.trainings,
              builder: (context, list, _) {
                final t = _isNew ? null : TrainingService.instance.getById(widget.trainingId!);
                final savedExercises = t?.exercises ?? [];
                
                return Column(
                  children: [
                    // Show saved exercises
                    for (final ex in savedExercises)
                      Card(
                        color: Colors.white10,
                        child: ListTile(
                          leading: _isEditMode ? null : Checkbox(
                            value: _completedExercises.contains(ex.id.toString()),
                            onChanged: (value) async {
                              setState(() {
                                if (value == true) {
                                  _completedExercises.add(ex.id.toString());
                                } else {
                                  _completedExercises.remove(ex.id.toString());
                                }
                              });
                              // Save to database
                              try {
                                await _firestoreService.updateExercise(
                                  widget.trainingId!,
                                  ex.id,
                                  name: ex.name,
                                  sets: ex.sets,
                                  reps: ex.reps,
                                  weight: ex.weight,
                                  completed: value ?? false,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error updating exercise: $e')),
                                  );
                                }
                              }
                            },
                          ),
                          title: Text(
                            ex.name,
                            style: TextStyle(
                              color: _completedExercises.contains(ex.id.toString()) ? Colors.white38 : Colors.white,
                              decoration: _completedExercises.contains(ex.id.toString()) ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text(
                            'Sets: ${ex.sets} • Reps: ${ex.reps} • Weight: ${ex.weight}',
                            style: TextStyle(
                              color: _completedExercises.contains(ex.id.toString()) ? Colors.white30 : Colors.white70,
                            ),
                          ),
                          trailing: _isEditMode ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white70),
                                onPressed: () => _showExerciseDialog(context, exercise: ex),
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
                                    try {
                                      await _firestoreService.deleteExercise(widget.trainingId!, ex.id);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting exercise: $e')));
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          ) : null,
                        ),
                      ),
                    // Show pending exercises (not yet saved) - only in edit mode
                    if (_isEditMode)
                      for (var i = 0; i < _pendingExercises.length; i++)
                        Card(
                          color: Colors.white10,
                          child: ListTile(
                            title: Text(_pendingExercises[i]['name'] as String, style: const TextStyle(color: Colors.white)),
                            subtitle: Text('Sets: ${_pendingExercises[i]['sets']} • Reps: ${_pendingExercises[i]['reps']} • Weight: ${_pendingExercises[i]['weight']}', style: const TextStyle(color: Colors.white70)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white70),
                                  onPressed: () => _showExerciseDialog(context, pendingIndex: i),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      _pendingExercises.removeAt(i);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    if (_isEditMode) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showExerciseDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add exercise'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            if (_isEditMode) ...[
              const SizedBox(height: 20),
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
                      _firestoreService.addTraining(title: title, description: description, durationMinutes: duration).then((newId) async {
                        // Add all pending exercises
                        for (final exercise in _pendingExercises) {
                          try {
                            await _firestoreService.addExercise(
                              int.parse(newId),
                              name: exercise['name'] as String,
                              sets: exercise['sets'] as int,
                              reps: exercise['reps'] as int,
                              weight: exercise['weight'] as double,
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding exercise: $e')));
                            }
                          }
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Training created')));
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }).catchError((e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating training: $e')));
                        }
                      });
                    } else {
                      _firestoreService.updateTraining(widget.trainingId!, title: title, description: description, durationMinutes: duration).then((_) async {
                        // Add all pending exercises
                        for (final exercise in _pendingExercises) {
                          try {
                            await _firestoreService.addExercise(
                              widget.trainingId!,
                              name: exercise['name'] as String,
                              sets: exercise['sets'] as int,
                              reps: exercise['reps'] as int,
                              weight: exercise['weight'] as double,
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding exercise: $e')));
                            }
                          }
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Training saved')));
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }).catchError((e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving training: $e')));
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAAC2FF),
                    foregroundColor: const Color(0xFF213466),
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
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _showExerciseDialog(BuildContext context, {Exercise? exercise, int? pendingIndex}) async {
    final isPendingEdit = pendingIndex != null;
    final pendingExercise = isPendingEdit ? _pendingExercises[pendingIndex] : null;
    
    final nameCtrl = TextEditingController(text: exercise?.name ?? pendingExercise?['name'] ?? '');
    final setsCtrl = TextEditingController(text: exercise?.sets.toString() ?? pendingExercise?['sets']?.toString() ?? '3');
    final repsCtrl = TextEditingController(text: exercise?.reps.toString() ?? pendingExercise?['reps']?.toString() ?? '8');
    final weightCtrl = TextEditingController(text: exercise?.weight.toString() ?? pendingExercise?['weight']?.toString() ?? '0');

    final isEdit = exercise != null || isPendingEdit;

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
              
              if (exercise != null) {
                // Editing a saved exercise
                _firestoreService.updateExercise(widget.trainingId!, exercise.id, name: name, sets: sets, reps: reps, weight: weight).then((_) {
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                }).catchError((e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating exercise: $e')));
                  }
                });
              } else if (isPendingEdit) {
                // Editing a pending exercise
                setState(() {
                  _pendingExercises[pendingIndex] = {
                    'name': name,
                    'sets': sets,
                    'reps': reps,
                    'weight': weight,
                  };
                });
                Navigator.pop(context, true);
              } else if (!_isNew && widget.trainingId != null) {
                // Adding to an existing training
                _firestoreService.addExercise(widget.trainingId!, name: name, sets: sets, reps: reps, weight: weight).then((_) {
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                }).catchError((e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding exercise: $e')));
                  }
                });
              } else {
                // Adding to pending (new training)
                setState(() {
                  _pendingExercises.add({
                    'name': name,
                    'sets': sets,
                    'reps': reps,
                    'weight': weight,
                  });
                });
                Navigator.pop(context, true);
              }
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
