import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_providers.dart';
import '../../data/utils/location_helper.dart';

/// Nút gửi báo cáo
class SubmitButton extends ConsumerWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedPollutionProvider);
    final isSubmitting = ref.watch(isSubmittingReportProvider);
    final hasImage = ref.watch(selectedImageProvider) != null;
    final hasDescription = ref.watch(descriptionProvider).isNotEmpty;

    // Validate: Phải chọn loại ô nhiễm HOẶC có ảnh/description
    // (Nếu có ảnh, AI sẽ tự detect type)
    final isValid = (selectedType != null || hasImage || hasDescription) && !isSubmitting;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.send, color: Colors.white),
        label: Text(
          isSubmitting ? 'Đang gửi...' : 'Gửi báo cáo',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isValid ? const Color(0xFF00D9A3) : Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isValid ? 2 : 0,
        ),
        onPressed: isValid ? () => _submitReport(context, ref) : null,
      ),
    );
  }

  Future<void> _submitReport(BuildContext context, WidgetRef ref) async {
    final selectedType = ref.read(selectedPollutionProvider);
    final description = ref.read(descriptionProvider);
    final location = ref.read(currentLocationProvider);
    final coordinates = ref.read(currentCoordinatesProvider);
    final image = ref.read(selectedImageProvider);
    final repository = ref.read(reportRepositoryProvider);

    // If no type selected, use default "trash" (most common)
    final reportType = selectedType ?? 'trash';

    // Set submitting state
    ref.read(isSubmittingReportProvider.notifier).state = true;

    try {
      // Use GPS coordinates if available, otherwise use mock from location string
      final coords = coordinates ?? LocationHelper.getCoordinatesFromLocation(location);

      // Chuẩn bị danh sách ảnh
      final images = image != null ? [image] : null;

      // Gửi report
      final report = await repository.createReport(
        type: reportType,
        description: description.isNotEmpty ? description : null,
        latitude: coords['latitude']!,
        longitude: coords['longitude']!,
        address: location,
        severity: 'medium',
        images: images,
      );

      // Invalidate user reports để refresh danh sách
      ref.invalidate(userReportsProvider);

      // Reset form
      _resetForm(ref);

      // Show success dialog with AI analysis
      if (context.mounted) {
        _showSuccessDialog(
          context, 
          report.trackingCode,
          report.description,
        );
      }
    } catch (e) {
      // Show error dialog
      if (context.mounted) {
        _showErrorDialog(context, 'Lỗi: ${e.toString()}');
      }
    } finally {
      // Reset submitting state
      ref.read(isSubmittingReportProvider.notifier).state = false;
    }
  }

  void _showSuccessDialog(
    BuildContext context, 
    String? trackingCode,
    String? aiDescription,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00D9A3), size: 28),
            SizedBox(width: 12),
            Text('Thành công'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Báo cáo của bạn đã được gửi đi!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              
              // AI Analysis Section
              if (aiDescription != null && aiDescription.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00D9A3).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFF00D9A3), size: 18),
                          SizedBox(width: 6),
                          Text(
                            'AI Phân Tích',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00D9A3),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        aiDescription,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Không phát hiện được đối tượng trong ảnh. Admin sẽ xem xét báo cáo.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Tracking Code
              if (trackingCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Mã theo dõi: ',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        trackingCode,
                        style: const TextStyle(
                          color: Color(0xFF00D9A3),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF00D9A3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Lỗi'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm(WidgetRef ref) {
    ref.read(selectedPollutionProvider.notifier).state = null;
    ref.read(descriptionProvider.notifier).state = '';
    ref.read(selectedImageProvider.notifier).state = null;
    // Don't reset location - keep GPS coordinates
  }
}
