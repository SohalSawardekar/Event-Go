import 'package:intl/intl.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final String location;
  final double latitude;
  final double longitude;
  final String organizer;
  final String category;
  final double price;
  final bool isFree;
  final int attendeeCount;
  final int maxAttendees;
  final bool isVirtual;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.organizer,
    required this.category,
    required this.price,
    this.isFree = false,
    this.attendeeCount = 0,
    this.maxAttendees = 0,
    this.isVirtual = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      imageUrl: json['imageUrl'],
      location: json['location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      organizer: json['organizer'],
      category: json['category'],
      price: json['price']?.toDouble() ?? 0.0,
      isFree: json['isFree'] ?? false,
      attendeeCount: json['attendeeCount'] ?? 0,
      maxAttendees: json['maxAttendees'] ?? 0,
      isVirtual: json['isVirtual'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'imageUrl': imageUrl,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'organizer': organizer,
      'category': category,
      'price': price,
      'isFree': isFree,
      'attendeeCount': attendeeCount,
      'maxAttendees': maxAttendees,
      'isVirtual': isVirtual,
    };
  }

  String get formattedDate {
    final DateFormat formatter = DateFormat('E, MMM d · h:mm a');
    return formatter.format(startDate);
  }

  String get formattedDateRange {
    final DateFormat dateFormatter = DateFormat('E, MMM d');
    final DateFormat timeFormatter = DateFormat('h:mm a');
    
    if (startDate.day == endDate.day) {
      // Same day
      return '${dateFormatter.format(startDate)} · ${timeFormatter.format(startDate)} - ${timeFormatter.format(endDate)}';
    } else {
      // Different days
      return '${dateFormatter.format(startDate)} - ${dateFormatter.format(endDate)}';
    }
  }

  String get formattedPrice {
    if (isFree) return 'Free';
    return '\$${price.toStringAsFixed(2)}';
  }

  String get availabilityStatus {
    if (maxAttendees == 0) return 'Unlimited spots';
    final remaining = maxAttendees - attendeeCount;
    if (remaining <= 0) return 'Sold out';
    if (remaining < 10) return 'Few spots left';
    return '$remaining spots available';
  }
  
  bool get isSoldOut {
    return maxAttendees > 0 && attendeeCount >= maxAttendees;
  }
}