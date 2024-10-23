import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // Import just_audio package
import 'package:audio_session/audio_session.dart'; // Import audio_session package
import 'models/dough.dart';

class TimerScreen extends StatefulWidget {
  final List<Dough> doughList;

  TimerScreen({required this.doughList});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  List<Dough?> selectedDoughs = [null, null, null];
  List<int> speed1Timers = [0, 0, 0];
  List<int> speed2Timers = [0, 0, 0];
  List<bool> isSpeed1List = [true, true, true];
  List<Timer?> timers = [null, null, null];
  List<bool> isPaused = [false, false, false]; // Tracks if each timer is paused
  List<bool> isBlinking = [false, false, false]; // Tracks if a timer is blinking for acknowledgment
  final AudioPlayer audioPlayer = AudioPlayer(); // Initialize just_audio player
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Cancel all timers and dispose of audioPlayer when the screen is disposed
    for (var timer in timers) {
      timer?.cancel();
    }
    audioPlayer.dispose(); // Dispose of the audio player
    _blinkController.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  // Function to play the sound when the timer finishes
  void playSound() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.speech()); // Configure the session

      await audioPlayer.setAsset('assets/timer_end.mp3'); // Load the asset
      await audioPlayer.play(); // Play the sound
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Function to stop the sound
  void stopSound() async {
    try {
      await audioPlayer.stop();
    } catch (e) {
      print('Error stopping sound: $e');
    }
  }

  // Start or resume the timer for a specific index (dough type)
  void startOrResumeTimer(int index) {
    if (selectedDoughs[index] == null) {
      // Ensure a dough type is selected before starting the timer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a dough type before starting the timer.')),
      );
      return;
    }

    timers[index]?.cancel(); // Cancel any running timer first

    // If the timer was stopped or reset, initialize the times
    if (speed1Timers[index] == 0 && speed2Timers[index] == 0) {
      speed1Timers[index] = selectedDoughs[index]!.speed1Time;
      speed2Timers[index] = selectedDoughs[index]!.speed2Time;
      isSpeed1List[index] = true;
    }

    setState(() {
      isPaused[index] = false; // Resume or start the timer
      isBlinking[index] = false; // Stop blinking if it was
    });

    timers[index] = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (isSpeed1List[index]) {
          if (speed1Timers[index] > 0) {
            speed1Timers[index]--;
          } else {
            // Speed 1 finished, pause and alert the baker
            isSpeed1List[index] = false;
            isPaused[index] = true;
            isBlinking[index] = true;
            playSound(); // Play sound when Speed 1 finishes
            timer.cancel();
          }
        } else {
          if (speed2Timers[index] > 0) {
            speed2Timers[index]--;
          } else {
            // Speed 2 finished, pause and alert the baker
            isPaused[index] = true;
            isBlinking[index] = true;
            playSound(); // Play sound when Speed 2 finishes
            timer.cancel();
          }
        }
      });
    });
  }

  // Acknowledge the alert and proceed to the next step or reset
  void acknowledgeAlert(int index) {
    setState(() {
      stopSound(); // Stop the sound
      isBlinking[index] = false; // Stop blinking
      if (isSpeed1List[index] == false && speed2Timers[index] > 0) {
        // Resume Speed 2 if Speed 1 was acknowledged
        startOrResumeTimer(index);
      } else {
        // Reset if Speed 2 was acknowledged
        speed1Timers[index] = selectedDoughs[index]!.speed1Time;
        speed2Timers[index] = selectedDoughs[index]!.speed2Time;
        isSpeed1List[index] = true;
      }
    });
  }

  // Pause the timer
  void pauseTimer(int index) {
    setState(() {
      isPaused[index] = true;
      timers[index]?.cancel(); // Pause the timer
    });
  }

  // Stop and reset the timer
  void stopTimer(int index) {
    setState(() {
      timers[index]?.cancel(); // Cancel the timer
      // Reset the timer values for Speed 1 and Speed 2
      speed1Timers[index] = selectedDoughs[index] != null ? selectedDoughs[index]!.speed1Time : 0;
      speed2Timers[index] = selectedDoughs[index] != null ? selectedDoughs[index]!.speed2Time : 0;
      isSpeed1List[index] = true; // Reset to Speed 1
      isPaused[index] = false; // Unpause the timer
      isBlinking[index] = false; // Stop blinking
      stopSound(); // Stop the sound if it is playing
    });
  }

  // Delete the timer
  void deleteTimer(int index) {
    setState(() {
      timers[index]?.cancel(); // Cancel the timer
      selectedDoughs.removeAt(index);
      speed1Timers.removeAt(index);
      speed2Timers.removeAt(index);
      isSpeed1List.removeAt(index);
      timers.removeAt(index);
      isPaused.removeAt(index);
      isBlinking.removeAt(index);
    });
  }

  // Add a new timer
  void addTimer() {
    setState(() {
      selectedDoughs.add(null); // Add a placeholder for the dropdown selection
      speed1Timers.add(0); // Default to 0 seconds for new timers
      speed2Timers.add(0); // Default to 0 seconds for new timers
      isSpeed1List.add(true);
      timers.add(null); // Add a placeholder for the Timer object
      isPaused.add(false); // Initially, the timer is not paused
      isBlinking.add(false); // Initially, the timer is not blinking
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dough Timers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // List of timers
            Expanded(
              child: ListView.builder(
                itemCount: selectedDoughs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AnimatedBuilder(
                      animation: _blinkController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: isBlinking[index] && _blinkController.value > 0.5
                                ? Colors.yellowAccent.withOpacity(0.5)
                                : Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              // Dropdown to select dough type
                              DropdownButton<Dough>(
                                hint: const Text('Select Dough Type'),
                                value: selectedDoughs[index] != null && widget.doughList.contains(selectedDoughs[index])
                                    ? selectedDoughs[index]
                                    : null,
                                items: widget.doughList.map((Dough dough) {
                                  return DropdownMenuItem<Dough>(
                                    value: dough,
                                    child: Text(dough.name),
                                  );
                                }).toList(),
                                onChanged: (Dough? newDough) {
                                  setState(() {
                                    selectedDoughs[index] = newDough;
                                    if (newDough != null) {
                                      speed1Timers[index] = newDough.speed1Time;
                                      speed2Timers[index] = newDough.speed2Time;
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 10),

                              // Display timer status
                              if (selectedDoughs[index] != null) ...[
                                Text('Speed 1: ${speed1Timers[index]}s remaining',
                                    style: TextStyle(
                                        color: isBlinking[index] ? Colors.red : Colors.black)),
                                Text('Speed 2: ${speed2Timers[index]}s remaining',
                                    style: TextStyle(
                                        color: isBlinking[index] ? Colors.red : Colors.black)),
                                const SizedBox(height: 10),

                                // Timer control buttons (Start/Resume, Pause, Stop, Delete, Acknowledge)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (!isBlinking[index])
                                      ElevatedButton(
                                        onPressed: isPaused[index]
                                            ? () => startOrResumeTimer(index) // Resume
                                            : () => startOrResumeTimer(index), // Start
                                        child: Text(isPaused[index] ? 'Resume' : 'Start'),
                                      ),
                                    if (isBlinking[index])
                                      ElevatedButton(
                                        onPressed: () => acknowledgeAlert(index),
                                        child: const Text('Acknowledge'),
                                      ),
                                    ElevatedButton(
                                      onPressed: () => pauseTimer(index),
                                      child: const Text('Pause'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => stopTimer(index),
                                      child: const Text('Stop'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => deleteTimer(index),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
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
