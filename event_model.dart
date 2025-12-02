import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final Timestamp startTime;
  final Timestamp endTime;
  final List<String> images;
  final String? videoUrl;
  final int attendeesCount;
  final String status;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.images,
    required this.videoUrl,
    required this.attendeesCount,
    required this.status,
  });

  factory EventModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      location: data['location'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      images: List<String>.from(data['images']),
      videoUrl: data['videoUrl'],
      attendeesCount: data['attendeesCount'] ?? 0,
      status: data['status'],
    );
  }
}
