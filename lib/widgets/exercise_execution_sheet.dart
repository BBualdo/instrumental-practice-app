import 'dart:async';
import 'package:flutter/material.dart';
import 'package:instrumental/models/exercise.dart';
import 'package:audioplayers/audioplayers.dart';

class ExerciseExecutionSheet extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onComplete;

  const ExerciseExecutionSheet({
    super.key,
    required this.exercise,
    required this.onComplete,
  });

  @override
  State<ExerciseExecutionSheet> createState() => _ExerciseExecutionSheetState();
}

class _ExerciseExecutionSheetState extends State<ExerciseExecutionSheet> {
  Timer? _timer;
  late int _remainingSeconds;
  bool _isRunning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.exercise.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (widget.exercise.description != null) ...[
            const SizedBox(height: 8),
            Text(widget.exercise.description!, textAlign: TextAlign.center),
          ],

          const Divider(height: 32),

          if (widget.exercise.statisticName != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Last ${widget.exercise.statisticName}: ${widget.exercise.lastStatistic ?? 'N/A'}',
                ),
                Text(
                  'Most ${widget.exercise.statisticName}: ${widget.exercise.highestStatistic ?? 'N/A'}',
                ),
              ],
            ),

          const SizedBox(height: 24),

          Text(
            _formattedTime,
            style: const TextStyle(fontSize: 48, fontFamily: 'monospace'),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh),
                iconSize: 32,
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: _toggleTimer,
                child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: widget.onComplete,
                icon: const Icon(Icons.check_circle), color: Colors.green,
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _remainingSeconds = widget.exercise.durationSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();

    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();

          await _audioPlayer.play(AssetSource('audio/ping.mp3'));

          widget.onComplete();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = widget.exercise.durationSeconds;
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
