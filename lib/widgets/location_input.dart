import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:favorite_places/models/place.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<StatefulWidget> createState() {
   return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
 PlaceLocation? _pickLocation;
  var _isGettingLocation = false;

  String get LocationImage {
    if (_pickLocation == null) {
      return '';
    }
    final lat = _pickLocation!.latitude;
    final lng = _pickLocation!.longitude;
   return 'https://maps.googleapis.com/maps/api/staticmap?center$lat,$lng=Brooklyn+Bridge,New+York,NY&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:S%7C$lat,$lng&markers=color:green%7Clabel:G%7C40.711614,-74.012318&markers=color:red%7Clabel:C%7C40.718217,-73.998284&key=YOUR_API_KEY';
  }

 void _getCurrentLocation() async {
  setState(() {
    _isGettingLocation = true;
  });
  

  Location location = Location();

bool serviceEnabled;
PermissionStatus permissionGranted;
LocationData locationData;

serviceEnabled = await location.serviceEnabled();
if (!serviceEnabled) {
  serviceEnabled = await location.requestService();
  if (!serviceEnabled) {
    return;
  }
}

permissionGranted = await location.hasPermission();
if (permissionGranted == PermissionStatus.denied) {
  permissionGranted = await location.requestPermission();
  if (permissionGranted != PermissionStatus.granted) {
    return;
  }
}

  setState(() {
    _isGettingLocation = true;
  });

  locationData = await location.getLocation();
  final lat = locationData.latitude;
  final lng = locationData.longitude;

  if (lat == null || lng == null) {
    return;
  }

  final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=YOUR_API_KEY');
 final response = await http.get(url);
 final resData = json.decode(response.body);
 final address = resData['results'] [0] ['formatted_address'];

  setState(() {
    _pickLocation = PlaceLocation(
      latitude: lat,
       longitude: lng,
        address: address,
        );
    _isGettingLocation = false;
  });

  print(locationData.latitude);
  print(locationData.longitude);
}

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    Widget previewContent = Text(
        'No location chosen', 
        textAlign: TextAlign.center, 
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color:Theme.of(context).colorScheme.onBackground,
        ),
        
        );

        if (_pickLocation != null)  {
          previewContent = Image.network(LocationImage,fit: BoxFit.cover, width: double.infinity, height: double.infinity);
        }

     if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
     }

   return Column(
    children: [
    Container(
      height: 170,
      width: double.infinity,
      alignment: Alignment.center,
       decoration: BoxDecoration(
        border: Border.all(width: 1, color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        )
      ),
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.location_on),
          label: const Text('Get Current Location'),
          onPressed: _getCurrentLocation,
        ),
        TextButton.icon(
          icon: const Icon(Icons.map),
          label: const Text('select on map'),
          onPressed: () {},
        )
      ],
    ),
   ],
   );
  }
}