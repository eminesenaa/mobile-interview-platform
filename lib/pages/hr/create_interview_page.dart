// ===================== File: create_interview_page.dart =====================
// Purpose:
// HR creates a new interview session
//
// Notes:
// - Temporary UI (functional first)
// - Backend integration later
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';

class CreateInterviewPage extends StatefulWidget {
  const CreateInterviewPage({super.key});

  @override
  State<CreateInterviewPage> createState() => _CreateInterviewPageState();
}

class _CreateInterviewPageState extends State<CreateInterviewPage> {
  final titleCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
  final durationCtrl = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String inviteCode = "—";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Interview"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= TITLE =================
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Interview Title",
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ================= POSITION =================
              TextField(
                controller: positionCtrl,
                decoration: const InputDecoration(
                  labelText: "Position",
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ================= DATE =================
              ListTile(
                title: Text(
                  selectedDate == null
                      ? "Select Date"
                      : selectedDate.toString().split(" ")[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),

              // ================= TIME =================
              ListTile(
                title: Text(
                  selectedTime == null
                      ? "Select Time"
                      : selectedTime!.format(context),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (picked != null) {
                    setState(() => selectedTime = picked);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ================= DURATION =================
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Duration (minutes)",
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ================= QUESTIONS =================
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar("TODO", "Select from database");
                      },
                      child: const Text("From Database"),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar("TODO", "Manual question add");
                      },
                      child: const Text("Manual Add"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // ================= INVITE CODE =================
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Invite Code: $inviteCode"),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          inviteCode = _generateCode();
                        });
                      },
                      child: const Text("Generate"),
                    )
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ================= CREATE BUTTON =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createInterview,
                  child: const Text("Create Interview"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CREATE =================
  void _createInterview() {
    if (titleCtrl.text.isEmpty ||
        positionCtrl.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        durationCtrl.text.isEmpty ||
        inviteCode == "—") {
      Get.snackbar("Error", "Fill all fields");
      return;
    }

    Get.snackbar("Success", "Interview created (mock)");

    Get.back();
  }

  // ================= CODE GENERATOR =================
  String _generateCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return List.generate(
      6,
          (index) => chars[(chars.length * (index + 3) % chars.length)],
    ).join();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    positionCtrl.dispose();
    durationCtrl.dispose();
    super.dispose();
  }
}