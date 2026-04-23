import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final int _currentStep = 1;
  
  final List<VerificationStep> _steps = [
    VerificationStep('Personal Info', 'Verify your identity', Icons.person, true),
    VerificationStep('Documents', 'Upload required documents', Icons.description, false),
    VerificationStep('Background Check', 'Pending review', Icons.security, false),
    VerificationStep('Complete', 'Verification complete', Icons.check_circle, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verification Status'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status card
            _buildStatusCard(),
            const SizedBox(height: 24),
            
            // Progress steps
            _buildProgressSteps(),
            const SizedBox(height: 24),
            
            // Required documents
            _buildRequiredDocuments(),
            const SizedBox(height: 24),
            
            // Next steps
            _buildNextSteps(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.pending_actions,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Verification in Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your account is being verified. This process usually takes 1-3 business days.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(_steps.length, (index) {
          final step = _steps[index];
          return _buildStep(step, index);
        }),
      ),
    );
  }

  Widget _buildStep(VerificationStep step, int index) {
    final isCompleted = step.isCompleted;
    final isCurrent = index == _currentStep;
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Colors.green
                    : isCurrent
                        ? AppColors.primary
                        : AppColors.greyLight,
              ),
              child: Icon(
                isCompleted ? Icons.check : step.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted || isCurrent
                          ? AppColors.textPrimary
                          : AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (isCurrent && !isCompleted)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        if (index < _steps.length - 1)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
            child: Container(
              width: 2,
              height: 40,
              color: isCompleted ? Colors.green : AppColors.greyLight,
            ),
          ),
      ],
    );
  }

  Widget _buildRequiredDocuments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDocumentItem(
            'National ID',
            'Upload your valid national ID',
            Icons.credit_card,
            'Uploaded',
            Colors.green,
            true,
          ),
          _buildDocumentItem(
            'Driving License',
            'Valid driving license',
            Icons.drive_eta,
            'Uploaded',
            Colors.green,
            true,
          ),
          _buildDocumentItem(
            'Vehicle Registration',
            'Vehicle registration document',
            Icons.description,
            'Pending',
            Colors.orange,
            false,
          ),
          _buildDocumentItem(
            'Insurance Certificate',
            'Valid vehicle insurance',
            Icons.security,
            'Not Uploaded',
            Colors.red,
            false,
          ),
          _buildDocumentItem(
            'Profile Photo',
            'Clear profile picture',
            Icons.camera_alt,
            'Uploaded',
            Colors.green,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(
    String title,
    String subtitle,
    IconData icon,
    String status,
    Color statusColor,
    bool isUploaded,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10, color: statusColor),
                ),
              ),
              const SizedBox(height: 4),
              if (!isUploaded)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Upload',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Steps',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTip('Complete all document uploads'),
          _buildTip('Wait for verification (1-3 business days)'),
          _buildTip('You will receive notification once verified'),
          _buildTip('Contact support if verification takes longer'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class VerificationStep {
  final String title;
  final String subtitle;
  final IconData icon;
  bool isCompleted;

  VerificationStep(this.title, this.subtitle, this.icon, this.isCompleted);
} 
