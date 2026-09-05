import 'package:flutter/material.dart';
import 'package:instrumental/models/exercise.dart';
import 'package:instrumental/models/instrument.dart';
import 'package:instrumental/providers/practice_provider.dart';
import 'package:provider/provider.dart';

class AddExerciseScreen extends StatefulWidget {
  final Exercise? exerciseToEdit;

  const AddExerciseScreen({super.key, this.exerciseToEdit});

  @override
  State<StatefulWidget> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _relatedLinkController = TextEditingController();
  final _statisticNameController = TextEditingController();
  late Instrument _selectedInstrument;

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exerciseToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Update Exercise' : 'New Exercise'),
        actions: [
          IconButton(onPressed: _saveExercise, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  label: Text('Title'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter exercise title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  label: Text('Description'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
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
                    child: Text(instrument.name.toUpperCase()),
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

              const SizedBox(height: 20),

              TextFormField(
                keyboardType: TextInputType.number,
                controller: _durationController,
                decoration: const InputDecoration(
                  label: Text('Duration'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter exercise duration';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Duration must be a number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _relatedLinkController,
                decoration: const InputDecoration(
                  label: Text('Related link'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _statisticNameController,
                decoration: const InputDecoration(
                  label: Text('Statistic name'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: null,
    );
  }

  @override
  void initState() {
    super.initState();

    final editTarget = widget.exerciseToEdit;

    if (editTarget != null) {
      _titleController.text = editTarget.title;
      _descriptionController.text = editTarget.description ?? '';
      _durationController.text = editTarget.durationMinutes.toString();
      _relatedLinkController.text = editTarget.relatedLink ?? '';
      _statisticNameController.text = editTarget.statisticName ?? '';
      _selectedInstrument = editTarget.instrument;
    } else {
      _selectedInstrument = Instrument.guitar;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _relatedLinkController.dispose();
    _statisticNameController.dispose();

    super.dispose();
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<PracticeProvider>();

      if (widget.exerciseToEdit != null) {
        provider.updateExercise(
          id: widget.exerciseToEdit!.id,
          title: _titleController.text,
          duration: int.parse(_durationController.text),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          relatedLink: _relatedLinkController.text.isEmpty
              ? null
              : _relatedLinkController.text,
          statisticName: _statisticNameController.text.isEmpty
              ? null
              : _statisticNameController.text,
          instrument: _selectedInstrument,
        );
      } else {
        provider.addExercise(
          title: _titleController.text,
          duration: int.parse(_durationController.text),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          relatedLink: _relatedLinkController.text.isEmpty
              ? null
              : _relatedLinkController.text,
          statisticName: _statisticNameController.text.isEmpty
              ? null
              : _statisticNameController.text,
          instrument: _selectedInstrument,
        );
      }

      Navigator.of(context).pop();
    }
  }
}
