import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';
import '../../models/question.dart';

class McqQuestionPage extends StatefulWidget {
  final Question question;

  const McqQuestionPage({super.key, required this.question});

  @override
  State<McqQuestionPage> createState() => _McqQuestionPageState();
}

class _McqQuestionPageState extends State<McqQuestionPage> {
  String? selectedOption;
  bool isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final question = widget.question;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question',
            style: AppTextStyles.headline.copyWith(color: Colors.white)),
        backgroundColor: pastelBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.title,
              style: AppTextStyles.headline,
            ),
            const SizedBox(height: 24),

            // Options
            ...?question.options?.map((option) {
              final isSelected = option == selectedOption;
              final isCorrect = option == question.correctAnswer;
              final isWrong = isSubmitted && isSelected && !isCorrect;

              return GestureDetector(
                onTap: isSubmitted
                    ? null
                    : () {
                  setState(() {
                    selectedOption = option;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isSubmitted
                        ? (isCorrect
                        ? Colors.green.shade100
                        : Colors.red.shade100)
                        : Colors.blue.shade50)
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: isSubmitted
                          ? (isCorrect
                          ? Colors.green
                          : (isWrong ? Colors.red : Colors.grey))
                          : Colors.grey,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSubmitted && isCorrect
                          ? Colors.green.shade700
                          : isWrong
                          ? Colors.red.shade700
                          : Colors.black,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              );
            }).toList(),

            const Spacer(),

            // Submit / Feedback
            if (!isSubmitted)
              ElevatedButton(
                onPressed: selectedOption == null
                    ? null
                    : () {
                  setState(() {
                    isSubmitted = true;
                  });
                },
                child: const Text('Send'),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedOption == question.correctAnswer
                        ? 'Correct! 🎉'
                        : 'Wrong ❌',
                    style: AppTextStyles.headline.copyWith(
                      color: selectedOption == question.correctAnswer
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correct answer: ${question.correctAnswer}',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}