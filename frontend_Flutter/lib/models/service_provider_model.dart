import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female, other }
enum ApprovalStatus { pending, accepted, rejected }

class ServiceProviderModel {
  final String providerId;  // Changed from uid to providerId
  final String name;       // Combined firstName and lastName into name
  final String email;
  final String phone;
  final String adhar;      // Changed from aadharNumber to adhar
  final String address;    // Changed from Map to String
  final String gender;     // Changed from enum to String
  final int age;
  final String about;
  final List<String> services;
  final String approvalStatus;  // Changed from enum to String
  final bool active;      // Added active status
  final double averageRating;  // Added averageRating
  final int totalReviews;     // Added totalReviews
  final List<Review>? reviews; // Added reviews list
  final int experience;  // Added experience field

  ServiceProviderModel({
    required this.providerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.adhar,
    required this.address,
    required this.gender,
    required this.age,
    required this.about,
    required this.services,
    required this.approvalStatus,
    required this.active,
    required this.experience,
    this.averageRating = 0.0,  // Default value
    this.totalReviews = 0,     // Default value
    this.reviews,              // Optional field
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      providerId: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      adhar: json['adhar'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      about: json['about'] ?? '',
      services: List<String>.from(json['services'] ?? []),
      approvalStatus: json['approvalStatus'] ?? 'PENDING',
      active: json['active'] ?? false,
      experience: json['experience'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      reviews: json['reviews'] != null 
          ? (json['reviews'] as List).map((r) => Review.fromMap(r as Map<String, dynamic>)).toList()
          : null,
    );
  }
}

// Add Review model class
class Review {
  final String reviewId;
  final String customerId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.reviewId,
    required this.customerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'customerId': customerId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      reviewId: map['reviewId'] ?? '',
      customerId: map['customerId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}