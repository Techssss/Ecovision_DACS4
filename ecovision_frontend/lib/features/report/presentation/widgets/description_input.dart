import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_providers.dart';

/// TextField mô tả chi tiết
class DescriptionInput extends ConsumerStatefulWidget {
  const DescriptionInput({super.key});

  @override
  ConsumerState<DescriptionInput> createState() => _DescriptionInputState();
}

class _DescriptionInputState extends ConsumerState<DescriptionInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider changes (from AI analysis)
    ref.listen(descriptionProvider, (previous, next) {
      if (next.isNotEmpty && _controller.text != next) {
        _controller.text = next;
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả chi tiết',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 5,
            onChanged: (value) {
              ref.read(descriptionProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: 'Mô tả tình trạng ô nhiễm bạn gặp phải...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
