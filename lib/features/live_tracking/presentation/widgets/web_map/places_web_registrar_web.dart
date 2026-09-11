import 'dart:js_interop';

import 'package:flutter_google_places_sdk_platform_interface/flutter_google_places_sdk_platform_interface.dart'
    as inter;
import 'package:flutter_google_places_sdk_web/extension.dart' as ext;
import 'package:flutter_google_places_sdk_web/flutter_google_places_sdk_web.dart';
import 'package:google_maps/google_maps_places.dart' as places;

/// Web plugin override that correctly requests and maps 'location' and 'displayName'
/// from Google Places (New) API on the web.
class FixedFlutterGooglePlacesSdkWebPlugin
    extends FlutterGooglePlacesSdkWebPlugin {
  @override
  Future<inter.FetchPlaceResponse> fetchPlace(
    String placeId, {
    required List<inter.PlaceField> fields,
    bool? newSessionToken,
    String? regionCode,
  }) async {
    // Google Places (New) API expects camelCase field names on the web.
    final fieldStrings = <String>{
      'location',
      'displayName',
      'formattedAddress',
      'id',
    };

    final fieldsJs =
        fieldStrings.map((s) => s.toJS).toList(growable: false).toJS;

    final place = places.Place(
      places.PlaceOptions(id: placeId),
    );

    final task = place.fetchFields(places.FetchFieldsRequest(fields: fieldsJs))
        as JSPromise<JSObject>?;

    final result = await task?.toDart;
    final response = result as ext.FetchFieldsResponse?;
    final resultPlace = response?.place;

    inter.LatLng? latLng;
    final loc = resultPlace?.location;
    if (loc != null) {
      latLng = inter.LatLng(
        lat: loc.lat.toDouble(),
        lng: loc.lng.toDouble(),
      );
    }

    final placeResult = inter.Place(
      id: resultPlace?.id ?? placeId,
      name: resultPlace?.displayName,
      address: resultPlace?.formattedAddress,
      latLng: latLng,
      addressComponents: null,
      attributions: null,
      businessStatus: null,
      nameLanguageCode: null,
      openingHours: null,
      phoneNumber: null,
      photoMetadatas: null,
      plusCode: null,
      priceLevel: null,
      rating: null,
      reviews: null,
      types: null,
      userRatingsTotal: null,
      utcOffsetMinutes: null,
      viewport: null,
      websiteUri: null,
    );

    return inter.FetchPlaceResponse(placeResult);
  }
}

void initPlacesWeb() {
  if (inter.FlutterGooglePlacesSdkPlatform.instance
      is! FixedFlutterGooglePlacesSdkWebPlugin) {
    inter.FlutterGooglePlacesSdkPlatform.instance =
        FixedFlutterGooglePlacesSdkWebPlugin();
  }
}
