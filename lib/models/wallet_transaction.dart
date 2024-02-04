class WalletTransaction {
  String type;
  String invoice;
  int amount;
  int? fees_paid;
  String? description;
  String? description_hash;
  String? preimage;
  String? payment_hash;
  int? created_at;
  int? expires_at;
  int? settled_at;
  var metadata;

  WalletTransaction({
    required this.type,
    required this.invoice,
    required this.amount,
    required this.fees_paid,
    required this.created_at,
    required this.metadata,
    this.description,
    this.description_hash,
    this.preimage,
    this.payment_hash,
    this.expires_at,
    this.settled_at,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      type: json['type'],
      invoice: json['invoice'],
      amount: json['amount'],
      fees_paid: json['fees_paid'],
      description: json['description'],
      description_hash: json['description_hash'],
      preimage: json['preimage'],
      payment_hash: json['payment_hash'],
      created_at: json['created_at'],
      expires_at: json['expires_at'],
      settled_at: json['settled_at'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'invoice': invoice,
      'amount': amount,
      'fees': fees_paid,
      'description': description,
      'description_hash': description_hash,
      'preimage': preimage,
      'payment_hash': payment_hash,
      'created_at': created_at,
      'expires_at': expires_at,
      'settled_at': settled_at,
      'metadata': metadata,
    };
  }
}
