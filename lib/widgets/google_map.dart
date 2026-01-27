import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fanari_v2/constants/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fanari_v2/utils.dart' as utils;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanari_v2/utils/print_helper.dart';
// import 'package:fanari_v2/widgets/custom_glass_wrapper.dart';

class GoogleMapSearchModel {
  String description;
  String placeId;

  GoogleMapSearchModel({required this.description, required this.placeId});
}

class GoogleMapLocation {
  String name;
  String placeId;
  LatLng position;

  GoogleMapLocation({
    required this.position,
    required this.name,
    required this.placeId,
  });
}

class GoogleMapScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final bool withScaffold;
  final String apiKey;
  final bool canSelectLocation;
  final void Function(GoogleMapLocation)? onLocationSelect;

  const GoogleMapScreen({
    super.key,
    required this.apiKey,
    this.initialPosition,
    this.withScaffold = true,
    this.onLocationSelect,
    this.canSelectLocation = true,
  });

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const LatLng _kGooglePlex = LatLng(
    37.42796133580664,
    -122.085749655962,
  );

  late CameraPosition _initialPosition;

  @override
  void initState() {
    super.initState();

    if (widget.initialPosition != null) {
      _initialPosition = CameraPosition(
        target: widget.initialPosition!,
        zoom: 14.4746,
      );

      _handleTap(widget.initialPosition!);
    } else {
      _initialPosition = CameraPosition(target: _kGooglePlex, zoom: 14.4746);
    }
  }

  bool _gettingMyLocation = false;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('');
      debugPrint('Location services are disabled.');
      debugPrint('');
      return;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('');
      debugPrint(
        'Location permissions are permanently denied. Please enable them from settings.',
      );
      debugPrint('');
      return;
    }

    setState(() {
      _gettingMyLocation = true;
    });

    // If everything is good, get the current position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(accuracy: LocationAccuracy.high),
    );

    debugPrint('');
    debugPrint(
      'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
    );
    debugPrint('');

    final GoogleMapController controller = await _controller.future;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );

    markers.clear(); // If you want only one marker at a time
    markers.add(
      Marker(
        markerId: MarkerId(position.hashCode.toString()),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(
          title: 'Selected Location',
          snippet: '${position.latitude}, ${position.longitude}',
        ),
      ),
    );

    setState(() {
      _selectedPlaceDetails = null;
      _selectedPosition = LatLng(position.latitude, position.longitude);
    });

    //Get the place id
    final placeId = await getPlaceIdFromLatLng(
      position.latitude,
      position.longitude,
    );

    if (placeId == null) return;

    //Get the place details
    final details = await getPlaceDetails(placeId);
    if (details == null) return;

    setState(() {
      _selectedPlaceDetails = details;
    });

    setState(() {
      _gettingMyLocation = false;
    });
  }

  Set<Marker> markers = {};

  bool _handlingTap = false;

  // This method handles the tap event on the map
  void _handleTap(LatLng tappedPoint) async {
    if (!mounted || _handlingTap) return;
    _handlingTap = true;
    setState(() {
      markers.clear(); // If you want only one marker at a time
      markers.add(
        Marker(
          markerId: MarkerId(
            '${tappedPoint.latitude}_${tappedPoint.longitude}',
          ),
          position: tappedPoint,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: '${tappedPoint.latitude}, ${tappedPoint.longitude}',
          ),
        ),
      );
    });

    if (!mounted) return;
    setState(() {
      _selectedPlaceDetails = null;
      _selectedPosition = LatLng(tappedPoint.latitude, tappedPoint.longitude);
    });

    //Get the place id
    final placeId = await getPlaceIdFromLatLng(
      tappedPoint.latitude,
      tappedPoint.longitude,
    );

    if (placeId == null) {
      _handlingTap = false;
      return;
    }

    //Get the place details
    final details = await getPlaceDetails(placeId);
    _handlingTap = false;
    if (details == null || !mounted) return;

    setState(() {
      _selectedPlaceDetails = details;
    });
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${widget.apiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return data['result'];
      } else {
        print('API Error: ${data['status']}');
        return null;
      }
    } else {
      return null;
    }
  }

  Future<String?> getPlaceIdFromLatLng(double lat, double lng) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${widget.apiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final placeId = data['results'][0]['place_id'];
        return placeId;
      }
    }

    return null;
  }

  String _googleMapPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=${widget.apiKey}';
  }

  Map<String, dynamic>? _selectedPlaceDetails;
  LatLng? _selectedPosition;

  String _searchIcon() {
    return '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M18.031 16.6166L22.3137 20.8993L20.8995 22.3135L16.6168 18.0308C15.0769 19.2628 13.124 19.9998 11 19.9998C6.032 19.9998 2 15.9678 2 10.9998C2 6.03176 6.032 1.99976 11 1.99976C15.968 1.99976 20 6.03176 20 10.9998C20 13.1238 19.263 15.0767 18.031 16.6166ZM16.0247 15.8746C17.2475 14.6144 18 12.8954 18 10.9998C18 7.13226 14.8675 3.99976 11 3.99976C7.1325 3.99976 4 7.13226 4 10.9998C4 14.8673 7.1325 17.9998 11 17.9998C12.8956 17.9998 14.6146 17.2473 15.8748 16.0245L16.0247 15.8746Z" fill="white"/></svg>';
  }

  String _gpsIcon() {
    return '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M12 1.25C12.4142 1.25 12.75 1.58579 12.75 2V3.28169C16.9842 3.64113 20.3589 7.01581 20.7183 11.25H22C22.4142 11.25 22.75 11.5858 22.75 12C22.75 12.4142 22.4142 12.75 22 12.75H20.7183C20.3589 16.9842 16.9842 20.3589 12.75 20.7183V22C12.75 22.4142 12.4142 22.75 12 22.75C11.5858 22.75 11.25 22.4142 11.25 22V20.7183C7.01581 20.3589 3.64113 16.9842 3.28169 12.75H2C1.58579 12.75 1.25 12.4142 1.25 12C1.25 11.5858 1.58579 11.25 2 11.25H3.28169C3.64113 7.01581 7.01581 3.64113 11.25 3.28169V2C11.25 1.58579 11.5858 1.25 12 1.25ZM12 4.75C7.99594 4.75 4.75 7.99594 4.75 12C4.75 16.0041 7.99594 19.25 12 19.25C16.0041 19.25 19.25 16.0041 19.25 12C19.25 7.99594 16.0041 4.75 12 4.75ZM12 9.75C10.7574 9.75 9.75 10.7574 9.75 12C9.75 13.2426 10.7574 14.25 12 14.25C13.2426 14.25 14.25 13.2426 14.25 12C14.25 10.7574 13.2426 9.75 12 9.75ZM8.25 12C8.25 9.92893 9.92893 8.25 12 8.25C14.0711 8.25 15.75 9.92893 15.75 12C15.75 14.0711 14.0711 15.75 12 15.75C9.92893 15.75 8.25 14.0711 8.25 12Z" fill="#999999"/></svg>';
  }

  Widget _blurBgWrapper({
    required Widget child,
    BorderRadius? borderRadius,
    double? height,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? EdgeInsets.zero,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.2),
              width: 1.w,
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF242424).withValues(alpha: 0.15),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }

  Widget _searchWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 48.h, left: 18.w, right: 18.w),
        child: Row(
          spacing: 12.w,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: _blurBgWrapper(
                width: 36.w,
                height: 36.w,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.text,
                  size: 14.w,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      return MapSearchScreen(
                        apiKey: widget.apiKey,
                        onSearchSelect: _handleSearchSelect,
                      );
                    },
                  ),
                );
              },
              child: _blurBgWrapper(
                width: 1.sw - 72.w - 36.w - 24.w,
                height: 40.h,
                borderRadius: BorderRadius.circular(24.r),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.string(
                      _searchIcon(),
                      width: 20.w,
                      height: 20.w,
                      color: AppColors.text.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Search ...',
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.6),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _getCurrentLocation,
              child: _blurBgWrapper(
                width: 36.w,
                height: 36.w,
                child: Center(
                  child: _gettingMyLocation
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1,
                          ),
                        )
                      : SvgPicture.string(
                          _gpsIcon(),
                          width: 20.w,
                          height: 20.w,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearchSelect(GoogleMapSearchModel item) async {
    final details = await getPlaceDetails(item.placeId);
    if (details == null) return;

    setState(() {
      _selectedPlaceDetails = details;
    });

    final location = details['geometry']['location'];
    setState(() {
      _selectedPosition = LatLng(location['lat'], location['lng']);
    });

    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    List<dynamic> str = jsonDecode(
      localStorage.getString('google-map-location-search-history') ?? '[]',
    );

    List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(str);

    history.removeWhere((element) => element['placeId'] == item.placeId);
    history.add({'placeId': item.placeId, 'description': item.description});

    localStorage.setString(
      'google-map-location-search-history',
      jsonEncode(history),
    );

    final GoogleMapController controller = await _controller.future;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(bearing: 0, target: _selectedPosition!, zoom: 15),
      ),
    );

    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId(item.placeId),
        position: LatLng(location['lat'], location['lng']),
        infoWindow: InfoWindow(
          title: 'Selected Location',
          snippet: '${location['lat']}, ${location['lng']}',
        ),
      ),
    );
  }

  Widget _photoWidget({
    required Map<String, dynamic> photo,
    required void Function() onTap,
  }) {
    final double height = 100.h;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: (height * photo['width']) / photo['height'],
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: CachedNetworkImage(
            imageUrl: _googleMapPhotoUrl(photo['photo_reference']),
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return Container(
                height: height,
                width: (height * photo['width']) / photo['height'],
                decoration: BoxDecoration(
                  color: Color(0xff242424).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _selectedPositionDetailsWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
          child: _blurBgWrapper(
            width: double.infinity,
            borderRadius: BorderRadius.circular(16.r),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedPlaceDetails!['address_components'].map((e) => e['long_name']).join(', ')}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlaceDetails = null;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 18.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (_selectedPlaceDetails != null &&
                    _selectedPlaceDetails!['photos'] != null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ..._selectedPlaceDetails!['photos'].asMap().entries.map(
                          (entry) {
                            int index = entry.key;
                            final photo = entry.value;
                            return _photoWidget(
                              photo: photo,
                              onTap: () {
                                utils.openImageViewer(
                                  context: context,
                                  index: index,
                                  images: [
                                    ..._selectedPlaceDetails!['photos'].map((
                                      item,
                                    ) {
                                      return CachedNetworkImageProvider(
                                        _googleMapPhotoUrl(
                                          item['photo_reference'],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                );
                              },
                            );
                          },
                        ).toList(),
                      ],
                    ),
                  ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 12.w,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlaceDetails = null;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xff242424).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                    if (widget.canSelectLocation)
                      GestureDetector(
                        onTap: () {
                          widget.onLocationSelect?.call(
                            GoogleMapLocation(
                              position: _selectedPosition!,
                              name: _selectedPlaceDetails!['address_components']
                                  .map((e) => e['long_name'])
                                  .join(', '),
                              placeId: _selectedPlaceDetails!['place_id'],
                            ),
                          );

                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xff242424).withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: Text(
                            'Select',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 110, 147, 250),
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  dynamic mapStyle = [
    {
      "elementType": "geometry",
      "stylers": [
        {"color": "#2b2f3a"},
      ],
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#cfd3dc"},
      ],
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {"color": "#2b2f3a"},
      ],
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#e0b07a"},
      ],
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#d6b48a"},
      ],
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [
        {"color": "#2f4a45"},
      ],
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#7fbfa3"},
      ],
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {"color": "#3e4453"},
      ],
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [
        {"color": "#2a2f3a"},
      ],
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#c1c7d3"},
      ],
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [
        {"color": "#5b556b"},
      ],
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry.stroke",
      "stylers": [
        {"color": "#3a3646"},
      ],
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#f0d6a8"},
      ],
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [
        {"color": "#3b4152"},
      ],
    },
    {
      "featureType": "transit.station",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#e0b07a"},
      ],
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {"color": "#1f334a"},
      ],
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#8fa1b5"},
      ],
    },
    {
      "featureType": "water",
      "elementType": "labels.text.stroke",
      "stylers": [
        {"color": "#1f334a"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    Widget buildWidget = SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          GoogleMap(
            style: jsonEncode(mapStyle),
            onTap: _handleTap,
            markers: markers,
            compassEnabled: true,
            buildingsEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          _searchWidget(),
          if (_selectedPlaceDetails != null) _selectedPositionDetailsWidget(),
        ],
      ),
    );

    if (widget.withScaffold) {
      return Scaffold(body: buildWidget);
    } else {
      return buildWidget;
    }
  }
}

class MapSearchScreen extends StatefulWidget {
  final void Function(GoogleMapSearchModel)? onSearchSelect;
  final String apiKey;

  const MapSearchScreen({super.key, required this.apiKey, this.onSearchSelect});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _searchDelayTimer;

  List<GoogleMapSearchModel> _searchResults = [];
  List<GoogleMapSearchModel> _searchHistory = [];

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDelayTimer?.cancel();
    super.dispose();
  }

  String _searchIcon() {
    return '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M18.031 16.6166L22.3137 20.8993L20.8995 22.3135L16.6168 18.0308C15.0769 19.2628 13.124 19.9998 11 19.9998C6.032 19.9998 2 15.9678 2 10.9998C2 6.03176 6.032 1.99976 11 1.99976C15.968 1.99976 20 6.03176 20 10.9998C20 13.1238 19.263 15.0767 18.031 16.6166ZM16.0247 15.8746C17.2475 14.6144 18 12.8954 18 10.9998C18 7.13226 14.8675 3.99976 11 3.99976C7.1325 3.99976 4 7.13226 4 10.9998C4 14.8673 7.1325 17.9998 11 17.9998C12.8956 17.9998 14.6146 17.2473 15.8748 16.0245L16.0247 15.8746Z" fill="white"/></svg>';
  }

  String _searchLocationIcon() {
    return '<?xml version="1.0" ?><svg viewBox="0 0 384 512" xmlns="http://www.w3.org/2000/svg"><path fill="#DB5C51" d="M192 0C85.97 0 0 85.97 0 192c0 77.41 26.97 99.03 172.3 309.7c9.531 13.77 29.91 13.77 39.44 0C357 291 384 269.4 384 192C384 85.97 298 0 192 0zM192 271.1c-44.13 0-80-35.88-80-80S147.9 111.1 192 111.1s80 35.88 80 80S236.1 271.1 192 271.1z"/></svg>';
  }

  Future<void> _saveToHistory(GoogleMapSearchModel item) async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    List<dynamic> str = jsonDecode(
      localStorage.getString('google-map-location-search-history') ?? '[]',
    );

    List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(str);

    history.removeWhere((element) => element['placeId'] == item.placeId);
    history.add({'placeId': item.placeId, 'description': item.description});

    localStorage.setString(
      'google-map-location-search-history',
      jsonEncode(history),
    );

    return null;
  }

  Widget _searchHistoryItemWidget(GoogleMapSearchModel item, int index) {
    return GestureDetector(
      onTap: () {
        widget.onSearchSelect?.call(item);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 18.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12.w,
          children: [
            Icon(
              Icons.history,
              size: 20.w,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            Expanded(
              child: Text(
                item.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                _removeHistoryItem(item);
              },
              child: Icon(Icons.close, color: AppColors.hintText, size: 20.w),
            ),
          ],
        ),
      ),
    );
  }

  void _loadHistory() async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    List<dynamic> str = jsonDecode(
      localStorage.getString('google-map-location-search-history') ?? '[]',
    );

    List<GoogleMapSearchModel> history = str.map((item) {
      return GoogleMapSearchModel(
        description: item['description'],
        placeId: item['placeId'],
      );
    }).toList();

    setState(() {
      _searchHistory = history;
    });
    return;
  }

  void _handleSearch(String value) {
    _searchDelayTimer?.cancel();

    _searchDelayTimer = Timer(const Duration(milliseconds: 500), () async {
      if (value.isEmpty) {
        setState(() {
          _searchResults = [];
        });

        return;
      }

      final autoComplete = await fetchAutocompletePredictions(value);
      if (autoComplete == null) return;

      setState(() {
        _searchResults = autoComplete.map((item) {
          return GoogleMapSearchModel(
            description: item['description'],
            placeId: item['place_id'],
          );
        }).toList();
      });
    });
  }

  Future<List<Map<String, dynamic>>?> fetchAutocompletePredictions(
    String input,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${widget.apiKey}&types=geocode',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        List<Map<String, dynamic>> predictions = [];
        for (var prediction in data['predictions']) {
          predictions.add(prediction);
        }

        return predictions; // List of predictions
      } else {
        debugPrint('API Error: ${data['status']}');
        return null;
      }
    } else {
      return null;
    }
  }

  Widget _searchWidget() {
    return SafeArea(
      bottom: false,
      child: Row(
        spacing: 8.w,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.text,
                size: 14.w,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.string(
                    _searchIcon(),
                    width: 20.w,
                    height: 20.w,
                    color: AppColors.text.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      onChanged: (value) async {
                        _handleSearch(value);
                      },
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(color: AppColors.text, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.6),
                          fontSize: 13.sp,
                        ),
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Search ...',
                        contentPadding: EdgeInsets.all(0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.close, color: AppColors.text, size: 14.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchItemWidget(GoogleMapSearchModel item, int index) {
    return GestureDetector(
      onTap: () async {
        await _saveToHistory(item);
        widget.onSearchSelect?.call(item);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 18.h),
        padding: EdgeInsets.only(bottom: 18.h),
        decoration: BoxDecoration(
          border: index == _searchResults.length - 1
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.w,
                  ),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12.w,
          children: [
            SvgPicture.string(_searchLocationIcon(), width: 18.w, height: 18.w),
            Expanded(
              child: Text(
                item.description,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeAllHistory() async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    setState(() {
      _searchHistory = [];
    });

    await localStorage.remove('google-map-location-search-history');
  }

  void _removeHistoryItem(GoogleMapSearchModel target) async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    setState(() {
      _searchHistory = _searchHistory
          .where((item) => item.placeId != target.placeId)
          .toList();
    });

    await localStorage.setString(
      'google-map-location-search-history',
      jsonEncode(
        _searchHistory.map((item) {
          return {'placeId': item.placeId, 'description': item.description};
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _searchWidget(),
              if (_searchResults.isNotEmpty) SizedBox(height: 36.h),
              if (_searchResults.isNotEmpty)
                ..._searchResults.asMap().entries.map((entry) {
                  int index = entry.key;
                  GoogleMapSearchModel item = entry.value;
                  return _searchItemWidget(item, index);
                }).toList(),
              if (_searchResults.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'History',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _removeAllHistory,
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            color: Color.fromARGB(255, 133, 178, 245),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_searchResults.isEmpty)
                ..._searchHistory.asMap().entries.map((entry) {
                  int index = entry.key;
                  GoogleMapSearchModel item = entry.value;

                  return _searchHistoryItemWidget(item, index);
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
