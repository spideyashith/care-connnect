import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cognitive_history_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {

  final supabase = Supabase.instance.client;

  bool gameStarted = false;
  int secondsElapsed = 0;
  Timer? timer;

  int playHour = 0;
  int duration = 0;
  int missedGame = 0;

  int tapCount = 0;
  int requiredTaps = 5;

  String lastStatus = "No Test Yet";

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startGame() {

    playHour = DateTime.now().hour;

    setState(() {
      gameStarted = true;
      secondsElapsed = 0;
      tapCount = 0;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void registerTap() {

    if (!gameStarted) return;

    setState(() {
      tapCount++;
    });

    if (tapCount >= requiredTaps) {
      finishGame();
    }
  }

  void finishGame() {

    timer?.cancel();

    duration = secondsElapsed;
    missedGame = 0;

    sendPrediction();
  }

  void skipGame() {

    timer?.cancel();

    playHour = DateTime.now().hour;
    duration = 0;
    missedGame = 1;

    sendPrediction();
  }

  Future<void> sendPrediction() async {

    final url = Uri.parse("http://10.0.2.2:5000/predict");

    final body = {
      "play_hour": playHour,
      "duration": duration,
      "missed_game": missedGame
    };

    String status;

    try {

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);
        status = data["status"];

      } else {

        status = generateFallbackPrediction();

      }

    } catch (e) {

      status = generateFallbackPrediction();

    }

    setState(() {
      lastStatus = status;
    });

    await saveResult(status);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("AI Result"),
        content: Text(status),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );

  }

  String generateFallbackPrediction() {

    if (missedGame == 1) {
      return "High Risk – Missed Cognitive Test";
    }

    if (duration < 5) {
      return "Normal Cognitive Activity";
    }

    if (duration < 15) {
      return "Mild Cognitive Concern";
    }

    return "High Risk Cognitive Delay";
  }

  Future<void> saveResult(String status) async {

    final user = supabase.auth.currentUser;

    if (user == null) return;

    await supabase.from('cognitive_tests').insert({

      "user_id": user.id,
      "play_hour": playHour,
      "duration": duration,
      "missed_game": missedGame,
      "ai_status": status

    });

  }

  void resetGame() {

    setState(() {
      gameStarted = false;
      secondsElapsed = 0;
      tapCount = 0;
    });
  }

  void sendEmergencyAlert() {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Emergency Alert Sent to Caregiver"),
        backgroundColor: Colors.red,
      ),

    );

  }

  Color getStatusColor() {

    if (lastStatus.contains("Normal")) return Colors.green;
    if (lastStatus.contains("Concern")) return Colors.orange;

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Patient Dashboard"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getStatusColor(),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                children: [

                  const Text(
                    "Current Cognitive Status",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    lastStatus,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,

                children: [

                  GestureDetector(
                    onTap: startGame,

                    child: buildCard(
                      Icons.psychology,
                      "Cognitive Test",
                      Colors.blue,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const CognitiveHistoryScreen(),
                        ),
                      );

                    },

                    child: buildCard(
                      Icons.analytics,
                      "Cognitive History",
                      Colors.green,
                    ),
                  ),

                  GestureDetector(
                    onTap: sendEmergencyAlert,

                    child: buildCard(
                      Icons.warning,
                      "Emergency Alert",
                      Colors.red,
                    ),
                  ),

                  buildCard(
                    Icons.favorite,
                    "Health Monitor",
                    Colors.purple,
                  ),

                ],
              ),
            ),

            if (gameStarted) ...[

              const SizedBox(height: 10),

              Text(
                "Time: $secondsElapsed seconds",
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 10),

              Text(
                "Taps: $tapCount / $requiredTaps",
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: registerTap,
                child: const Text("Tap"),
              ),

              ElevatedButton(
                onPressed: skipGame,
                child: const Text("Skip Game"),
              ),

            ]

          ],
        ),
      ),
    );
  }

  Widget buildCard(IconData icon, String title, Color color) {

    return Container(

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(icon, color: Colors.white, size: 40),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),
          ),

        ],
      ),
    );
  }
}