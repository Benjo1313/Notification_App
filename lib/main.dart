import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The app bar at the top
      appBar: AppBar(
        title: const Text('My Goals'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      // Body contains our timer card centered on screen
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: WorkoutTimerCard(),
        ),
      ),
    );
  }
}

// This is the main timer card widget
class WorkoutTimerCard extends StatefulWidget {
  const WorkoutTimerCard({super.key});

  @override
  State<WorkoutTimerCard> createState() => _WorkoutTimerCardState();
}

class _WorkoutTimerCardState extends State<WorkoutTimerCard> {
  Timer? _timer;
  late int _remainingSeconds;
  bool _isRunning = false;
  final int _goalMinutes = 1;

  @override
  void initState() {
    super.initState();
    // Initialize remaining seconds to the goal when widget is created
    _remainingSeconds = _goalMinutes * 60;
  }

    // Convert seconds to a nice MM:SS format
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;  // ~/ means divide and round down
    int remainingSeconds = seconds % 60;  // % gives us the remainder
    
    // padLeft(2, '0') ensures we always have 2 digits (e.g., "05" not "5")
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  // Calculate progress as a percentage (0.0 to 1.0)
  double _getProgress() {
    int goalSeconds = _goalMinutes * 60;
    if (goalSeconds == 0) return 0;
    
    // Progress is how much we've USED, not what's remaining
    int elapsedSeconds = goalSeconds - _remainingSeconds;
    double progress = elapsedSeconds / goalSeconds;
    
    return progress > 1.0 ? 1.0 : progress;
  }
  
  // Start or resume the timer
  void _startTimer() {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;  // Subtract instead of add
        } else {
          // Timer reached zero!
          _pauseTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Time\'s up! Goal reached! 🎉')),
          );
        }
      });
    });
  }
  
  // Pause the timer
  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    
    _timer?.cancel(); // Stop the timer (? means "if it exists")
  }
  
  // Complete/Reset the timer
  void _completeTimer() {
    _timer?.cancel();
    
    setState(() {
      _isRunning = false;
      _remainingSeconds = _goalMinutes * 60;  // Reset to full time
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timer reset! 🎉')),
    );
  }
  
  // Clean up when widget is removed
  @override
  void dispose() {
    _timer?.cancel(); // Always cancel timer when leaving
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '💪',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Workout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_goalMinutes min daily goal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isRunning ? Colors.green[50] : Colors.orange[50],  // Color changes
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isRunning ? 'ACTIVE' : 'PAUSED',  // Text changes
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isRunning ? Colors.green[900] : Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatTime(_remainingSeconds),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _getProgress(),
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(_remainingSeconds / 60).ceil()} min remaining',  // Show what's LEFT
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  Text(
                    '${(_getProgress() * 100).floor()}%',  // Progress still shows completion
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,  // Toggle based on state
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    _isRunning ? 'Pause' : 'Resume',  // Button text changes
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _completeTimer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Complete',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
