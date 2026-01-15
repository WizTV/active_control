import 'package:flutter/foundation.dart';

class Training {
  final int id;
  String title;
  String description;
  int durationMinutes;
  List<Exercise> exercises;

  Training({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];
}

class TrainingService {
  TrainingService._internal();

  static final TrainingService _instance = TrainingService._internal();
  static TrainingService get instance => _instance;

  final ValueNotifier<List<Training>> trainings = ValueNotifier<List<Training>>([]);
  int _nextId = 1;

  List<Training> getAll() => trainings.value;

  int getNextId() => _nextId;

  void setNextId(int value) => _nextId = value;

  void resetNextId() => _nextId = 1;

  Training? getById(int id) {
    for (final t in trainings.value) {
      if (t.id == id) return t;
    }
    return null;
  }

  int addTraining({required String title, required String description, required int durationMinutes}) {
    final t = Training(id: _nextId++, title: title, description: description, durationMinutes: durationMinutes, exercises: []);
    trainings.value = [...trainings.value, t];
    return t.id;
  }

  void updateTraining(int id, {required String title, required String description, required int durationMinutes}) {
    final list = trainings.value.map((t) {
      if (t.id == id) {
        return Training(id: t.id, title: title, description: description, durationMinutes: durationMinutes, exercises: t.exercises);
      }
      return t;
    }).toList();
    trainings.value = list;
  }

  void deleteTraining(int id) {
    trainings.value = trainings.value.where((t) => t.id != id).toList();
  }

  // Exercises management
  void addExercise(int trainingId, {required String name, required int sets, required int reps, required double weight}) {
    final list = trainings.value.map((t) {
      if (t.id == trainingId) {
        final newEx = Exercise(id: DateTime.now().microsecondsSinceEpoch, name: name, sets: sets, reps: reps, weight: weight);
        return Training(id: t.id, title: t.title, description: t.description, durationMinutes: t.durationMinutes, exercises: [...t.exercises, newEx]);
      }
      return t;
    }).toList();
    trainings.value = list;
  }

  void updateExercise(int trainingId, int exerciseId, {required String name, required int sets, required int reps, required double weight}) {
    final list = trainings.value.map((t) {
      if (t.id == trainingId) {
        final updated = t.exercises.map((e) {
          if (e.id == exerciseId) {
            return Exercise(id: e.id, name: name, sets: sets, reps: reps, weight: weight);
          }
          return e;
        }).toList();
        return Training(id: t.id, title: t.title, description: t.description, durationMinutes: t.durationMinutes, exercises: updated);
      }
      return t;
    }).toList();
    trainings.value = list;
  }

  void deleteExercise(int trainingId, int exerciseId) {
    final list = trainings.value.map((t) {
      if (t.id == trainingId) {
        final filtered = t.exercises.where((e) => e.id != exerciseId).toList();
        return Training(id: t.id, title: t.title, description: t.description, durationMinutes: t.durationMinutes, exercises: filtered);
      }
      return t;
    }).toList();
    trainings.value = list;
  }
}

class Exercise {
  final int id;
  String name;
  int sets;
  int reps;
  double weight;
  bool completed;

  Exercise({required this.id, required this.name, required this.sets, required this.reps, required this.weight, this.completed = false});
}
