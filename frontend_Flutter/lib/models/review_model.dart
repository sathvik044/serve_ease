class ReviewModel {
  final String reviewId;
  final String bookingId;
  final String customerId;
  final String providerId;
  final int rating;
  final String comment;
  final String date;

  ReviewModel({
    required this.reviewId,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'review_id': reviewId,
      'booking_id': bookingId,
      'customer_id': customerId,
      'provider_id': providerId,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map['review_id'] ?? '',
      bookingId: map['booking_id'] ?? '',
      customerId: map['customer_id'] ?? '',
      providerId: map['provider_id'] ?? '',
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      date: map['date'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.reviewId == reviewId;
  }

  @override
  int get hashCode => reviewId.hashCode;

  @override
  String toString() {
    return 'ReviewModel{reviewId: $reviewId, bookingId: $bookingId, '
        'customerId: $customerId, providerId: $providerId, '
        'rating: $rating, comment: $comment, date: $date}';
  }
}