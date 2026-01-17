import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'training_service.dart';

class FirestoreTrainingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Load all trainings from Firestore for the current user
  Future<void> loadTrainings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trainings')
          .get();

      // Clear local trainings and load from Firestore
      TrainingService.instance.trainings.value = [];
      TrainingService.instance.resetNextId();

      final trainings = <Training>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final exercises = (data['exercises'] as List<dynamic>?)
                ?.map((e) => Exercise(
                      id: (e['id'] as num).toInt(),
                      name: e['name'] as String,
                      sets: (e['sets'] as num).toInt(),
                      reps: (e['reps'] as num).toInt(),
                      weight: (e['weight'] as num).toDouble(),
                      completed: e['completed'] as bool? ?? false,
                    ))
                .toList() ??
            [];

        final trainingDate = data['trainingDate'] != null 
          ? (data['trainingDate'] as Timestamp).toDate()
          : DateTime.now();

        final training = Training(
          id: (data['id'] as num).toInt(),
          title: data['title'] as String,
          description: data['description'] as String,
          durationMinutes: (data['durationMinutes'] as num).toInt(),
          exercises: exercises,
          trainingDate: trainingDate,
        );

        trainings.add(training);

        // Update nextId to avoid conflicts
        if (training.id >= TrainingService.instance.getNextId()) {
          TrainingService.instance.setNextId(training.id + 1);
        }
      }
      
      // Sort trainings by date (most recent first)
      trainings.sort((a, b) => b.trainingDate.compareTo(a.trainingDate));
      TrainingService.instance.trainings.value = trainings;
    } catch (e) {
      rethrow;
    }
  }

  /// Add a training to Firestore and local storage
  Future<String> addTraining({
    required String title,
    required String description,
    required int durationMinutes,
    DateTime? trainingDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Add to local service first
      final trainingId = TrainingService.instance.addTraining(
        title: title,
        description: description,
        durationMinutes: durationMinutes,
        trainingDate: trainingDate,
      );

      final training = TrainingService.instance.getById(trainingId);
      if (training == null) throw Exception('Failed to create training locally');

      // Add to Firestore
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trainings')
          .doc(trainingId.toString());

      await docRef.set(_trainingToJson(training));

      return trainingId.toString();
    } catch (e) {
      rethrow;
    }
  }

  /// Update a training in Firestore and local storage
  Future<void> updateTraining(
    int id, {
    required String title,
    required String description,
    required int durationMinutes,
    DateTime? trainingDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Update local service
      TrainingService.instance.updateTraining(
        id,
        title: title,
        description: description,
        durationMinutes: durationMinutes,
        trainingDate: trainingDate,
      );

      final training = TrainingService.instance.getById(id);
      if (training == null) throw Exception('Training not found');

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trainings')
          .doc(id.toString())
          .update(_trainingToJson(training));
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a training from Firestore and local storage
  Future<void> deleteTraining(int id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Delete from local service
      TrainingService.instance.deleteTraining(id);

      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trainings')
          .doc(id.toString())
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Add exercise to a training
  Future<void> addExercise(
    int trainingId, {
    required String name,
    required int sets,
    required int reps,
    required double weight,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Add locally
      TrainingService.instance.addExercise(
        trainingId,
        name: name,
        sets: sets,
        reps: reps,
        weight: weight,
      );

      final training = TrainingService.instance.getById(trainingId);
      if (training == null) throw Exception('Training not found');

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trainings')
          .doc(trainingId.toString())
          .update(_trainingToJson(training));
    } catch (e) {
      rethrow;
    }
  }

  /// Update exercise in a training
  Future<void> updateExercise(
    int trainingId,
    int exerciseId, {
    required String name,
    required int sets,
    required int reps,
    required double weight,
    bool completed = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Update locally
      final training = TrainingService.instance.getById(trainingId);
      if (training != null) {
        final updatedExercises = training.exercises.map((e) {
          if (e.id == exerciseId) {
            e.completed = completed;
            e.name = name;
            e.sets = sets;
            e.reps = reps;
            e.weight = weight;
          }
          return e;
        }).toList();
        
        TrainingService.instance.trainings.value = TrainingService.instance.trainings.value.map((t) {
          if (t.id == trainingId) {
            return Training(
              id: t.id,
              title: t.title,
              description: t.description,
              durationMinutes: t.durationMinutes,
              exercises: updatedExercises,
            );
          }
          return t;
        }).toList();
      }

      final updatedTraining = TrainingService.instance.getById(trainingId);
      if (updatedTraining == null) throw Exception('Training not found');

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trainings')
          .doc(trainingId.toString())
          .update(_trainingToJson(updatedTraining));
    } catch (e) {
      rethrow;
    }
  }

  /// Delete exercise from a training
  Future<void> deleteExercise(int trainingId, int exerciseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Delete locally
      TrainingService.instance.deleteExercise(trainingId, exerciseId);

      final training = TrainingService.instance.getById(trainingId);
      if (training == null) throw Exception('Training not found');

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('trainings')
          .doc(trainingId.toString())
          .update(_trainingToJson(training));
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all local trainings
  Future<void> clearTrainings() async {
    TrainingService.instance.trainings.value = [];
    TrainingService.instance.resetNextId();
  }

  /// Convert Training to JSON for Firestore
  Map<String, dynamic> _trainingToJson(Training training) {
    return {
      'id': training.id,
      'title': training.title,
      'description': training.description,
      'durationMinutes': training.durationMinutes,
      'trainingDate': Timestamp.fromDate(training.trainingDate),
      'exercises': training.exercises
          .map((e) => {
                'id': e.id,
                'name': e.name,
                'sets': e.sets,
                'reps': e.reps,
                'weight': e.weight,
                'completed': e.completed,
              })
          .toList(),
    };
  }
}
