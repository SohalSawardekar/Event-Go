import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../routes/app_router.dart';
import '../../../services/auth_service.dart';
import '../../../services/event_service.dart';
import '../../../services/location_service.dart';
import '../../../widgets/events/event_card.dart';

class SavedTab extends StatefulWidget {
  const SavedTab({super.key});

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> {
  bool _isLoading = false;
  List<dynamic> _savedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadSavedEvents();
  }

  Future<void> _loadSavedEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final eventService = Provider.of<EventService>(context, listen: false);
    
    if (authService.user != null && authService.user!.savedEvents.isNotEmpty) {
      final events = await eventService.getSavedEvents(
        authService.user!.savedEvents,
      );
      
      setState(() {
        _savedEvents = events;
        _isLoading = false;
      });
    } else {
      setState(() {
        _savedEvents = [];
        _isLoading = false;
      });
    }
  }

  void _navigateToEventDetails(String eventId) {
    Navigator.of(context).pushNamed(
      AppRouter.eventDetails,
      arguments: {'eventId': eventId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final locationService = Provider.of<LocationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Events'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSavedEvents,
              child: _savedEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 72,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saved events yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Start saving events you\'re interested in to find them here',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _savedEvents.length,
                        itemBuilder: (context, index) {
                          final event = _savedEvents[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: EventCard(
                                    event: event,
                                    isSaved: true,
                                    onTap: () => _navigateToEventDetails(event.id),
                                    onSave: () {}, // Already saved
                                    onUnsave: () {
                                      authService.unsaveEvent(event.id).then((_) {
                                        _loadSavedEvents();
                                      });
                                    },
                                    distance: locationService.getDistanceToEvent(
                                      event.latitude,
                                      event.longitude,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
    );
  }
}