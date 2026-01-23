import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraPosition initialPosition = CameraPosition(
    target: LatLng(37.5214, 126.9246),
    zoom: 15,
  );
  late final GoogleMapController controller;

  checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      throw "위치 기능을 활성화 해주세요.";
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();
    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();
    }

    if (checkedPermission != LocationPermission.always
    && checkedPermission != LocationPermission.whileInUse) {
      throw "위치 권한을 허가해주세요.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // (안드로이드) title 텍스트 가운데 정렬
        title: Text(
          '오늘도 출근',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: myLocationPressed,
            icon: Icon(Icons.my_location),
            color: Colors.blue,
          )
        ],
      ),
      body: FutureBuilder(
          future: checkPermission(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: initialPosition,
                    // mapType: MapType.normal,
                    myLocationEnabled: true, // 내 위치를 표시함.
                    myLocationButtonEnabled: false, // 내 위치로 가기 버튼을 없앰.
                    zoomControlsEnabled: false, // (안드로이드) 줌 버튼을 없앰.
                    // GoogleMap 위젯으로 가기 해보면 다양한 옵션 확인 가능
                    onMapCreated: (GoogleMapController controller) {
                      this.controller = controller;
                    },
                    markers: {
                      Marker(
                        markerId: MarkerId('123'),
                        position: LatLng(37.5214, 126.9246),
                      ),
                    },
                    circles: {
                      Circle(
                        circleId: CircleId('inDistance'),
                        center: LatLng(37.5214, 126.9246),
                        radius: 100,
                        fillColor: Colors.blue.withValues(alpha: 0.5),
                        strokeColor: Colors.blue,
                        strokeWidth: 1,
                      )
                    },
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  myLocationPressed() async {
    final location = await Geolocator.getCurrentPosition();
    controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(location.latitude, location.longitude),
        ),
    );
  }

}
