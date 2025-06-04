import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';

class EventService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Event> _events = [];
  List<Event> _featuredEvents = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  
  List<Event> get events => _events;
  List<Event> get featuredEvents => _featuredEvents;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  EventService() {
    _fetchCategories();
    fetchEvents();
  }
  
  Future<void> fetchEvents({
    String? searchQuery,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      Query query = _firestore.collection('events')
          .orderBy('startDate');
      
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      
      if (startDate != null) {
        query = query.where('startDate', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.where('startDate', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      
      final querySnapshot = await query.get();
      
      _events = querySnapshot.docs
          .map((doc) => Event.fromJson({'id': doc.id, ...doc.data() as Map<String, dynamic>}))
          .where((event) {
            // Apply text search filter if provided
            if (searchQuery != null && searchQuery.isNotEmpty) {
              return event.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    event.description.toLowerCase().contains(searchQuery.toLowerCase());
            }
            return true;
          })
          .toList();
      
      _featuredEvents = _events
          .where((event) => 
            event.startDate.isAfter(DateTime.now()) && 
            !event.isSoldOut &&
            event.attendeeCount > 5)  // Simple criteria for "featured" 
          .take(5)
          .toList();
          
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Event?> getEventById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final docSnapshot = await _firestore.collection('events').doc(id).get();
      
      if (docSnapshot.exists) {
        final event = Event.fromJson({
          'id': docSnapshot.id,
          ...docSnapshot.data()!,
        });
        
        _isLoading = false;
        notifyListeners();
        return event;
      } else {
        _error = 'Event not found';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<List<Event>> getSavedEvents(List<String> eventIds) async {
    if (eventIds.isEmpty) return [];
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final events = <Event>[];
      
      // Firebase limits batched requests, so chunk into smaller sizes
      const chunkSize = 10;
      for (var i = 0; i < eventIds.length; i += chunkSize) {
        final chunk = eventIds.sublist(
          i, i + chunkSize > eventIds.length ? eventIds.length : i + chunkSize);
          
        final querySnapshot = await _firestore
            .collection('events')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
            
        events.addAll(querySnapshot.docs.map(
          (doc) => Event.fromJson({'id': doc.id, ...doc.data()})));
      }
      
      _isLoading = false;
      notifyListeners();
      return events;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categoryDoc = await _firestore.collection('metadata').doc('categories').get();
      
      if (categoryDoc.exists) {
        final data = categoryDoc.data();
        if (data != null && data['categories'] != null) {
          _categories = List<String>.from(data['categories']);
        }
      }
      
      if (_categories.isEmpty) {
        // Fallback categories if none found in database
        _categories = [
          'Music',
          'Food & Drink',
          'Arts & Culture',
          'Sports',
          'Outdoor',
          'Technology',
          'Business',
          'Community',
          'Health & Wellness',
          'Education',
        ];
      }
      
      notifyListeners();
    } catch (e) {
      // Use default categories on error
      _categories = [
        'Music',
        'Food & Drink',
        'Arts & Culture',
        'Sports',
        'Outdoor',
        'Technology',
      ];
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}