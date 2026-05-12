import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:oceanic/firebase_auth/auth_services.dart';
import 'package:oceanic/presentation/features/home/viewSample/auth_screen.dart';

class DeleteProfilePage extends StatefulWidget {
  const DeleteProfilePage({super.key});

  @override
  State<DeleteProfilePage> createState() => _DeleteProfilePageState();
}

class _DeleteProfilePageState extends State<DeleteProfilePage> {
  static const _navy = Color(0xFF2D2D8E);
  static const _danger = Color(0xFFE05252);

  final List<String> _reasons = [
    'I am no longer an enrollee',
    'The Application is not user-friendly',
    'Other',
  ];

  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              children: [
                const Text(
                  "We're sorry to see you go!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "We wanted to take a moment to say thank you for being a part of our community. "
                  "We're sorry to see you leave, but we respect your decision.",
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "If you have any feedback on your experience or if there's anything we could have "
                  "done better, we'd love to hear from you. Your insights are valuable to us!",
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Remember, you're always welcome back!",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // Reason checkboxes
                ...List.generate(_reasons.length, (i) {
                  final checked = _selected.contains(i);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        checked ? _selected.remove(i) : _selected.add(i);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: checked
                              ? _navy.withOpacity(0.06)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: checked ? _navy : Colors.grey.shade200,
                            width: checked ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: checked ? _navy : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: checked ? _navy : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                              ),
                              child: checked
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _reasons[i],
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: checked
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: checked ? _navy : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 32),

                // Delete button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _selected.isEmpty
                        ? null
                        : () => _confirmDelete(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _danger,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _selected.isEmpty
                            ? Colors.grey.shade500
                            : Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: Text(
                      'Keep my account',
                      style: TextStyle(
                        fontSize: 14,
                        color: _navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogueContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This is permanent and cannot be undone. Your data will be removed.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogueContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AuthServices().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFE05252),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  static const _navy = Color(0xFF2D2D8E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.chevron_left,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
