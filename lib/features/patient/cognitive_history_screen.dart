import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class CognitiveHistoryScreen extends StatefulWidget {
  const CognitiveHistoryScreen({super.key});

  @override
  State<CognitiveHistoryScreen> createState() => _CognitiveHistoryScreenState();
}

class _CognitiveHistoryScreenState extends State<CognitiveHistoryScreen> {

  final supabase = Supabase.instance.client;

  List records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {

    final user = supabase.auth.currentUser;

    if (user == null) return;

    final data = await supabase
        .from('cognitive_tests')
        .select()
        .eq('user_id', user.id)
        .order('created_at');

    setState(() {
      records = data;
      loading = false;
    });
  }

  List<FlSpot> buildSpots() {

    List<FlSpot> spots = [];

    for (int i = 0; i < records.length; i++) {

      final status = records[i]["ai_status"];

      double score = 0;

      if (status.contains("Normal")) score = 3;
      if (status.contains("Concern")) score = 2;
      if (status.contains("High")) score = 1;

      spots.add(FlSpot(i.toDouble(), score));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cognitive History"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
          ? const Center(child: Text("No cognitive tests yet"))
          : Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const Text(
              "Cognitive Trend",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,

              child: LineChart(

                LineChartData(

                  gridData: const FlGridData(show: true),

                  titlesData: const FlTitlesData(show: true),

                  borderData: FlBorderData(show: true),

                  lineBarsData: [

                    LineChartBarData(

                      spots: buildSpots(),

                      isCurved: true,

                      color: Colors.blue,

                      barWidth: 4,

                      dotData: const FlDotData(show: true),

                    )

                  ],

                ),

              ),
            ),

            const SizedBox(height: 30),

            Expanded(

              child: ListView.builder(

                itemCount: records.length,

                itemBuilder: (context, index) {

                  final record = records[index];

                  return Card(

                    child: ListTile(

                      title: Text(record["ai_status"]),

                      subtitle: Text(
                          "Duration: ${record["duration"]} sec"),

                      trailing: Text(
                        record["created_at"]
                            .toString()
                            .substring(0, 10),
                      ),

                    ),

                  );
                },

              ),

            )

          ],

        ),

      ),
    );
  }
}