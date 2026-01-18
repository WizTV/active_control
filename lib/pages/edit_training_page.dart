import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../services/training_service.dart';
import '../services/firestore_training_service.dart';

class EditTrainingPage extends StatefulWidget {
  final int? trainingId;
  final DateTime? initialDate;
  const EditTrainingPage({super.key, this.trainingId, this.initialDate});

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
  late DateTime _selectedDate;

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
    // Normalize initial date to midnight
    if (widget.initialDate != null) {
      _selectedDate = DateTime(widget.initialDate!.year, widget.initialDate!.month, widget.initialDate!.day);
    } else {
      _selectedDate = DateTime.now();
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    }
    final id = widget.trainingId;
    if (id != null) {
      final t = TrainingService.instance.getById(id);
      if (t != null) {
        _isNew = false;
        _titleController.text = t.title;
        _descriptionController.text = t.description;
        _durationController.text = t.durationMinutes.toString();
        // Normalize the training date to midnight
        _selectedDate = DateTime(t.trainingDate.year, t.trainingDate.month, t.trainingDate.day);
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
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.white;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Training'),
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      _isEditMode ? 'Edit' : 'View',
                      style: TextStyle(color: textColor, fontSize: 14),
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
              const SizedBox(height: 12),
              Card(
                color: Colors.white10,
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: textColor.withValues(alpha: 0.7)),
                  title: Text(
                    'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: TextStyle(color: textColor),
                  ),
                  onTap: widget.initialDate == null ? () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        // Normalize to midnight to avoid time-related issues
                        _selectedDate = DateTime(picked.year, picked.month, picked.day);
                      });
                    }
                  } : null,
                  trailing: widget.initialDate != null ? Icon(Icons.lock, color: textColor.withValues(alpha: 0.7), size: 18) : null,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title: ${_titleController.text}', style: const TextStyle(color: Color.fromARGB(255, 30, 50, 100), fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (_descriptionController.text.isNotEmpty) ...[
                      Text('Description: ${_descriptionController.text}', style: const TextStyle(color: Color.fromARGB(255, 30, 50, 100))),
                      const SizedBox(height: 8),
                    ],
                    Text('Duration: ${_durationController.text} min', style: const TextStyle(color: Color.fromARGB(255, 30, 50, 100))),
                    const SizedBox(height: 8),
                    Text('Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(color: Color.fromARGB(255, 30, 50, 100))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text('Exercises', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                              color: _completedExercises.contains(ex.id.toString()) ? textColor.withValues(alpha: 0.38) : textColor,
                              decoration: _completedExercises.contains(ex.id.toString()) ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text(
                            'Sets: ${ex.sets} • Reps: ${ex.reps} • Weight: ${ex.weight}',
                            style: TextStyle(
                              color: _completedExercises.contains(ex.id.toString()) ? textColor.withValues(alpha: 0.3) : textColor.withValues(alpha: 0.7),
                            ),
                          ),
                          trailing: _isEditMode ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: textColor.withValues(alpha: 0.7)),
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
                            title: Text(_pendingExercises[i]['name'] as String, style: TextStyle(color: textColor)),
                            subtitle: Text('Sets: ${_pendingExercises[i]['sets']} • Reps: ${_pendingExercises[i]['reps']} • Weight: ${_pendingExercises[i]['weight']}', style: TextStyle(color: textColor.withValues(alpha: 0.7))),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: textColor.withValues(alpha: 0.7)),
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
                            foregroundColor: textColor,
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
                      _firestoreService.addTraining(title: title, description: description, durationMinutes: duration, trainingDate: _selectedDate).then((newId) async {
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
                      _firestoreService.updateTraining(widget.trainingId!, title: title, description: description, durationMinutes: duration, trainingDate: _selectedDate).then((_) async {
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
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.white;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit exercise' : 'Add exercise', style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: textColor),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
              ),
              TextField(
                controller: setsCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Sets',
                  labelStyle: TextStyle(color: textColor),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
              ),
              TextField(
                controller: repsCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Reps',
                  labelStyle: TextStyle(color: textColor),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
              ),
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Weight',
                  labelStyle: TextStyle(color: textColor),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: textColor))),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final sets = int.tryParse(setsCtrl.text.trim()) ?? 0;
              final reps = int.tryParse(repsCtrl.text.trim()) ?? 0;
              final weight = double.tryParse(weightCtrl.text.trim()) ?? 0.0;
              if (name.isEmpty) return;
              
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
            child: Text(isEdit ? 'Save' : 'Add', style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );

    if (result == true) {
    }
  }
}
