class NwcNotification {
  static const String PAYMENT_RECEIVED = "payment_received";
  static const String PAYMENT_SENT = "payment_sent";

  static const String INCOMING = "incoming";
  static const String OUTGOING = "outgoing";

  String type;
  String invoice;
  String? description;
  String? descriptionHash;
  String preimage;
  String paymentHash;
  int amount;
  int feesPaid;
  int createdAt;
  int? expiresAt;
  int settledAt;
  Map<String, dynamic>? metadata;

  get isIncoming => type == INCOMING;

  NwcNotification({
    required this.type,
    required this.invoice,
    this.description,
    this.descriptionHash,
    required this.preimage,
    required this.paymentHash,
    required this.amount,
    required this.feesPaid,
    required this.createdAt,
    this.expiresAt,
    required this.settledAt,
    required this.metadata,
  });

  factory NwcNotification.fromMap(Map<String, dynamic> map) {
    return NwcNotification(
      type: map['type'] as String,
      invoice: map['invoice'] as String,
      description: map['description'] as String?,
      descriptionHash: map['description_hash'] as String?,
      preimage: map['preimage'] as String,
      paymentHash: map['payment_hash'] as String,
      amount: map['amount'] as int,
      feesPaid: map['fees_paid'] as int,
      createdAt: map['created_at'] as int,
      expiresAt: map['expires_at'] as int?,
      settledAt: map['settled_at'] as int,
      metadata: map.containsKey('metadata') && map['metadata']!=null ? Map<String, dynamic>.from(map['metadata']): null,
    );
  }
}
