import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'loading_screen.dart';

class OcrConfirmScreen extends StatefulWidget {
  final String ocrText;
  final String productType;
  const OcrConfirmScreen({
    super.key,
    required this.ocrText,
    required this.productType,
  });
  @override
  State<OcrConfirmScreen> createState() => _OcrConfirmScreenState();
}

class _OcrConfirmScreenState extends State<OcrConfirmScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.ocrText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Confirm extracted text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.green.withOpacity(0.3),
                ),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline, color: AppColors.green, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Review the scanned text. Edit anything that looks wrong, then tap Analyse.',
                    style: TextStyle(fontSize: 12, color: AppColors.green),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // Editable text field
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Scanned text appears here...',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Character count
            Text(
              '${_controller.text.length} characters',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.right,
            ),

            const SizedBox(height: 12),

            // Analyse button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No text to analyse. Please scan again.'),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LoadingScreen(
                        ocrText: text,
                        productType: widget.productType,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.science_outlined),
                label: const Text('Analyse ingredients'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
