import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/login_button.dart';

class EditTrainingPage extends StatefulWidget {
  const EditTrainingPage({super.key});

  @override
  State<EditTrainingPage> createState() => _EditTrainingPageState();
}

class _EditTrainingPageState extends State<EditTrainingPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Training'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Training details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            LoginButton(
              text: 'Save',
              onPressed: () {
                // For now just show a confirmation snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Training saved')),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
