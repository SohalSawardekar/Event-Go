import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../routes/app_router.dart';
import '../../../services/event_service.dart';
import '../../../services/location_service.dart';
import '../../../widgets/ui/search_bar.dart';
import '../../../models/event.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarkers();
    });
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveToUserLocation();
  }

  Future<void> _moveToUserLocation() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    
    if (locationService.currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              locationService.currentPosition!.latitude,
              locationService.currentPosition!.longitude,
            ),
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  void _loadMarkers() {
    final eventService = Provider.of<EventService>(context, listen: false);
    
    setState(() {
      _markers.clear();
      for (final event in eventService.events) {
        _markers.add(
          Marker(
            markerId: MarkerId(event.id),
            position: LatLng(event.latitude, event.longitude),
            infoWindow: InfoWindow(
              title: event.title,
              snippet: event.formattedDate,
              onTap: () => _navigateToEventDetails(event.id),
            ),
          ),
        );
      }
    });
  }

  void _navigateToEventDetails(String eventId) {
    Navigator.of(context).pushNamed(
      AppRouter.eventDetails,
      arguments: {'eventId': eventId},
    );
  }

  void _onSearch(String query) {
    final eventService = Provider.of<EventService>(context, listen: false);
    eventService.fetchEvents(searchQuery: query).then((_) => _loadMarkers());
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    final eventService = Provider.of<EventService>(context);
    
    // If location permission was denied
    if (locationService.permissionDenied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Location access denied',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please enable location access to view events near you',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => locationService.requestLocationPermission(),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }
    
    // Loading state
    if (locationService.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Default location if user location is not available
    final LatLng initialPosition = locationService.currentPosition != null
        ? LatLng(
            locationService.currentPosition!.latitude,
            locationService.currentPosition!.longitude,
          )
        : const LatLng(37.7749, -122.4194); // San Francisco as default
    
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomSearchBar(
                controller: _searchController,
                onSearch: _onSearch,
                hintText: 'Search for events...',
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: initialPosition,
                    zoom: 14.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                if (eventService.isLoading)
                  const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                Positioned(
                  right: 16,
                  bottom: 100,
                  child: FloatingActionButton(
                    onPressed: _moveToUserLocation,
                    mini: true,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}