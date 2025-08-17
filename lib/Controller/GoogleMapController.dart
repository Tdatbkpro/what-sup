// ignore: file_names
import 'package:geolocator/geolocator.dart';
class GoogleMapController {
  
Future<String> getCurrentLocationLink() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception("Dịch vụ định vị chưa bật");
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception("Quyền truy cập vị trí bị từ chối");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception("Quyền truy cập vị trí bị từ chối vĩnh viễn");
  }

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  String googleMapsUrl =
      "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
  return googleMapsUrl;
}

}