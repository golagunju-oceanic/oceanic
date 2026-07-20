import 'package:flutter/material.dart';

class TelemedicineScaffold extends StatelessWidget {
  final Widget child;
  final int currentStep;

  const TelemedicineScaffold({
    required this.child,
    required this.currentStep,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          SizedBox(height: 50),
          // SafeArea(
          //   bottom: false,
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          //     child: Align(
          //       alignment: Alignment.centerLeft,
          //       child: ElevatedButton(
          //         onPressed: () =>
          //             Navigator.of(context).popUntil((r) => r.isFirst),
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: scheme.primary,
          //           foregroundColor: scheme.onPrimary,
          //           padding: const EdgeInsets.symmetric(
          //             horizontal: 20,
          //             vertical: 10,
          //           ),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(24),
          //           ),
          //           elevation: 0,
          //         ),
          //         child: const Text(
          //           'Back to App',
          //           style: TextStyle(fontSize: 13),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Divider(height: 1, color: scheme.onSurface.withValues(alpha: 0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: scheme.onSurface,
                  ),
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
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
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
