import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:instrumental/models/exercise.dart';
import 'package:instrumental/models/practice_session.dart';
import 'package:instrumental/providers/practice_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Progress'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Results'),
              Tab(text: 'Time'),
            ],
          ),
        ),
        body: TabBarView(children: [_ResultsChartTab(), _TimeSpentChartTab()]),
      ),
    );
  }
}

class _ResultsChartTab extends StatefulWidget {
  const _ResultsChartTab();

  @override
  State<_ResultsChartTab> createState() => _ResultsChartTabState();
}

class _ResultsChartTabState extends State<_ResultsChartTab> {
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
    final Map<DateTime, int> dailyHighest = {};
    for (var record in exercise.statHistory) {
      final day = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      if (!dailyHighest.containsKey(day) || record.value > dailyHighest[day]!) {
        dailyHighest[day] = record.value;
      }
    }

    final sortedDays = dailyHighest.keys.toList()..sort();

    final spots = sortedDays.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        dailyHighest[entry.value]!.toDouble(),
      );
    }).toList();

    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= sortedDays.length) {
                return const SizedBox.shrink();
              }

              final date = sortedDays[index];
              final formattedDate = DateFormat('MMM d').format(date);

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
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

class _TimeSpentChartTab extends StatelessWidget {
  const _TimeSpentChartTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final sessions = provider.sessions;

    final totalMinutes = sessions.fold(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.lightBlue, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Practice Time',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${hours}h ${minutes}m',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              'Last 7 Days',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Expanded(child: BarChart(_createChartData(sessions))),
          ],
        ),
      ),
    );
  }

  BarChartData _createChartData(List<PracticeSession> sessions) {
    final List<double> weeklyData = List.filled(7, 0.0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var session in sessions) {
      final sessionDate = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      final difference = today.difference(sessionDate).inDays;

      if (difference >= 0 && difference < 7) {
        weeklyData[6 - difference] += session.durationMinutes.toDouble();
      }
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY:
          weeklyData.reduce((curr, next) => curr > next ? curr : next) * 1.2 +
          10,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final date = today.subtract(Duration(days: 6 - value.toInt()));
              final dayName = DateFormat('E').format(date);
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  dayName,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: weeklyData.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              gradient: const LinearGradient(
                colors: [Color(0xFF00e676), Color(0xFF1de9b6)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 20,
              borderRadius: BorderRadius.circular(6),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY:
                    weeklyData.reduce(
                          (curr, next) => curr > next ? curr : next,
                        ) *
                        1.2 +
                    10,
                color: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
