import 'package:flutter/material.dart';

// IMPORTANT: If your files are in different folders, VS Code might show a red line under these imports.
// Click the red line and press Alt + Enter (or Ctrl + .) to auto-fix the import path.
import '../patient/patient_dashboard.dart';
import '../caregiver/caregiver_dashboard.dart';
import '../dashboard/doctor_dashboard.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Role"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Choose how you want to use CareConnect",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // 1. PATIENT BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientDashboard(),
                    ),
                  );
                },
                child: const Text("Patient", style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 20),

            // 2. CAREGIVER BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CaregiverDashboard(),
                    ),
                  );
                },
                child: const Text("Caregiver", style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 20),

            // 3. DOCTOR BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorDashboard(),
                    ),
                  );
                },
                child: const Text("Doctor", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}