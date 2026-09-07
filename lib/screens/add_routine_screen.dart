import 'package:flutter/material.dart';
import 'package:instrumental/models/instrument.dart';
import 'package:instrumental/providers/practice_provider.dart';
import 'package:instrumental/utils/capitalize_string.dart';
import 'package:provider/provider.dart';

class AddRoutineScreen extends StatefulWidget {
  const AddRoutineScreen({super.key});

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  Instrument _selectedInstrument = Instrument.guitar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Routine'),
        actions: [
          IconButton(onPressed: _saveRoutine, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter routine title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<Instrument>(
                initialValue: _selectedInstrument,
                decoration: const InputDecoration(
                  labelText: 'Instrument',
                  border: OutlineInputBorder(),
                ),

                items: Instrument.values.map((Instrument instrument) {
                  return DropdownMenuItem<Instrument>(
                    value: instrument,
                    child: Text(capitalizeString(instrument.name)),
                  );
                }).toList(),
                onChanged: (Instrument? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedInstrument = newValue;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<PracticeProvider>();

      provider.addRoutine(_titleController.text, _selectedInstrument, []);

      Navigator.of(context).pop();
    }
  }
}
