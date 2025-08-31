// lib/services/ai/app_bindings.dart
import 'package:get/get.dart';
import 'ai_service.dart';
import '../../controllers/question_controller.dart';
import 'ai_config.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AiService>(
      AiService(
        provider: AiConfig.provider,
        defaultPromptType: AiConfig.defaultPromptType,
      ),
      permanent: true,
    );

    Get.put<QuestionController>(QuestionController(), permanent: true);
  }
}
