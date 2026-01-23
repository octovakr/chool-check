import 'package:flutter/cupertino.dart';
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

  final double okDistance = 100;

  bool choolCheckDone = false;
  bool canChoolCheck = false;

  late final GoogleMapController controller;

  @override
  initState() {
    super.initState();
    Geolocator.getPositionStream().listen((e) {
      final start = LatLng(37.5214, 126.9246);
      final end = LatLng(e.latitude, e.longitude);

      final distance = Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
      setState(() {
        if (distance <= okDistance) {
          canChoolCheck = true;
        } else {
          canChoolCheck = false;
        }
      });
    });
  }

  checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      throw "위치 기능을 활성화 해주세요.";
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();
    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();
    }

    if (checkedPermission != LocationPermission.always &&
        checkedPermission != LocationPermission.whileInUse) {
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
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: myLocationPressed,
            icon: Icon(Icons.my_location),
            color: Colors.blue,
          ),
        ],
      ),
      body: FutureBuilder(
        future: checkPermission(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return Column(
            children: [
              Expanded(
                flex: 2,
                child: _GoogleMap(
                  initialCameraPosition: initialPosition,
                  onMapCreated: (GoogleMapController controller) {
                    this.controller = controller;
                  },
                  radius: okDistance,
                  canChoolCheck: canChoolCheck,
                ),
              ),
              Expanded(
                child: _BottomChoolCheckButton(
                  choolCheckDone: choolCheckDone,
                  canChoolCheck: canChoolCheck,
                  choolCheckPressed: choolCheckPressed,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  choolCheckPressed() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('출근하기'),
          content: Text('출근을 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // dialog도 하나의 페이지다.
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: Text('출근하기'),
            ),
          ],
        );
      },
    );
    if (result) {
      setState(() {
        choolCheckDone = result;
      });
    }
  }

  myLocationPressed() async {
    final location = await Geolocator.getCurrentPosition();
    controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
    );
  }
}

class _GoogleMap extends StatelessWidget {
  final CameraPosition initialCameraPosition;
  final MapCreatedCallback onMapCreated;
  final double radius;
  final bool canChoolCheck;

  const _GoogleMap({
    required this.initialCameraPosition,
    required this.onMapCreated,
    required this.radius,
    required this.canChoolCheck,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      // mapType: MapType.normal,
      myLocationEnabled: true,
      // 내 위치를 표시함.
      myLocationButtonEnabled: false,
      // 내 위치로 가기 버튼을 없앰.
      zoomControlsEnabled: false,
      // (안드로이드) 줌 버튼을 없앰.
      // GoogleMap 위젯으로 가기 해보면 다양한 옵션 추가로 확인 가능
      onMapCreated: onMapCreated,
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
          radius: radius,
          fillColor: canChoolCheck
              ? Colors.blue.withValues(alpha: 0.5)
              : Colors.red.withValues(alpha: 0.5),
          strokeColor: canChoolCheck ? Colors.blue : Colors.red,
          strokeWidth: 1,
        ),
      },
    );
  }
}

class _BottomChoolCheckButton extends StatelessWidget {
  final bool choolCheckDone;
  final bool canChoolCheck;
  final VoidCallback choolCheckPressed;

  const _BottomChoolCheckButton({
    required this.choolCheckDone,
    required this.canChoolCheck,
    required this.choolCheckPressed,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          choolCheckDone ? Icons.check : Icons.timelapse_outlined,
          color: choolCheckDone ? Colors.green : Colors.blue,
        ),
        SizedBox(height: 16.0),
        if (!choolCheckDone && canChoolCheck)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            onPressed: choolCheckPressed,
            child: Text('출근하기'),
          ),
      ],
    );
  }
}
