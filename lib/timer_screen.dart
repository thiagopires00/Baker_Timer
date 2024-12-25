import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'models/dough.dart';
bool isTestSoundPlaying = false;

class TimerScreen extends StatefulWidget {
  final List<Dough> doughList;

  const TimerScreen({super.key, required this.doughList});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  List<Dough?> selectedDoughs = [];
  List<int> speed1Timers = [];
  List<int> speed2Timers = [];
  List<bool> isSpeed1List = [];
  List<Timer?> timers = [];
  List<bool> isPaused = [];
  List<bool> isBlinking = [];
  List<bool> hasStarted = [];
  final AudioPlayer audioPlayer = AudioPlayer();

  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    for (var timer in timers) {
      timer?.cancel();
    }
    audioPlayer.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void addTimer() {
    setState(() {
      selectedDoughs.add(null);
      speed1Timers.add(0);
      speed2Timers.add(0);
      isSpeed1List.add(true);
      timers.add(null);
      isPaused.add(true);
      isBlinking.add(false);
      hasStarted.add(false);
    });
  }

  void deleteTimer(int index) {
    if (index < 0 || index >= selectedDoughs.length) return;

    setState(() {
      timers[index]?.cancel();
      selectedDoughs.removeAt(index);
      speed1Timers.removeAt(index);
      speed2Timers.removeAt(index);
      isSpeed1List.removeAt(index);
      timers.removeAt(index);
      isPaused.removeAt(index);
      isBlinking.removeAt(index);
      hasStarted.removeAt(index);
    });
  }

  void onDoughChanged(int index, Dough? newValue) {
    if (index < 0 || index >= selectedDoughs.length) return;

    setState(() {
      selectedDoughs[index] = newValue;
      if (newValue != null) {
        speed1Timers[index] = newValue.speed1Time;
        speed2Timers[index] = newValue.speed2Time;
      }
    });
  }

  void playSound() async {
    try {
      await audioPlayer.setAsset('assets/digital.wav');
      audioPlayer.setLoopMode(LoopMode.one);
      audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void stopSound() async {
    try {
      await audioPlayer.stop();
    } catch (e) {
      print('Error stopping sound: $e');
    }
  }

  void startOrResumeTimer(int index) {
    if (index < 0 || index >= selectedDoughs.length) return;

    if (selectedDoughs[index] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a dough type before starting the timer.')),
      );
      return;
    }

    timers[index]?.cancel();

    if (!hasStarted[index]) {
      speed1Timers[index] = selectedDoughs[index]!.speed1Time;
      speed2Timers[index] = selectedDoughs[index]!.speed2Time;
      isSpeed1List[index] = true;
      hasStarted[index] = true;
    }

    setState(() {
      isPaused[index] = false;
      isBlinking[index] = false;
    });

    timers[index] = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (isSpeed1List[index]) {
          if (speed1Timers[index] > 0) {
            speed1Timers[index]--;
          } else {
            isPaused[index] = true;
            isBlinking[index] = true;
            playSound();
            timer.cancel();
          }
        } else {
          if (speed2Timers[index] > 0) {
            speed2Timers[index]--;
          } else {
            isPaused[index] = true;
            isBlinking[index] = true;
            playSound();
            timer.cancel();
          }
        }
      });
    });
  }

  void pauseTimer(int index) {
    if (index < 0 || index >= selectedDoughs.length) return;

    setState(() {
      isPaused[index] = true;
      timers[index]?.cancel();
    });
  }

  void stopTimer(int index) {
    if (index < 0 || index >= selectedDoughs.length) return;

    setState(() {
      timers[index]?.cancel();
      speed1Timers[index] = selectedDoughs[index]?.speed1Time ?? 0;
      speed2Timers[index] = selectedDoughs[index]?.speed2Time ?? 0;
      isSpeed1List[index] = true;
      isPaused[index] = true;
      isBlinking[index] = false;
      hasStarted[index] = false;
      stopSound();
    });
  }

  void acknowledgeAlert(int index) {
    if (index < 0 || index >= selectedDoughs.length) return;

    setState(() {
      stopSound();
      isBlinking[index] = false;

      if (isSpeed1List[index] && speed2Timers[index] > 0) {
        isSpeed1List[index] = false;
        startOrResumeTimer(index);
      } else {
        stopTimer(index);
      }
    });
  }

  void addExtraMinute(int index) {
    if (index < 0 || index >= selectedDoughs.length) return;

    setState(() {
      if (isSpeed1List[index]) {
        speed1Timers[index] += 60;
      } else {
        speed2Timers[index] += 60;
      }
      isPaused[index] = false;
      isBlinking[index] = false;
      stopSound();
      startOrResumeTimer(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixer Timers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
                      // Add Timer Button
          ElevatedButton(
            onPressed: addTimer,
            child: const Text('Add Timer'),
          ),

          // Test Sound Button
          ElevatedButton(
  onPressed: () async {
    try {
      if (audioPlayer.playing) {
        // Stop the sound and update state only after confirmation
        await audioPlayer.stop();
        setState(() {
          isTestSoundPlaying = false;
        });
      } else {
        // Play the sound and update state only after confirmation
        await audioPlayer.setAsset('assets/digital.wav');
        await audioPlayer.setLoopMode(LoopMode.one);
        await audioPlayer.play();
        setState(() {
          isTestSoundPlaying = true;
        });
      }
    } catch (e) {
      print('Error handling test sound: $e');
    }
  },
  child: Text(isTestSoundPlaying ? 'Stop Sound' : 'Test Sound'),
),



          // Timer List
          Expanded(
            child: ListView.builder(

                itemCount: selectedDoughs.length,
                itemBuilder: (context, index) {
                  return TimerCard(
                    index: index,
                    doughList: widget.doughList,
                    selectedDough: selectedDoughs[index],
                    speed1Time: speed1Timers[index],
                    speed2Time: speed2Timers[index],
                    isPaused: isPaused[index],
                    isBlinking: isBlinking[index],
                    hasStarted: hasStarted[index],
                    onStart: () => startOrResumeTimer(index),
                    onPause: () => pauseTimer(index),
                    onStop: () => stopTimer(index),
                    onDelete: () => deleteTimer(index),
                    onDoughChanged: onDoughChanged,
                    onAcknowledge: () => acknowledgeAlert(index),
                    onAddExtraMinute: () => addExtraMinute(index),
                    blinkController: _blinkController,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerCard extends StatelessWidget {
  final int index;
  final List<Dough> doughList;
  final Dough? selectedDough;
  final int speed1Time;
  final int speed2Time;
  final bool isPaused;
  final bool isBlinking;
  final bool hasStarted;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback onDelete;
  final VoidCallback onAcknowledge;
  final VoidCallback onAddExtraMinute;
  final void Function(int index, Dough? newValue) onDoughChanged;
  final AnimationController blinkController;

  const TimerCard({
    super.key,
    required this.index,
    required this.doughList,
    required this.selectedDough,
    required this.speed1Time,
    required this.speed2Time,
    required this.isPaused,
    required this.isBlinking,
    required this.hasStarted,
    required this.onStart,
    required this.onPause,
    required this.onStop,
    required this.onDelete,
    required this.onAcknowledge,
    required this.onAddExtraMinute,
    required this.onDoughChanged,
    required this.blinkController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: blinkController,
      builder: (context, child) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: isBlinking
              ? Color.lerp(Colors.yellow, Colors.white, blinkController.value)
              : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<Dough>(
                  hint: const Text('Select Dough Type'),
                  value: selectedDough,
                  items: doughList.map((Dough dough) {
                    return DropdownMenuItem<Dough>(
                      value: dough,
                      child: Text(dough.name),
                    );
                  }).toList(),
                  onChanged: (Dough? newValue) => onDoughChanged(index, newValue),
                ),
                Text('Speed 1 Time: ${speed1Time}s'),
                Text('Speed 2 Time: ${speed2Time}s'),
                                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isBlinking) ...[
                      ElevatedButton(
                        onPressed: onAcknowledge,
                        child: const Text('Acknowledge'),
                      ),
                      ElevatedButton(
                        onPressed: onAddExtraMinute,
                        child: const Text('+1 Min'),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: !hasStarted || isPaused ? onStart : onPause,
                        child: Text(!hasStarted ? 'Start' : isPaused ? 'Resume' : 'Pause'),
                      ),
                      ElevatedButton(
                        onPressed: onStop,
                        child: const Text('Stop'),
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

