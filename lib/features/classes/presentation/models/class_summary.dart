import 'package:flutter/material.dart';

class ClassSummary {
  const new({
    required this.title,
    required this.instructor,
    required this.dateRange,
    required this.progress,
    required this.thumbnailColor,
    this.priceLabel,
    this.isFavorite = false,
    this.isSubscribed = false,
  });

  final String title;
  final String instructor;
  final String dateRange;
  final double progress;
  final Color thumbnailColor;

  final String? priceLabel;
  final bool isFavorite;
  final bool isSubscribed;
}

const mockMyClasses = [
  ClassSummary(
    title: 'Institutional Superior Themed Exemplary as known',
    instructor: 'John Smith',
    dateRange: 'Jan 23 - Mar 25, 2023',
    progress: 0.39,
    thumbnailColor: Color(0xFFD9D9D9),
    isFavorite: true,
    isSubscribed: true,
  ),
  ClassSummary(
    title: 'Natural sciences and nature',
    instructor: 'Jenny Wilson',
    dateRange: 'Jan 23 - Mar 25, 2023',
    progress: 0.69,
    thumbnailColor: Color(0xFFF5B400),
    priceLabel: '₦35,000',
    isSubscribed: true,
  ),
  ClassSummary(
    title: 'Natural sciences and nature',
    instructor: 'Jenny Wilson',
    dateRange: 'Jan 23 - Mar 25, 2023',
    progress: 0.69,
    thumbnailColor: Color(0xFFF5B400),
    priceLabel: '₦35,000',
    isSubscribed: true,
  ),
];

const mockRecommendedClasses = [
  ClassSummary(
    title: 'Institutional Superior Themed Exemplary as known',
    instructor: 'John Smith',
    dateRange: 'Jan 23 - Mar 25, 2023',
    progress: 0,
    thumbnailColor: Color(0xFFD9D9D9),
    isFavorite: true,
  ),
  ClassSummary(
    title: 'Natural sciences and nature',
    instructor: 'Jenny Wilson',
    dateRange: 'Jan 23 - Mar 25, 2023',
    progress: 0,
    thumbnailColor: Color(0xFF4A3B2A),
    priceLabel: '₦35,000',
  ),
  ClassSummary(
    title: 'Natural sciences and nature',
    instructor: 'Jenny Wilson',
    dateRange: 'Jan 23 - Mar 25, 2023',
    progress: 0,
    thumbnailColor: Color(0xFF4A3B2A),
    priceLabel: '₦35,000',
  ),
];
