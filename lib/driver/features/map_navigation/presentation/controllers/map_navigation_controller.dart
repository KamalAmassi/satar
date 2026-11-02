import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project/core/utils/view_status.dart';

class MapNavigationController extends GetxController {
  // تتبع حالة الواجهة (تحميل، نجاح، خطأ)
  final status = ViewStatus.loading.obs;

  // متغيرات الخريطة والموقع
  GoogleMapController? mapController;
  final currentPosition = const LatLng(0.0, 0.0).obs;
  
  // بث تتبع الموقع الحي
  StreamSubscription<Position>? _locationStreamSubscription;

  // مجموعات الرسم على الخريطة
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermissionAndStartTracking();
  }

  // التحقق من الصلاحيات وبدء التتبع الحي مع ميزة التصفية لحل مشكلة استهلاك الـ API
  Future<void> _checkPermissionAndStartTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      status.value = ViewStatus.error;
      Get.snackbar('خطأ', 'يرجى تفعيل خدمات الموقع (GPS) في الجهاز');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        status.value = ViewStatus.error;
        Get.snackbar('خطأ', 'تم رفض صلاحيات الوصول للموقع');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      status.value = ViewStatus.error;
      Get.snackbar('خطأ', 'صلاحيات الموقع مرفوضة دائماً، يرجى تفعيلها من الإعدادات');
      return;
    }

    // نجاح الصلاحيات وبدء تتبع البث الحي
    status.value = ViewStatus.success;
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    // حل مشكلة اللوب اللانهائي: نحدث الموقع فقط إذا تحرك السائق 10 أمتار على الأقل
    _locationStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, 
      ),
    ).listen((Position position) {
      currentPosition.value = LatLng(position.latitude, position.longitude);
      
      // تحديث واجهة الخريطة ونقل الكاميرا تلقائياً مع تحرك السائق
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(currentPosition.value),
        );
      }
      
      _updateDriverMarker();
      _syncLocationWithServer(position);
    });
  }

  void _updateDriverMarker() {
    markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: currentPosition.value,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'موقعك الحالي'),
      ),
    );
  }

  // محاكاة إرسال الإحداثيات الجديدة للسيرفر لتحديث موقع السائق عند العميل
  void _syncLocationWithServer(Position position) {
    // TODO: استدعاء الـ UseCase الخاص بتحديث الموقع على السيرفر هنا لاحقاً
    print("تم تحديث موقع السائق على السيرفر: ${position.latitude}, ${position.longitude}");
  }

  @override
  void onClose() {
    // خطوة حرجة جداً: إيقاف البث فور إغلاق الشاشة لمنع استهلاك موارد الجهاز والبطارية
    _locationStreamSubscription?.cancel();
    mapController?.dispose();
    super.onClose();
  }
}
