import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../routes/app_router.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/location_service.dart';
import '../utils/theme.dart';
import '../models/event.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  
  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    final eventService = Provider.of<EventService>(context, listen: false);
    final event = await eventService.getEventById(widget.eventId);
    
    if (mounted) {
      setState(() {
        _event = event;
        _isLoading = false;
      });
    }
  }

  void _shareEvent() {
    if (_event == null) return;
    
    final String shareText = '''Check out this event: ${_event!.title}
${_event!.formattedDateRange}
${_event!.location}

${_event!.description.substring(0, min(_event!.description.length, 100))}...

#EventGo #LocalEvent''';

    Share.share(shareText);
  }

  void _navigateToMap() {
    if (_event == null) return;
    
    Navigator.of(context).pushNamed(
      AppRouter.eventMap,
      arguments: {
        'latitude': _event!.latitude,
        'longitude': _event!.longitude,
        'eventName': _event!.title,
      },
    );
  }

  void _registerForEvent() {
    // TODO: Implement event registration
    if (_event == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration feature coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final locationService = Provider.of<LocationService>(context);
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _event == null
              ? const Center(child: Text('Event not found'))
              : CustomScrollView(
                  slivers: [
                    // App bar with image
                    SliverAppBar(
                      expandedHeight: 240.0,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: _event!.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                            ),
                            // Gradient overlay for better text visibility
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: const [0.6, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        // Bookmark button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              authService.isEventSaved(_event!.id)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            if (authService.isEventSaved(_event!.id)) {
                              authService.unsaveEvent(_event!.id);
                            } else {
                              authService.saveEvent(_event!.id);
                            }
                          },
                        ),
                        // Share button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: _shareEvent,
                        ),
                      ],
                    ),
                    
                    // Event content
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Event title
                                Text(
                                  _event!.title,
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Event meta info
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.category,
                                            size: 16,
                                            color: AppTheme.primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _event!.category,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.attach_money,
                                            size: 16,
                                            color: AppTheme.primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _event!.formattedPrice,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Date and time
                                _buildInfoRow(
                                  context,
                                  icon: Icons.calendar_today,
                                  title: 'Date & Time',
                                  value: _event!.formattedDateRange,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Location with map button
                                GestureDetector(
                                  onTap: _navigateToMap,
                                  child: _buildInfoRow(
                                    context,
                                    icon: Icons.location_on,
                                    title: 'Location',
                                    value: _event!.location,
                                    suffix: locationService.currentPosition != null
                                        ? Text(
                                            locationService.formatDistance(
                                              locationService.getDistanceToEvent(
                                                _event!.latitude,
                                                _event!.longitude,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          )
                                        : const Icon(
                                            Icons.map,
                                            size: 20,
                                            color: AppTheme.primaryColor,
                                          ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Organizer
                                _buildInfoRow(
                                  context,
                                  icon: Icons.person,
                                  title: 'Organizer',
                                  value: _event!.organizer,
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Availability
                                if (_event!.maxAttendees > 0)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Availability',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: LinearProgressIndicator(
                                          value: _event!.attendeeCount / _event!.maxAttendees,
                                          minHeight: 12,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _event!.isSoldOut
                                                ? Colors.red
                                                : AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _event!.availabilityStatus,
                                        style: TextStyle(
                                          color: _event!.isSoldOut
                                              ? Colors.red
                                              : Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                
                                const SizedBox(height: 24),
                                
                                // About section
                                Text(
                                  'About This Event',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _event!.description,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                  ),
                                ),
                                
                                const SizedBox(height: 100), // Extra space for the bottom button
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomSheet: _event == null
          ? null
          : Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _event!.formattedPrice,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        _event!.isFree ? 'Free entry' : 'Per person',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _event!.isSoldOut ? null : _registerForEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: Colors.grey[400],
                      ),
                      child: Text(
                        _event!.isSoldOut
                            ? 'Sold Out'
                            : _event!.isFree
                                ? 'Register Now'
                                : 'Get Tickets',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Widget? suffix,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (suffix != null) suffix,
      ],
    );
  }
  
  int min(int a, int b) => a < b ? a : b;
}