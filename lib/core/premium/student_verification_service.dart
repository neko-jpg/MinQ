import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';

class StudentVerificationService {
  final PremiumService _premiumService;
  final LocalStorageService _localStorage;

  StudentVerificationService(this._premiumService, this._localStorage);

  Future<bool> isEligibleForStudentPlan() async {
    final currentTier = await _premiumService.getCurrentTier();
    return currentTier == PremiumTier.free || currentTier == PremiumTier.basic;
  }

  Future<StudentVerificationStatus> getVerificationStatus() async {
    return await _premiumService.getStudentVerificationStatus();
  }

  Future<StudentVerification?> getCurrentVerification() async {
    try {
      final verificationData = await _localStorage.getString('student_verification');
      if (verificationData == null) return null;
      
      final json = Map<String, dynamic>.from(verificationData as Map);
      return StudentVerification.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getSupportedSchools() async {
    // Mock implementation - would fetch from actual database
    return [
      'University of Tokyo',
      'Kyoto University',
      'Osaka University',
      'Tohoku University',
      'Nagoya University',
      'Hokkaido University',
      'Kyushu University',
      'Tokyo Institute of Technology',
      'Waseda University',
      'Keio University',
      'Sophia University',
      'International Christian University',
      'Temple University Japan',
      'Ritsumeikan University',
      'Doshisha University',
    ];
  }

  Future<List<String>> getAcceptedDocumentTypes() async {
    return [
      'Student ID Card',
      'Enrollment Certificate',
      'Class Schedule',
      'Transcript',
      'Tuition Receipt',
      'Library Card',
      'Student Email Verification',
    ];
  }

  Future<StudentVerificationResult> submitVerification({
    required String schoolName,
    required String studentId,
    required String studentEmail,
    required String documentType,
    required File documentFile,
    required DateTime expectedGraduation,
    String? additionalNotes,
  }) async {
    if (!await isEligibleForStudentPlan()) {
      return StudentVerificationResult.failure(
        'Not eligible for student plan verification'
      );
    }

    try {
      // Validate inputs
      final validationResult = await _validateVerificationData(
        schoolName: schoolName,
        studentId: studentId,
        studentEmail: studentEmail,
        documentType: documentType,
        documentFile: documentFile,
        expectedGraduation: expectedGraduation,
      );

      if (!validationResult.isValid) {
        return StudentVerificationResult.failure(validationResult.errorMessage!);
      }

      // Upload document (mock implementation)
      final documentUrl = await _uploadDocument(documentFile);

      // Create verification record
      final verification = StudentVerification(
        id: _generateVerificationId(),
        schoolName: schoolName,
        studentId: studentId,
        studentEmail: studentEmail,
        documentType: documentType,
        documentUrl: documentUrl,
        expectedGraduation: expectedGraduation,
        additionalNotes: additionalNotes,
        submittedAt: DateTime.now(),
        status: StudentVerificationStatus.pending,
        reviewNotes: null,
        reviewedAt: null,
        reviewedBy: null,
        expiresAt: expectedGraduation,
      );

      // Save verification
      await _saveVerification(verification);

      // Submit to verification service (mock implementation)
      await _submitToVerificationService(verification);

      return StudentVerificationResult.success(
        verification: verification,
        message: 'Verification submitted successfully. You will receive an email within 2-3 business days.',
      );
    } catch (e) {
      return StudentVerificationResult.failure(
        'Failed to submit verification: $e'
      );
    }
  }

  Future<StudentVerificationResult> resubmitVerification({
    required String verificationId,
    String? newDocumentType,
    File? newDocumentFile,
    String? additionalNotes,
  }) async {
    final currentVerification = await getCurrentVerification();
    
    if (currentVerification == null || currentVerification.id != verificationId) {
      return StudentVerificationResult.failure('Verification not found');
    }

    if (currentVerification.status != StudentVerificationStatus.rejected) {
      return StudentVerificationResult.failure('Can only resubmit rejected verifications');
    }

    try {
      String documentUrl = currentVerification.documentUrl;
      String documentType = currentVerification.documentType;

      // Upload new document if provided
      if (newDocumentFile != null) {
        documentUrl = await _uploadDocument(newDocumentFile);
      }

      if (newDocumentType != null) {
        documentType = newDocumentType;
      }

      // Update verification
      final updatedVerification = currentVerification.copyWith(
        documentType: documentType,
        documentUrl: documentUrl,
        additionalNotes: additionalNotes ?? currentVerification.additionalNotes,
        submittedAt: DateTime.now(),
        status: StudentVerificationStatus.pending,
        reviewNotes: null,
        reviewedAt: null,
        reviewedBy: null,
      );

      await _saveVerification(updatedVerification);
      await _submitToVerificationService(updatedVerification);

      return StudentVerificationResult.success(
        verification: updatedVerification,
        message: 'Verification resubmitted successfully.',
      );
    } catch (e) {
      return StudentVerificationResult.failure(
        'Failed to resubmit verification: $e'
      );
    }
  }

  Future<bool> cancelVerification() async {
    final verification = await getCurrentVerification();
    if (verification == null) return false;

    if (verification.status != StudentVerificationStatus.pending) {
      return false;
    }

    final cancelledVerification = verification.copyWith(
      status: StudentVerificationStatus.rejected,
      reviewNotes: 'Cancelled by user',
      reviewedAt: DateTime.now(),
    );

    await _saveVerification(cancelledVerification);
    return true;
  }

  Future<StudentDiscountInfo> getDiscountInfo() async {
    final tier = await _premiumService.getCurrentTier();
    
    if (tier != PremiumTier.student) {
      return StudentDiscountInfo(
        isEligible: await isEligibleForStudentPlan(),
        discountPercentage: 50,
        originalMonthlyPrice: 9.99,
        discountedMonthlyPrice: 4.99,
        originalYearlyPrice: 99.99,
        discountedYearlyPrice: 39.99,
        savings: const StudentSavings(
          monthlyAmount: 5.00,
          yearlyAmount: 60.00,
          totalSavingsPerYear: 60.00,
        ),
        benefits: _getStudentBenefits(),
        requirements: _getStudentRequirements(),
      );
    }

    // Already a student plan user
    final verification = await getCurrentVerification();
    return StudentDiscountInfo(
      isEligible: true,
      discountPercentage: 50,
      originalMonthlyPrice: 9.99,
      discountedMonthlyPrice: 4.99,
      originalYearlyPrice: 99.99,
      discountedYearlyPrice: 39.99,
      savings: const StudentSavings(
        monthlyAmount: 5.00,
        yearlyAmount: 60.00,
        totalSavingsPerYear: 60.00,
      ),
      benefits: _getStudentBenefits(),
      requirements: _getStudentRequirements(),
      currentVerification: verification,
      expiresAt: verification?.expiresAt,
    );
  }

  Future<List<StudentTip>> getStudentTips() async {
    return [
      const StudentTip(
        id: 'study_habits',
        title: 'Build Study Habits',
        description: 'Use MinQ to build consistent study routines that will improve your academic performance.',
        category: 'Academic',
        icon: 'school',
      ),
      const StudentTip(
        id: 'time_management',
        title: 'Master Time Management',
        description: 'Create quests for assignment deadlines and exam preparation to stay organized.',
        category: 'Productivity',
        icon: 'schedule',
      ),
      const StudentTip(
        id: 'health_balance',
        title: 'Maintain Health Balance',
        description: 'Don\'t forget to include exercise, sleep, and nutrition habits alongside your studies.',
        category: 'Wellness',
        icon: 'favorite',
      ),
      const StudentTip(
        id: 'social_connections',
        title: 'Stay Connected',
        description: 'Use family features to stay connected with family and study groups.',
        category: 'Social',
        icon: 'people',
      ),
      const StudentTip(
        id: 'financial_habits',
        title: 'Build Financial Habits',
        description: 'Start building good financial habits early with budgeting and saving quests.',
        category: 'Finance',
        icon: 'savings',
      ),
    ];
  }

  Future<bool> renewStudentStatus() async {
    final verification = await getCurrentVerification();
    if (verification == null) return false;

    if (verification.status != StudentVerificationStatus.verified) {
      return false;
    }

    // Check if renewal is needed (within 30 days of expiration)
    final daysUntilExpiration = verification.expiresAt.difference(DateTime.now()).inDays;
    if (daysUntilExpiration > 30) {
      return false; // Too early to renew
    }

    // Create renewal verification
    final renewalVerification = verification.copyWith(
      id: _generateVerificationId(),
      submittedAt: DateTime.now(),
      status: StudentVerificationStatus.pending,
      reviewNotes: null,
      reviewedAt: null,
      reviewedBy: null,
      expiresAt: DateTime.now().add(const Duration(days: 365)), // Extend for another year
    );

    await _saveVerification(renewalVerification);
    await _submitToVerificationService(renewalVerification);

    return true;
  }

  // Private helper methods
  Future<ValidationResult> _validateVerificationData({
    required String schoolName,
    required String studentId,
    required String studentEmail,
    required String documentType,
    required File documentFile,
    required DateTime expectedGraduation,
  }) async {
    // Validate school name
    final supportedSchools = await getSupportedSchools();
    if (!supportedSchools.contains(schoolName)) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'School not in our supported list. Please contact support.',
      );
    }

    // Validate student email domain
    if (!_isValidStudentEmail(studentEmail, schoolName)) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'Please use your official student email address.',
      );
    }

    // Validate document type
    final acceptedTypes = await getAcceptedDocumentTypes();
    if (!acceptedTypes.contains(documentType)) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'Document type not accepted.',
      );
    }

    // Validate file
    if (!await documentFile.exists()) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'Document file not found.',
      );
    }

    final fileSize = await documentFile.length();
    if (fileSize > 10 * 1024 * 1024) { // 10MB limit
      return const ValidationResult(
        isValid: false,
        errorMessage: 'Document file too large. Maximum size is 10MB.',
      );
    }

    // Validate graduation date
    if (expectedGraduation.isBefore(DateTime.now())) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'Expected graduation date must be in the future.',
      );
    }

    return const ValidationResult(isValid: true);
  }

  bool _isValidStudentEmail(String email, String schoolName) {
    // Mock validation - would implement actual domain checking
    final domain = email.split('@').last.toLowerCase();
    
    // Common academic domains
    final academicDomains = [
      'edu', 'ac.jp', 'u-tokyo.ac.jp', 'kyoto-u.ac.jp',
      'osaka-u.ac.jp', 'tohoku.ac.jp', 'nagoya-u.ac.jp',
      'hokudai.ac.jp', 'kyushu-u.ac.jp', 'titech.ac.jp',
      'waseda.jp', 'keio.jp', 'sophia.ac.jp', 'icu.ac.jp',
    ];
    
    return academicDomains.any((d) => domain.contains(d));
  }

  Future<String> _uploadDocument(File documentFile) async {
    // Mock implementation - would upload to actual cloud storage
    await Future.delayed(const Duration(seconds: 2));
    return 'https://storage.minq.app/documents/${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  Future<void> _submitToVerificationService(StudentVerification verification) async {
    // Mock implementation - would submit to actual verification service
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _saveVerification(StudentVerification verification) async {
    final verificationJson = jsonEncode(verification.toJson());
    await _localStorage.setString('student_verification', verificationJson);
  }

  String _generateVerificationId() {
    return 'sv_${DateTime.now().millisecondsSinceEpoch}';
  }

  List<String> _getStudentBenefits() {
    return [
      'All Premium features at 50% off',
      'Study-focused quest templates',
      'Academic calendar integration',
      'Extended trial periods',
      'Priority customer support',
      'Student community access',
    ];
  }

  List<String> _getStudentRequirements() {
    return [
      'Valid student ID or enrollment certificate',
      'Official student email address',
      'Currently enrolled in an accredited institution',
      'Verification renewal required annually',
    ];
  }
}

class StudentVerification {
  final String id;
  final String schoolName;
  final String studentId;
  final String studentEmail;
  final String documentType;
  final String documentUrl;
  final DateTime expectedGraduation;
  final String? additionalNotes;
  final DateTime submittedAt;
  final StudentVerificationStatus status;
  final String? reviewNotes;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final DateTime expiresAt;

  const StudentVerification({
    required this.id,
    required this.schoolName,
    required this.studentId,
    required this.studentEmail,
    required this.documentType,
    required this.documentUrl,
    required this.expectedGraduation,
    this.additionalNotes,
    required this.submittedAt,
    required this.status,
    this.reviewNotes,
    this.reviewedAt,
    this.reviewedBy,
    required this.expiresAt,
  });

  StudentVerification copyWith({
    String? documentType,
    String? documentUrl,
    String? additionalNotes,
    DateTime? submittedAt,
    StudentVerificationStatus? status,
    String? reviewNotes,
    DateTime? reviewedAt,
    String? reviewedBy,
    DateTime? expiresAt,
  }) {
    return StudentVerification(
      id: id,
      schoolName: schoolName,
      studentId: studentId,
      studentEmail: studentEmail,
      documentType: documentType ?? this.documentType,
      documentUrl: documentUrl ?? this.documentUrl,
      expectedGraduation: expectedGraduation,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'schoolName': schoolName,
    'studentId': studentId,
    'studentEmail': studentEmail,
    'documentType': documentType,
    'documentUrl': documentUrl,
    'expectedGraduation': expectedGraduation.toIso8601String(),
    'additionalNotes': additionalNotes,
    'submittedAt': submittedAt.toIso8601String(),
    'status': status.name,
    'reviewNotes': reviewNotes,
    'reviewedAt': reviewedAt?.toIso8601String(),
    'reviewedBy': reviewedBy,
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory StudentVerification.fromJson(Map<String, dynamic> json) => StudentVerification(
    id: json['id'],
    schoolName: json['schoolName'],
    studentId: json['studentId'],
    studentEmail: json['studentEmail'],
    documentType: json['documentType'],
    documentUrl: json['documentUrl'],
    expectedGraduation: DateTime.parse(json['expectedGraduation']),
    additionalNotes: json['additionalNotes'],
    submittedAt: DateTime.parse(json['submittedAt']),
    status: StudentVerificationStatus.values.firstWhere(
      (s) => s.name == json['status'],
    ),
    reviewNotes: json['reviewNotes'],
    reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
    reviewedBy: json['reviewedBy'],
    expiresAt: DateTime.parse(json['expiresAt']),
  );
}

class StudentVerificationResult {
  final bool isSuccess;
  final StudentVerification? verification;
  final String? message;
  final String? errorMessage;

  const StudentVerificationResult._({
    required this.isSuccess,
    this.verification,
    this.message,
    this.errorMessage,
  });

  factory StudentVerificationResult.success({
    required StudentVerification verification,
    String? message,
  }) {
    return StudentVerificationResult._(
      isSuccess: true,
      verification: verification,
      message: message,
    );
  }

  factory StudentVerificationResult.failure(String errorMessage) {
    return StudentVerificationResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

class StudentDiscountInfo {
  final bool isEligible;
  final int discountPercentage;
  final double originalMonthlyPrice;
  final double discountedMonthlyPrice;
  final double originalYearlyPrice;
  final double discountedYearlyPrice;
  final StudentSavings savings;
  final List<String> benefits;
  final List<String> requirements;
  final StudentVerification? currentVerification;
  final DateTime? expiresAt;

  const StudentDiscountInfo({
    required this.isEligible,
    required this.discountPercentage,
    required this.originalMonthlyPrice,
    required this.discountedMonthlyPrice,
    required this.originalYearlyPrice,
    required this.discountedYearlyPrice,
    required this.savings,
    required this.benefits,
    required this.requirements,
    this.currentVerification,
    this.expiresAt,
  });
}

class StudentSavings {
  final double monthlyAmount;
  final double yearlyAmount;
  final double totalSavingsPerYear;

  const StudentSavings({
    required this.monthlyAmount,
    required this.yearlyAmount,
    required this.totalSavingsPerYear,
  });
}

class StudentTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;

  const StudentTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
  });
}

final studentVerificationServiceProvider = Provider<StudentVerificationService>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return StudentVerificationService(premiumService, localStorage);
});

final studentVerificationStatusProvider = FutureProvider<StudentVerificationStatus>((ref) {
  final studentService = ref.watch(studentVerificationServiceProvider);
  return studentService.getVerificationStatus();
});

final currentStudentVerificationProvider = FutureProvider<StudentVerification?>((ref) {
  final studentService = ref.watch(studentVerificationServiceProvider);
  return studentService.getCurrentVerification();
});

final studentDiscountInfoProvider = FutureProvider<StudentDiscountInfo>((ref) {
  final studentService = ref.watch(studentVerificationServiceProvider);
  return studentService.getDiscountInfo();
});

final studentTipsProvider = FutureProvider<List<StudentTip>>((ref) {
  final studentService = ref.watch(studentVerificationServiceProvider);
  return studentService.getStudentTips();
});

final supportedSchoolsProvider = FutureProvider<List<String>>((ref) {
  final studentService = ref.watch(studentVerificationServiceProvider);
  return studentService.getSupportedSchools();
});