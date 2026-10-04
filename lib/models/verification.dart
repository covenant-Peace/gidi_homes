import 'enums.dart';

/// An agent's identity-verification request (NIN or CAC).
/// Stored at verifications/{agentId} — one per agent.
class Verification {
  const Verification({
    required this.agentId,
    required this.agentName,
    required this.type,
    required this.idNumber,
    required this.createdAt,
    this.businessName,
    this.documentUrl,
    this.status = VerificationStatus.pending,
    this.reviewNote,
  });

  final String agentId;
  final String agentName;
  final VerificationType type;
  final String idNumber;
  final DateTime createdAt;
  final String? businessName;
  final String? documentUrl; // Cloudinary image of the ID/CAC cert
  final VerificationStatus status;
  final String? reviewNote;

  Map<String, dynamic> toMap() => {
        'agentId': agentId,
        'agentName': agentName,
        'type': type.name,
        'idNumber': idNumber,
        'createdAt': createdAt.toIso8601String(),
        'businessName': businessName,
        'documentUrl': documentUrl,
        'status': status.name,
        'reviewNote': reviewNote,
      };

  factory Verification.fromMap(Map<String, dynamic> m) => Verification(
        agentId: m['agentId'] as String? ?? '',
        agentName: m['agentName'] as String? ?? 'Agent',
        type: VerificationType.values.firstWhere(
          (t) => t.name == m['type'],
          orElse: () => VerificationType.nin,
        ),
        idNumber: m['idNumber'] as String? ?? '',
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        businessName: m['businessName'] as String?,
        documentUrl: m['documentUrl'] as String?,
        status: VerificationStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => VerificationStatus.pending,
        ),
        reviewNote: m['reviewNote'] as String?,
      );
}
