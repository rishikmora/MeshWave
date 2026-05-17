enum MessageState { queued, sent, relayed, delivered, failed }

class StoredMessage {
  const StoredMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.recipientId,
    required this.body,
    required this.createdAt,
    required this.state,
    this.priority = 'normal',
    this.encryptedPayload,
    this.sequence = 0,
    this.hopCount = 0,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String recipientId;
  final String body;
  final DateTime createdAt;
  final MessageState state;
  final String priority;
  final String? encryptedPayload;
  final int sequence;
  final int hopCount;

  StoredMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? recipientId,
    String? body,
    DateTime? createdAt,
    MessageState? state,
    String? priority,
    String? encryptedPayload,
    int? sequence,
    int? hopCount,
  }) {
    return StoredMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      state: state ?? this.state,
      priority: priority ?? this.priority,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      sequence: sequence ?? this.sequence,
      hopCount: hopCount ?? this.hopCount,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'recipientId': recipientId,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'state': state.name,
        'priority': priority,
        'encryptedPayload': encryptedPayload,
        'sequence': sequence,
        'hopCount': hopCount,
      };

  static StoredMessage fromJson(Map<dynamic, dynamic> json) {
    return StoredMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      state: MessageState.values.firstWhere(
        (state) => state.name == json['state'],
      ),
      priority: json['priority'] as String? ?? 'normal',
      encryptedPayload: json['encryptedPayload'] as String?,
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      hopCount: (json['hopCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.participantIds,
    required this.updatedAt,
    this.isEmergency = false,
  });

  final String id;
  final String title;
  final List<String> participantIds;
  final DateTime updatedAt;
  final bool isEmergency;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'participantIds': participantIds,
        'updatedAt': updatedAt.toIso8601String(),
        'isEmergency': isEmergency,
      };

  static Conversation fromJson(Map<dynamic, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      participantIds: List<String>.from(json['participantIds'] as List),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isEmergency: json['isEmergency'] as bool? ?? false,
    );
  }
}

class DiagnosticSample {
  const DiagnosticSample({
    required this.id,
    required this.nodeId,
    required this.recordedAt,
    required this.rssi,
    required this.snr,
    required this.batteryPercent,
    required this.queueDepth,
    required this.deliveryRatio,
  });

  final String id;
  final String nodeId;
  final DateTime recordedAt;
  final int rssi;
  final double snr;
  final double batteryPercent;
  final int queueDepth;
  final double deliveryRatio;

  Map<String, Object?> toJson() => {
        'id': id,
        'nodeId': nodeId,
        'recordedAt': recordedAt.toIso8601String(),
        'rssi': rssi,
        'snr': snr,
        'batteryPercent': batteryPercent,
        'queueDepth': queueDepth,
        'deliveryRatio': deliveryRatio,
      };

  static DiagnosticSample fromJson(Map<dynamic, dynamic> json) {
    return DiagnosticSample(
      id: json['id'] as String,
      nodeId: json['nodeId'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      rssi: (json['rssi'] as num).toInt(),
      snr: (json['snr'] as num).toDouble(),
      batteryPercent: (json['batteryPercent'] as num).toDouble(),
      queueDepth: (json['queueDepth'] as num).toInt(),
      deliveryRatio: (json['deliveryRatio'] as num).toDouble(),
    );
  }
}
