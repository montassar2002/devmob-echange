enum ReservationStatus { pending, accepted, rejected, completed, cancelled }

class Reservation {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemImage;
  final String renterId;
  final String renterName;
  final String ownerId;
  final String ownerName;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final ReservationStatus status;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemImage,
    required this.renterId,
    required this.renterName,
    required this.ownerId,
    required this.ownerName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.status = ReservationStatus.pending,
    required this.createdAt,
  });

  // Depuis Firestore
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? '',
      itemId: json['itemId'] ?? '',
      itemTitle: json['itemTitle'] ?? '',
      itemImage: json['itemImage'] ?? 'assets/images/perceuse.png',
      renterId: json['renterId'] ?? '',
      renterName: json['renterName'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      startDate: (json['startDate'] as dynamic).toDate(),
      endDate: (json['endDate'] as dynamic).toDate(),
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      status: _statusFromString(json['status'] ?? 'pending'),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  // Vers Firestore
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemImage': itemImage,
      'renterId': renterId,
      'renterName': renterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'startDate': startDate,
      'endDate': endDate,
      'totalPrice': totalPrice,
      'status': _statusToString(status),
      'createdAt': createdAt,
    };
  }

  static ReservationStatus _statusFromString(String status) {
    switch (status) {
      case 'accepted': return ReservationStatus.accepted;
      case 'rejected': return ReservationStatus.rejected;
      case 'completed': return ReservationStatus.completed;
      case 'cancelled': return ReservationStatus.cancelled;
      default: return ReservationStatus.pending;
    }
  }

  static String _statusToString(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.accepted: return 'accepted';
      case ReservationStatus.rejected: return 'rejected';
      case ReservationStatus.completed: return 'completed';
      case ReservationStatus.cancelled: return 'cancelled';
      default: return 'pending';
    }
  }
}