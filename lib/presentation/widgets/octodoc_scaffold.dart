import 'package:flutter/material.dart';
import 'package:oceanic/core/constants/app_colors.dart';

class OctodocScaffold extends StatelessWidget {
  final Widget child;
  final int currentStep;

  const OctodocScaffold({
    required this.child,
    required this.currentStep,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kNavyBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to App',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.healing, color: Colors.red, size: 16),
                SizedBox(width: 4),
                Text(
                  'Powered by Octodoc',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(color: Colors.grey.shade200, height: 1),
          // Step header with back arrow and dots
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 22),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    4,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i + 1 == currentStep
                            ? kTeal
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content in a white card
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
