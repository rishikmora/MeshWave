enum NodeRole { phone, relay, gateway, emergency, observer }

class MeshNode {
  const MeshNode({
    required this.id,
    required this.callsign,
    required this.lastSeen,
    this.roles = const {NodeRole.phone},
    this.rssi = -120,
    this.snr = 0,
    this.batteryPercent = 1,
    this.firmwareVersion = 'unknown',
    this.latitude,
    this.longitude,
    this.online = true,
  });

  final String id;
  final String callsign;
  final DateTime lastSeen;
  final Set<NodeRole> roles;
  final int rssi;
  final double snr;
  final double batteryPercent;
  final String firmwareVersion;
  final double? latitude;
  final double? longitude;
  final bool online;

  bool get canRelay =>
      roles.contains(NodeRole.relay) || roles.contains(NodeRole.gateway);
  bool get isStale =>
      DateTime.now().difference(lastSeen) > const Duration(minutes: 5);

  double get linkQuality {
    final signal = ((rssi + 130) / 80).clamp(0.0, 1.0);
    final noise = ((snr + 20) / 35).clamp(0.0, 1.0);
    final power = batteryPercent.clamp(0.0, 1.0);
    return (signal * 0.52) + (noise * 0.28) + (power * 0.20);
  }

  MeshNode copyWith({
    String? id,
    String? callsign,
    DateTime? lastSeen,
    Set<NodeRole>? roles,
    int? rssi,
    double? snr,
    double? batteryPercent,
    String? firmwareVersion,
    double? latitude,
    double? longitude,
    bool? online,
  }) {
    return MeshNode(
      id: id ?? this.id,
      callsign: callsign ?? this.callsign,
      lastSeen: lastSeen ?? this.lastSeen,
      roles: roles ?? this.roles,
      rssi: rssi ?? this.rssi,
      snr: snr ?? this.snr,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      online: online ?? this.online,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'callsign': callsign,
        'lastSeen': lastSeen.toIso8601String(),
        'roles': roles.map((role) => role.name).toList(),
        'rssi': rssi,
        'snr': snr,
        'batteryPercent': batteryPercent,
        'firmwareVersion': firmwareVersion,
        'latitude': latitude,
        'longitude': longitude,
        'online': online,
      };

  static MeshNode fromJson(Map<dynamic, dynamic> json) {
    return MeshNode(
      id: json['id'] as String,
      callsign: json['callsign'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      roles: ((json['roles'] as List?) ?? const ['phone'])
          .map(
            (role) => NodeRole.values.firstWhere((item) => item.name == role),
          )
          .toSet(),
      rssi: (json['rssi'] as num?)?.toInt() ?? -120,
      snr: (json['snr'] as num?)?.toDouble() ?? 0,
      batteryPercent: (json['batteryPercent'] as num?)?.toDouble() ?? 1,
      firmwareVersion: json['firmwareVersion'] as String? ?? 'unknown',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      online: json['online'] as bool? ?? true,
    );
  }
}
