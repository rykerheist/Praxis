class Client {
  final String id;
  final String tenantId;
  final String fullName;
  final String? organization;
  final String timezone;
  final Map<String, dynamic>? psychometrics;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.tenantId,
    required this.fullName,
    this.organization,
    this.timezone = 'UTC',
    this.psychometrics,
    required this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      fullName: json['full_name'] as String,
      organization: json['organization'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      psychometrics: json['psychometrics_json'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'full_name': fullName,
      'organization': organization,
      'timezone': timezone,
      'psychometrics_json': psychometrics,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
