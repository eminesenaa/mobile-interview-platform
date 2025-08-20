// ===================== File: lib/pages/practice_page.dart =====================
// Purpose: Kullanıcının soru çözme pratiği yapacağı ana sayfa.
//          QuestionController üzerinden sorular çekilir, filtrelenir ve listelenir.
//
// Notlar:
// - GetX Obx kullanılarak reactive UI sağlanır (controller.filteredQuestions değiştikçe UI yenilenir).
// - ListView.builder ile dinamik soru kartları oluşturulur.
// - onTap: soru tipine göre ilgili sayfaya yönlendirilebilir.
// ==============================================================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/pages/question_types/fill_in_blank_page.dart';
import 'package:interview_project/pages/question_types/short_answer_page.dart';

import '../controllers/question_controller.dart';
import '../models/question.dart';
import '../widgets/get_started_card.dart';
import '../widgets/question_card.dart';
import '../widgets/topic_chip_scroll.dart';
import '../widgets/search_add_bar.dart';
import '../widgets/filter_popup.dart';
import '../constants/constants.dart';
import 'question_types/mcq_question_page.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı sayfaya bağla
    final QuestionController controller = Get.put(QuestionController());
    controller.loadDummyQuestions();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: pastelBlue,
        elevation: 0,
        title: Text(
          'Practice',
          style: AppTextStyles.headline,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SafeArea(
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Get Started Cards
              // Get Started Cards
              SizedBox(
                height: 150,
                child: PageView.builder(
                  // Kart başlıklarını burada kontrol edebilirsin
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final imgPath = 'assets/images/get_started_${index + 1}.jpg';
                    // Basit başlık örnekleri (istersen değiştir)
                    const titles = [
                      'Warm-up • Quick Win',
                      'Today’s Challenge',
                      'Revise Core Topics',
                      'Mock Interview Prep',
                      'Tips & Tricks'
                    ];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: GetStartedCard(
                        title: titles[index % titles.length],
                        imagePath: imgPath,
                        onTap: () {
                          // Şimdilik basit bir aksiyon; istersen soru listesine scroll/focus ekleyebiliriz
                          Get.snackbar('Let’s go!', 'Scroll down and start solving 🚀');
                        },
                      ),
                    );
                  },
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(12),
                child: Text("Today's Question",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Write a function to reverse a string.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          debugPrint('Solve link clicked!');
                        },
                        child: Text(
                          'Solve',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              TopicChipScroll(
                topics: ['All', 'Data Structures', 'Algorithms'],
                selectedTopic: controller.selectedTopic.value,
                onTopicSelected: (topic) {
                  controller.updateFilters(topic: topic);
                },
              ),

              const Divider(height: 24),

              SearchAddBar(
                searchText: controller.searchQuery.value,
                onSearchChanged: (val) => controller.updateSearch(val),
                onFilterPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) {
                      return FilterPopup(
                        topics: ['All', 'Data Structures', 'Algorithms'],
                        difficulties: [null, ...Difficulty.values],
                        statuses: [null, ...Status.values],
                        selectedTopic: controller.selectedTopic.value,
                        selectedDifficulty:
                        controller.selectedDifficulty.value,
                        selectedStatus: controller.selectedStatus.value,
                        onApply: ({
                          required topic,
                          required difficulty,
                          required status,
                        }) {
                          controller.updateFilters(
                            topic: topic,
                            difficulty: difficulty,
                            status: status,
                          );
                        },
                      );
                    },
                  );
                },
                onAddPressed: () {},
                onRandomPressed: () {
                  final random = controller.getRandomQuestion();
                  if (random != null) {
                    Get.snackbar("Random Question", random.title);
                  }
                },
                canAdd: controller.filteredQuestions.isNotEmpty,
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: controller.filteredQuestions.length,
                  itemBuilder: (context, index) {
                    final question = controller.filteredQuestions[index];
                    return QuestionCard(
                      question: question,
                      onTap: () {
                        switch (question.type) {
                          case QuestionType.mcq:
                            Get.to(() => McqQuestionPage(question: question));
                            break;
                          case QuestionType.shortAnswer:
                            Get.to(() => ShortAnswerPage(question: question));
                            break;
                          case QuestionType.coding:
                            Get.snackbar('Coming Soon', 'Coding Editor coming soon!');
                            break;
                          case QuestionType.fillBlank:
                            Get.to(() => FillInBlankPage(question: question));
                            break;
                          case QuestionType.debugging:
                            Get.snackbar('Coming Soon', 'Debugging environment coming soon!');
                            break;
                          default:
                            Get.snackbar('Not Implemented', 'This question type is unknown');
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}