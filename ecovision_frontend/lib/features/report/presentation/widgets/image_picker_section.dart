import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../providers/report_providers.dart';
import '../../../auth/data/services/auth_service.dart';

/// Section chụp/chọn ảnh với AI analysis
class ImagePickerSection extends ConsumerWidget {
  const ImagePickerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = ref.watch(selectedImageProvider);
    final isAnalyzing = ref.watch(isAnalyzingProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          if (selectedImage == null) ...[
            // Empty state
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Thêm ảnh (tùy chọn)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nhấn để chọn ảnh từ thư viện',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ] else ...[
            // Image preview
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                selectedImage,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            if (isAnalyzing)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI đang phân tích ảnh...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00D9A3),
                    ),
                  ),
                ],
              ),
          ],
          const SizedBox(height: 16),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Thư viện'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () => _pickImage(context, ref, ImageSource.gallery),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Chụp ảnh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () => _pickImage(context, ref, ImageSource.camera),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        final File imageFile = File(image.path);
        ref.read(selectedImageProvider.notifier).state = imageFile;

        // Mock AI analysis
        await _mockAIAnalysis(context, ref);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _mockAIAnalysis(BuildContext context, WidgetRef ref) async {
    // Show loading
    ref.read(isAnalyzingProvider.notifier).state = true;

    try {
      // Get selected image
      final imageFile = ref.read(selectedImageProvider);
      if (imageFile == null) {
        throw Exception('No image selected');
      }

      // Call real API to analyze image
      // Get token from AuthService
      final authService = AuthService();
      final token = await authService.getAccessToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      // Create multipart request
      final url = Uri.parse('${AuthService.baseUrl}/reports/analyze-image');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add image file
      final imageBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];
        
        // Get AI-generated description
        final aiDescription = data['description'] as String?;
        final detectionCount = data['detection_count'] as int? ?? 0;

        // Auto-fill description if AI detected something
        if (aiDescription != null && aiDescription.isNotEmpty) {
          ref.read(descriptionProvider.notifier).state = aiDescription;
          
          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('AI phát hiện $detectionCount đối tượng!'),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF00D9A3),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          // No detections found
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Không phát hiện được đối tượng. Vui lòng nhập mô tả thủ công.'),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        throw Exception('Failed to analyze image');
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi phân tích ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Hide loading
      ref.read(isAnalyzingProvider.notifier).state = false;
    }
  }
}
