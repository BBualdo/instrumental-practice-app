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

    final maxStat = dailyHighest.values.isEmpty
        ? 0
        : dailyHighest.values.reduce((curr, next) => curr > next ? curr : next);

    final double maxX = sortedDays.isEmpty
        ? 0
        : (sortedDays.length - 1).toDouble();
    final double minX = sortedDays.length < 7 ? maxX - 6 : 0;

    return LineChartData(
      minY: 0,
      maxY: maxStat * 1.2 + 5,
      minX: minX,
      maxX: maxX,
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

class _TimeSpentChartTab extends StatefulWidget {
  const _TimeSpentChartTab();

  @override
  State<_TimeSpentChartTab> createState() => _TimeSpentChartTabState();
}

class _TimeSpentChartTabState extends State<_TimeSpentChartTab> {
  int? _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final allSessions = provider.sessions;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? startDate;
    if (_selectedDays != null) {
      startDate = today.subtract(Duration(days: _selectedDays! - 1));
    } else if (allSessions.isNotEmpty) {
      final sortedSessions = List.of(allSessions)
        ..sort((a, b) => a.date.compareTo(b.date));
      final oldest = sortedSessions.first.date;
      startDate = DateTime(oldest.year, oldest.month, oldest.day);
    } else {
      startDate = today;
    }

    final filteredSessions = allSessions.where((s) {
      final sessionDate = DateTime(s.date.year, s.date.month, s.date.day);
      return sessionDate.isAfter(startDate!.subtract(const Duration(days: 1)));
    }).toList();

    final totalMinutes = filteredSessions.fold(
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
                    'Practice Time',
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

            const SizedBox(height: 24),

            SegmentedButton<int?>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 Days')),
                ButtonSegment(value: 30, label: Text('30 Days')),
                ButtonSegment(value: null, label: Text('All Time')),
              ],
              selected: {_selectedDays},
              onSelectionChanged: (Set<int?> newSelection) {
                setState(() {
                  _selectedDays = newSelection.first;
                });
              },
            ),

            const SizedBox(height: 24),

            Expanded(
              child: BarChart(
                _createChartData(filteredSessions, startDate, today),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _createChartData(
    List<PracticeSession> sessions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<DateTime, int> dailyMinutes = {};
    final int daysCount = endDate.difference(startDate).inDays + 1;

    for (int i = 0; i < daysCount; i++) {
      dailyMinutes[startDate.add(Duration(days: i))] = 0;
    }

    for (var session in sessions) {
      final sessionDate = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      if (dailyMinutes.containsKey(sessionDate)) {
        dailyMinutes[sessionDate] =
            dailyMinutes[sessionDate]! + session.durationMinutes;
      }
    }

    final sortedDays = dailyMinutes.keys.toList()..sort();
    final maxValue = dailyMinutes.values.isEmpty
        ? 0
        : dailyMinutes.values.reduce((curr, next) => curr > next ? curr : next);

    final double dynamicBarWidth = (200 / daysCount).clamp(4.0, 20.0);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxValue * 1.2 + 10,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= sortedDays.length) {
                return const SizedBox.shrink();
              }

              final int step = daysCount > 7 ? (daysCount / 5).ceil() : 1;

              final distanceFromEnd = (sortedDays.length - 1) - index;

              if (distanceFromEnd % step != 0) {
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
                  softWrap: false,
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
      barGroups: sortedDays.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: dailyMinutes[entry.value]!.toDouble(),
              gradient: const LinearGradient(
                colors: [Color(0xFF00e676), Color(0xFF1de9b6)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: dynamicBarWidth,
              borderRadius: BorderRadius.circular(6),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxValue * 1.2 + 10,
                color: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
