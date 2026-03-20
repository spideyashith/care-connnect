import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {

  final supabase = Supabase.instance.client;

  List records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {

    try {

      final data = await supabase
          .from('cognitive_tests')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        records = data ?? [];
        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Database error: $e")),
      );

    }
  }

  Future<void> logout() async {

    await supabase.auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  Widget buildStatusCard() {

    if (records.isEmpty) {

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "No patient cognitive data available yet.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final latest = records.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Latest Cognitive Status",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            latest["ai_status"] ?? "Unknown",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Duration: ${latest["duration"]} sec",
            style: const TextStyle(color: Colors.white),
          ),

        ],
      ),
    );
  }

  Widget buildHistoryList() {

    if (records.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text("No history available"),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(

        itemCount: records.length,

        itemBuilder: (context, index) {

          final record = records[index];

          return Card(
            child: ListTile(

              leading: const Icon(Icons.psychology),

              title: Text(record["ai_status"] ?? "Unknown"),

              subtitle: Text(
                  "Duration: ${record["duration"]} sec"),

              trailing: Text(
                record["created_at"]
                    .toString()
                    .substring(0,10),
              ),

            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Caregiver Dashboard"),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            buildStatusCard(),

            const SizedBox(height: 20),

            const Text(
              "Patient Cognitive History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildHistoryList(),

          ],
        ),
      ),
    );
  }
}