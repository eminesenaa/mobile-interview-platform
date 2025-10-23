import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/colors.dart';
import 'controllers/exam_controller.dart';

/// Sınav değerlendirme sürerken gösterilen tam ekran loading.
/// - Değerlendirme ve sonuç sayfasına geçişi ExamController.submit(...) yapar.
/// - Bu sayfa sadece süreci başlatır ve spinner gösterir.
/// - FutureBuilder, min 650ms bekleme + submit işlemini birlikte bekler.
class ResultLoadingPage extends StatefulWidget {
  /// ExamController'ı bulmak için kullanılan tag (ExamPage'de: tag: exam.id)
  final String controllerTag;

  /// süre bitimiyle mi geldi?
  final bool autoSubmit;

  const ResultLoadingPage({
    super.key,
    required this.controllerTag,
    this.autoSubmit = false,
  });

  @override
  State<ResultLoadingPage> createState() => _ResultLoadingPageState();
}

class _ResultLoadingPageState extends State<ResultLoadingPage> {
  late final ExamController c;
  Object? _error; // hata olursa göstermek için
  bool _started = false;

  @override
  void initState() {
    super.initState();

    c = Get.find<ExamController>(tag: widget.controllerTag);
    // build tamamlandıktan sonra başlat → build sırasında Obx refresh çakışmaz
    WidgetsBinding.instance.addPostFrameCallback((_) => _kickoff());
  }

  Future<void> _kickoff() async {
    if (_started) return;
    _started = true;
    try {
      // “flicker”ı önlemek için min. 650ms göster
      await Future.wait<void>([
        c.submit(auto: widget.autoSubmit), // yönlendirmeyi kendi yapıyor
        Future.delayed(const Duration(milliseconds: 650)),
      ]);
      // Not: submit başarıyla biterse bu sayfa Get.offAll ile zaten kapanır.
    } catch (e) {
      // submit bir exception fırlatırsa error UI göster
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // geri kapalı
      child: Scaffold(
        body: _error == null ? _buildLoading() : _buildError(_error),
      ),
    );
  }

  Widget _buildLoading() {
    return const SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Spinner
              CircularProgressIndicator(
                color: primaryColor, // uygulamanın primary rengi
                strokeWidth: 4,
              ),
              const SizedBox(height: 20),
              // Başlık (spinner ALTINDA)
              const Text(
                'Analyzing your answers…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              // Açıklama
              const Text(
                'This may take a few seconds. Please keep the app open.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Bir sorun oluştu. Değerlendirme tamamlanamadı.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Get.back(), // ExamPage’e dön
                  child: const Text('Geri dön'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _error = null);
                    _started = false;
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _kickoff());
                  },
                  child: const Text('Tekrar dene'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
