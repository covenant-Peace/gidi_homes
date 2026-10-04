/// A 1:1 conversation between a buyer and an agent about a property.
class Chat {
  const Chat({
    required this.id,
    required this.participants,
    required this.buyerId,
    required this.agentId,
    required this.buyerName,
    required this.agentName,
    required this.propertyId,
    required this.propertyTitle,
    this.propertyImage,
    this.lastMessage = '',
    this.lastSenderId = '',
    required this.updatedAt,
  });

  final String id;
  final List<String> participants; // [buyerId, agentId]
  final String buyerId;
  final String agentId;
  final String buyerName;
  final String agentName;
  final String propertyId;
  final String propertyTitle;
  final String? propertyImage;
  final String lastMessage;
  final String lastSenderId;
  final DateTime updatedAt;

  /// Deterministic id so the same buyer+property always maps to one thread.
  static String makeId(String propertyId, String buyerId) =>
      '${propertyId}__$buyerId';

  String otherName(String uid) => uid == buyerId ? agentName : buyerName;

  Map<String, dynamic> toMap() => {
        'id': id,
        'participants': participants,
        'buyerId': buyerId,
        'agentId': agentId,
        'buyerName': buyerName,
        'agentName': agentName,
        'propertyId': propertyId,
        'propertyTitle': propertyTitle,
        'propertyImage': propertyImage,
        'lastMessage': lastMessage,
        'lastSenderId': lastSenderId,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Chat.fromMap(Map<String, dynamic> m) => Chat(
        id: m['id'] as String,
        participants: (m['participants'] as List?)?.cast<String>() ?? const [],
        buyerId: m['buyerId'] as String? ?? '',
        agentId: m['agentId'] as String? ?? '',
        buyerName: m['buyerName'] as String? ?? 'Buyer',
        agentName: m['agentName'] as String? ?? 'Agent',
        propertyId: m['propertyId'] as String? ?? '',
        propertyTitle: m['propertyTitle'] as String? ?? '',
        propertyImage: m['propertyImage'] as String?,
        lastMessage: m['lastMessage'] as String? ?? '',
        lastSenderId: m['lastSenderId'] as String? ?? '',
        updatedAt:
            DateTime.tryParse(m['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
        id: m['id'] as String? ?? '',
        senderId: m['senderId'] as String? ?? '',
        text: m['text'] as String? ?? '',
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
