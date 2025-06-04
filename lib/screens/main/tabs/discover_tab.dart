import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../routes/app_router.dart';
import '../../../services/auth_service.dart';
import '../../../services/event_service.dart';
import '../../../services/location_service.dart';
import '../../../widgets/events/event_card.dart';
import '../../../widgets/events/featured_event_card.dart';
import '../../../widgets/events/category_chip.dart';
import '../../../widgets/ui/section_title.dart';
import '../../../widgets/ui/search_bar.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  String _selectedCategory = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTab();
    });
  }

  Future<void> _initializeTab() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    await locationService.getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final eventService = Provider.of<EventService>(context, listen: false);
    eventService.fetchEvents(searchQuery: query);
  }

  void _onCategorySelected(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = ''; // Toggle off if already selected
      } else {
        _selectedCategory = category;
      }
    });
    
    // Fetch events with the selected category
    final eventService = Provider.of<EventService>(context, listen: false);
    eventService.fetchEvents(
      category: _selectedCategory.isNotEmpty ? _selectedCategory : null,
      searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
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
    final eventService = Provider.of<EventService>(context);
    final locationService = Provider.of<LocationService>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar with profile
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${authService.user?.displayName ?? 'there'}!',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            locationService.currentAddress ?? 'Set your location',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Go to profile tab
                      (context.findAncestorWidgetOfExactType<MainScreen>() as MainScreen?)
                          ?.setState(() {
                        // TODO: Set selected index to profile tab
                      });
                    },
                    child: Hero(
                      tag: 'profile-picture',
                      child: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        backgroundImage: authService.user?.photoUrl != null
                            ? NetworkImage(authService.user!.photoUrl!)
                            : null,
                        radius: 24,
                        child: authService.user?.photoUrl == null
                            ? Text(
                                authService.user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: CustomSearchBar(
                controller: _searchController,
                onSearch: _onSearch,
                hintText: 'Search for events...',
              ),
            ),
            
            // Categories horizontal list
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: eventService.categories.length,
                itemBuilder: (context, index) {
                  final category = eventService.categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: CategoryChip(
                      label: category,
                      isSelected: _selectedCategory == category,
                      onTap: () => _onCategorySelected(category),
                    ),
                  );
                },
              ),
            ),
            
            // Main content
            Expanded(
              child: eventService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => eventService.fetchEvents(
                        category: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                      ),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (eventService.featuredEvents.isNotEmpty) ...[
                              const SectionTitle(title: 'Featured Events'),
                              SizedBox(
                                height: 220,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: eventService.featuredEvents.length,
                                  itemBuilder: (context, index) {
                                    final event = eventService.featuredEvents[index];
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration: const Duration(milliseconds: 375),
                                      child: SlideAnimation(
                                        horizontalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 16),
                                            child: FeaturedEventCard(
                                              event: event,
                                              isSaved: authService.isEventSaved(event.id),
                                              onTap: () => _navigateToEventDetails(event.id),
                                              onSave: () => authService.saveEvent(event.id),
                                              onUnsave: () => authService.unsaveEvent(event.id),
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
                              const SizedBox(height: 24),
                            ],
                            
                            const SectionTitle(title: 'Upcoming Events'),
                            eventService.events.isEmpty
                                ? SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.event_busy,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No events found',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : AnimationLimiter(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      itemCount: eventService.events.length,
                                      itemBuilder: (context, index) {
                                        final event = eventService.events[index];
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
                                                  isSaved: authService.isEventSaved(event.id),
                                                  onTap: () => _navigateToEventDetails(event.id),
                                                  onSave: () => authService.saveEvent(event.id),
                                                  onUnsave: () => authService.unsaveEvent(event.id),
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
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}