import 'package:flutter/material.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';
import 'package:lengoal/features/classes/presentation/models/class_quiz.dart';
import 'package:lengoal/features/classes/presentation/models/class_summary.dart';
import 'package:lengoal/features/dashboard/presentation/models/calendar_session.dart';

class ClassDetail {
  const new({
    required this.item,
    required this.rating,
    required this.reviewCount,
    required this.outline,
    required this.instructorPronouns,
    required this.instructorTitle,
    required this.instructorBio,
    required this.sessions,
    required this.quizzes,
    required this.materials,
    required this.hasCertificate,
  });

  factory fallback(ClassSummary item) {
    return ClassDetail(
      item: item,
      rating: 4.5,
      reviewCount: 128,
      outline: 'Class outline coming soon.',
      instructorPronouns: '',
      instructorTitle: '',
      instructorBio: 'More about ${item.instructor} coming soon.',
      sessions: const [],
      quizzes: const [],
      materials: const [],
      hasCertificate: false,
    );
  }

  final ClassSummary item;
  final double rating;
  final int reviewCount;
  final String outline;
  final String instructorPronouns;
  final String instructorTitle;
  final String instructorBio;
  final List<CalendarSession> sessions;
  final List<ClassQuiz> quizzes;
  final List<ClassMaterial> materials;
  final bool hasCertificate;
}

const mockSkeletalSystemDetail = ClassDetail(
  item: ClassSummary(
    title: 'Anatomy of the Skeletal system',
    instructor: 'John Smith',
    dateRange: 'Jan 23 - Mar 25, 2023',
    progress: 0.39,
    thumbnailColor: Color(0xFFD9D9D9),
    priceLabel: '₦35,000',
    isSubscribed: true,
  ),
  rating: 4.7,
  reviewCount: 1221,
  outline:
      'The skeletal system can be divided into two main parts: the axial '
      'skeleton and the appendicular skeleton. The axial skeleton includes '
      'the skull, vertebral column, ribs, and sternum, providing support '
      'and protection for vital organs such as the brain and spinal cord. '
      'The appendicular skeleton includes the bones of the limbs, along '
      'with the shoulder and pelvic girdles, facilitating movement and '
      'locomotion. The skeletal system also houses bone marrow, which '
      'produces blood cells. Understanding the anatomy of the skeletal '
      'system is essential for medical professionals, as it helps '
      'diagnose and treat bone-related conditions and ensures the '
      'overall well-being and functionality of the human body.',
  instructorPronouns: 'She/Her',
  instructorTitle: 'Senior Product Designer / Design Coach',
  instructorBio:
      'Genevieve is a Product Designer with 6+ years of Product & SaaS '
      'Experience. She is a user-centric, data-driven and result-oriented '
      'product person with proficiency in designing, evolving, and '
      'shipping products on multiple platforms. She is currently a '
      'Senior Product Designer at Design on Tap - a digital agency in '
      'the USA and a Design Coach at Plato where she mentors product '
      'designers in the USA, Canada and Finland. '
      "She's passionate about mentoring and educating designers.",
  sessions: mockCalendarSessions,
  quizzes: [
    ClassQuiz(
      title: 'Mid- Course Assessment',
      dueDate: 'Mar 23, 2025',
      status: QuizStatus.completed,
      instructorName: 'Ayodeji Oloruntoba',
    ),
    ClassQuiz(
      title: 'Penultimate Assessment',
      dueDate: 'Mar 23, 2025',
      status: QuizStatus.completed,
      instructorName: 'Ayodeji Oloruntoba',
    ),
    ClassQuiz(
      title: 'Final Assessment',
      dueDate: 'Mar 23, 2025',
      status: QuizStatus.pending,
      instructorName: 'Ayodeji Oloruntoba',
    ),
  ],
  materials: [
    ClassMaterial(
      name: 'Introduction to anatomy',
      fileType: MaterialFileType.pdf,
      url: '',
    ),
    ClassMaterial(
      name: 'Organization of the body',
      fileType: MaterialFileType.pdf,
      url: '',
    ),
    ClassMaterial(
      name: 'Cells and Tissues',
      fileType: MaterialFileType.word,
      url: '',
    ),
    ClassMaterial(
      name: 'Anatomy of the skeletal system',
      fileType: MaterialFileType.excel,
      url: '',
    ),
    ClassMaterial(
      name: 'https://www.youtube.com/watch?v=QIoUmnSkOXE',
      fileType: MaterialFileType.link,
      url: 'https://www.youtube.com/watch?v=QIoUmnSkOXE',
    ),
  ],
  hasCertificate: true,
);

ClassDetail detailFor(ClassSummary item) {
  if (item.title == mockSkeletalSystemDetail.item.title) {
    return mockSkeletalSystemDetail;
  }
  return ClassDetail.fallback(item);
}
