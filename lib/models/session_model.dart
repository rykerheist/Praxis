enum SessionStatus {
  scheduled,
  completed,
  cancelled,
}

class Session {
  final String id;
  final String clientId;
  final DateTime? scheduledAt;
  final String? briefingNoteMd;
  final String? transcriptText;
  final String? summaryPdfUrl;
  final SessionStatus status;

  Session({
    required this.id,
    required this.clientId,
    this.scheduledAt,
    this.briefingNoteMd,
    this.transcriptText,
    this.summaryPdfUrl,
    required this.status,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      briefingNoteMd: json['briefing_note_md'] as String?,
      transcriptText: json['transcript_text'] as String?,
      summaryPdfUrl: json['summary_pdf_url'] as String?,
      status: SessionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'scheduled'),
        orElse: () => SessionStatus.scheduled,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'briefing_note_md': briefingNoteMd,
      'transcript_text': transcriptText,
      'summary_pdf_url': summaryPdfUrl,
      'status': status.name,
    };
  }
}
