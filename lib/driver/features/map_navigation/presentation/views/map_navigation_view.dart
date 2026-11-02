import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/core/utils/view_status.dart';
import '../controllers/map_navigation_controller.dart';

class MapNavigationView extends GetView<MapNavigationController> {
  const MapNavigationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خرائط الملاحة والتوصيل'),
        centerTitle: true,
      ),
      body: Obx(() {
        // مراقبة حالة الشاشة وحقن الصلاحيات
        switch (controller.status.value) {
          case ViewStatus.loading:
            return const Center(
              child: CircularProgressIndicator(),
            );
            
          case ViewStatus.error:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'فشل الوصول إلى خدمات الموقع',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'يرجى التأكد من تفعيل الـ GPS ومنح التطبيق صلاحيات الموقع بالكامل للتمكن من بدء التوصيل.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => controller.onInit(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );

          case ViewStatus.success:
          case ViewStatus.empty:
            return Stack(
              children: [
                // عرض خريطة جوجل التفاعلية
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: controller.currentPosition.value,
                    zoom: 15.0,
                  ),
                  onMapCreated: (GoogleMapController mapController) {
                    controller.mapController = mapController;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  markers: controller.markers,
                  polylines: controller.polylines,
                ),
                
                // نافذة عائمة تظهر إحداثيات السائق الحالية للتأكد من المزامنة
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.navigation, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'نظام التتبع الحي نشط',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'الموقع: ${controller.currentPosition.value.latitude.toStringAsFixed(4)}, ${controller.currentPosition.value.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
        }
      }),
    );
  }
}
