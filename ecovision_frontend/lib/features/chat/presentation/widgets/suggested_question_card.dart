import 'package:flutter/material.dart';
import '../../domain/models/suggested_questions.dart';

/// Card câu hỏi gợi ý
class SuggestedQuestionCard extends StatelessWidget {
  final SuggestedQuestion question;
  final VoidCallback onTap;

  const SuggestedQuestionCard({
    super.key,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              question.icon,
              color: const Color(0xFF00D9A3),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question.text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
