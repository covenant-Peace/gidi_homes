enum InspectionStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  declined('Declined'),
  cancelled('Cancelled');

  const InspectionStatus(this.label);
  final String label;
}

/// A buyer's request to physically inspect a property at a chosen time.
class Inspection {
  const Inspection({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.agentId,
    required this.when,
    required this.createdAt,
    this.note = '',
    this.status = InspectionStatus.pending,
  });

  final String id;
  final String propertyId;
  final String propertyTitle;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String agentId;
  final DateTime when; // requested date/time
  final DateTime createdAt;
  final String note;
  final InspectionStatus status;

  Map<String, dynamic> toMap() => {
        'id': id,
        'propertyId': propertyId,
        'propertyTitle': propertyTitle,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'buyerPhone': buyerPhone,
        'agentId': agentId,
        'when': when.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'note': note,
        'status': status.name,
      };

  factory Inspection.fromMap(Map<String, dynamic> m) => Inspection(
        id: m['id'] as String? ?? '',
        propertyId: m['propertyId'] as String? ?? '',
        propertyTitle: m['propertyTitle'] as String? ?? '',
        buyerId: m['buyerId'] as String? ?? '',
        buyerName: m['buyerName'] as String? ?? 'Buyer',
        buyerPhone: m['buyerPhone'] as String? ?? '',
        agentId: m['agentId'] as String? ?? '',
        when: DateTime.tryParse(m['when'] as String? ?? '') ?? DateTime.now(),
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        note: m['note'] as String? ?? '',
        status: InspectionStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => InspectionStatus.pending,
        ),
      );
}
