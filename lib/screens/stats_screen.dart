import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:instrumental/models/exercise.dart';
import 'package:instrumental/providers/practice_provider.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Exercise? _selectedExercise;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();

    final trackableExercises = provider.exercises
        .where(
          (exercise) =>
              exercise.statisticName != null && exercise.statHistory.isNotEmpty,
        )
        .toList();

    if (_selectedExercise == null && trackableExercises.isNotEmpty) {
      _selectedExercise = trackableExercises.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: trackableExercises.isEmpty
          ? const Center(child: Text('No history data.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Exercise>(
                    decoration: const InputDecoration(
                      labelText: 'Select Exercise',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedExercise,
                    items: trackableExercises.map((exercise) {
                      return DropdownMenuItem<Exercise>(
                        value: exercise,
                        child: Text(exercise.title),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() => _selectedExercise = newValue);
                    },
                  ),

                  const SizedBox(height: 32),

                  if (_selectedExercise != null)
                    Text(
                      "Last '${_selectedExercise!.statisticName}': ${_selectedExercise!.lastStatistic}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 32),

                  if (_selectedExercise != null)
                    Expanded(
                      child: LineChart(_buildChartData(_selectedExercise!)),
                    ),
                ],
              ),
            ),
    );
  }

  LineChartData _buildChartData(Exercise exercise) {
    final history = List.of(exercise.statHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
    }).toList();

    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text('#${value.toInt() + 1}'),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: Colors.blue,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
